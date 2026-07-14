# shell/integration.bash --- Emacs/ghostel/byobu shell integration (vendored)
#
# Sourced from ~/.bashrc via an emacs-managed block (see `my-ensure-shell-
# integration' in init.el, which also symlinks the byobu config below).  Keep
# this self-contained and idempotent so it can be sourced from any interactive
# bash.  Everything here is version-controlled in the .emacs.d repo.

# mise: polyglot runtime/tool version manager (node, erlang, elixir, ...).
# Activation puts mise-managed tool shims on PATH and enables per-project
# version switching (mise.toml / .tool-versions), much like direnv does for env.
if [ -x "$HOME/.local/bin/mise" ]; then
    eval "$("$HOME/.local/bin/mise" activate bash)"
fi

# direnv: load each project's .envrc on `cd', so the byobu tabs get the same
# per-project environment as Emacs (via envrc).  `direnv allow' once to trust it.
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

# git-aware prompt: show branch + working-tree state in PS1.  Injected (bold
# yellow, before the prompt char) into whatever PS1 ~/.bashrc already built —
# this file is sourced last, so the stock prompt stays untouched upstream.
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    . /usr/lib/git-core/git-sh-prompt
    GIT_PS1_SHOWDIRTYSTATE=1     # '*' unstaged, '+' staged
    GIT_PS1_SHOWSTASHSTATE=1     # '$' stashed
    GIT_PS1_SHOWUNTRACKEDFILES=1 # '%' untracked
    GIT_PS1_SHOWUPSTREAM=auto    # '<' '>' '=' vs upstream
    case "$PS1" in
        *__git_ps1*) ;; # already injected (idempotent if sourced twice)
        *) PS1=${PS1/'\$ '/'\[\033[01;33m\]$(__git_ps1 " (%s)")\[\033[00m\]\$ '} ;;
    esac
fi

# execution-time stamp: a dim [HH:MM:SS] prefix showing when the command actually
# RAN, not when its prompt was drawn (`\t' in PS1 alone gives you the latter --
# useless if you sat at the prompt a while before hitting Enter).  PS1 seeds the
# slot with the draw time; PS0 -- expanded the instant Enter is pressed, after the
# command is read but before it executes -- jumps back up and overwrites those 8
# chars in place.  Scrollback then tells you when each command was executed.
#   \e[F  start of previous line   \e[2G  column 2 (inside the brackets)
#   \e[E  back down to the start of the output line
# Prefixed, so the stamp is always the first visible thing -> column 2 is stable.
# Caveat: assumes the typed command fits on one line; if it wraps, \e[F lands on
# the wrapped line and the stamp overwrites 8 chars of the echo (cosmetic only).
case "$PS1" in
    *'[\t]'*) ;; # already prefixed (idempotent if sourced twice)
    *) PS1='\[\e[2m\][\t]\[\e[0m\] '"$PS1" ;;
esac
PS0='\e[F\e[2G\e[2m$(date +%H:%M:%S)\e[0m\e[E'

# Bash has no built-in "re-read your rc" signal, so give it one.
trap 'source ~/.bashrc' USR1

# Reload every OTHER shell carrying that trap.  Never use a bare `pkill -USR1
# bash': SIGUSR1's default action is TERMINATE, so it would kill any bash that
# lacks the trap -- including running bash *scripts*.  This only signals processes
# that actually CATCH USR1 (SigCgt bit 10 = 0x200 in /proc/PID/status), so it can
# never kill anything.
reload-shells() {
    local p mask n=0
    for p in $(pgrep -x bash); do
        [ "$p" = "$$" ] && continue
        mask=$(awk '/^SigCgt:/{print $2}' "/proc/$p/status" 2>/dev/null) || continue
        if [ -n "$mask" ] && ((0x$mask & 0x200)); then
            kill -USR1 "$p" 2>/dev/null && n=$((n + 1))
        fi
    done
    echo "reloaded $n shell(s)"
}

# --- byobu + Emacs/ghostel projectile integration -----------------------------
# byobu reads its config from $BYOBU_CONFIG_DIR; the customized files there
# (status, .tmux.conf, bin/bb-save-layout) are symlinks into this repo's byobu/.
export BYOBU_CONFIG_DIR="$HOME/.config/byobu"

# Default tabs for a brand-new project session, and the command each starts with
# (empty = just a shell).  On restore, only these known names get their command
# re-run; any custom tab you added comes back as a plain shell.
__BB_DEFAULT_WINDOWS=(claude shell git test)
declare -A __BB_WINDOW_CMD=(
    [claude]='claude --continue || claude'
    [git]='git status'
)

__bb_layout_file() { # $1 = session name -> path to its saved layout file
    local dir="${BYOBU_CONFIG_DIR:-$HOME/.config/byobu}/layouts"
    mkdir -p "$dir"
    printf '%s/%s' "$dir" "${1//\//__}"
}

# `bb' attaches (or creates) the project's persistent byobu/tmux session.  Emacs
# C-t launchers send `bb' into a ghostel buffer; it also works by hand from any
# shell (a separate terminal, VS Code, a subdirectory), deriving the project
# name from the git top-level so it lands in the SAME session as Emacs.
bb() {
    # `bb -g [window]' opens a grouped VIEW instead of a direct attach (see below).
    local grouped=0 startwin=""
    if [[ "$1" == "-g" ]]; then
        grouped=1
        shift
        startwin="${1:-}"
    fi

    local rawproj="${PROJECTILE_PROJECT_NAME:-$(basename "$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || echo "$PWD")")}"
    # tmux rewrites '.' and ':' in a session name to '_'; do it ourselves so our
    # explicit `=session:window' targets match the stored name (e.g. `.emacs.d').
    local proj="${rawproj//[.: ]/_}"
    local session="projectile/$proj"

    # `bb -g [window]' — a second, INDEPENDENT view of this project's session: a
    # grouped tmux session that shares the exact same windows but keeps its own
    # active-window pointer, so a second Emacs pane can sit on a different tab.
    # Two plain clients on one session move in lockstep; a grouped session is the
    # tmux mechanism that decouples the active window.  Ephemeral: killed on
    # detach, so the real session and its panes are never touched.
    if ((grouped)); then
        # Only meaningful from a fresh, non-tmux shell (tmux refuses to attach
        # inside itself) — which is exactly what the Emacs command spawns.
        if [[ -n "$TMUX" ]]; then
            echo "bb -g: already inside tmux — run it from a fresh shell (M-x my-ghostel-grouped-view)." >&2
            return 1
        fi
        if ! tmux has-session -t "=$session" 2>/dev/null; then
            echo "bb -g: '$session' isn't running — start it with plain 'bb' first." >&2
            return 1
        fi
        # Emacs mints the view name so it can target this view's tabs (C-t); fall
        # back to a per-shell name for manual use.  '^' is tmux-safe (unlike '.'/':').
        local view="${BB_VIEW_SESSION:-${session}^v$$}"
        tmux has-session -t "=$view" 2>/dev/null ||
            tmux new-session -d -t "=$session" -s "$view" || return 1
        # Default the view to a DIFFERENT window than the base session is showing.
        # Two grouped clients on the SAME window at different widths fight over its
        # size (window-size latest) and tear each other's redraw — that's what
        # briefly garbles the main terminal.  Landing apart avoids it: each window
        # sizes cleanly to its sole viewer.  Selected BEFORE `attach' so the shared
        # window never even momentarily gets a second viewer.
        if [[ -z "$startwin" ]]; then
            # Collect tabs already shown by the base session AND any sibling view,
            # then land on one nobody's on — so several side-by-side views spread
            # across different tabs by themselves.
            local -A taken=()
            local sname wactive wname w
            while IFS='|' read -r sname wactive wname; do
                [[ "$wactive" == 1 ]] || continue
                [[ "$sname" == "$session" || "$sname" == "$session"^v* ]] || continue
                taken["$wname"]=1
            done < <(tmux list-windows -a \
                -F '#{session_name}|#{window_active}|#{window_name}' 2>/dev/null)
            while IFS= read -r w; do
                [[ -z "${taken[$w]:-}" ]] && {
                    startwin="$w"
                    break
                }
            done < <(tmux list-windows -t "=$session" -F '#{window_name}' 2>/dev/null)
            # Every tab already on screen -> accept the base's current one.
            [[ -z "$startwin" ]] && startwin=$(tmux list-windows -t "=$session" \
                -F '#{window_active} #{window_name}' 2>/dev/null | awk '$1==1{print $2; exit}')
        fi
        [[ -n "$startwin" ]] && tmux select-window -t "=$view:$startwin" 2>/dev/null
        # Reap the ephemeral view however this shell ends: a clean detach (F6)
        # returns from `attach' below; a buffer-kill sends SIGHUP -> the trap.
        # kill-session is a no-op if already gone.
        trap "tmux kill-session -t '=$view' 2>/dev/null" EXIT HUP
        tmux attach -t "=$view"                   # blocks until you detach
        tmux kill-session -t "=$view" 2>/dev/null # detached -> reap the view now
        # Emacs spawns us in a throwaway shell and wants F6 to close the ghostel
        # buffer (BB_VIEW_SESSION is set); a manual `bb -g' in a real terminal
        # should instead drop back to the prompt, not close the window.
        if [[ -n "${BB_VIEW_SESSION:-}" ]]; then
            exit
        else
            trap - EXIT HUP
            return
        fi
    fi

    # Already running?  Just attach — its windows live in the tmux server.
    if tmux has-session -t "=$session" 2>/dev/null; then
        tmux set-option -t "$session" @project "$rawproj" 2>/dev/null
        byobu attach -t "$session"
        return
    fi

    # Fresh session: tab names from the saved per-project layout, else defaults.
    local file
    file="$(__bb_layout_file "$session")"
    local -a names
    if [[ -s "$file" ]]; then
        mapfile -t names <"$file"
    else
        names=("${__BB_DEFAULT_WINDOWS[@]}")
    fi
    [[ ${#names[@]} -eq 0 ]] && names=("${__BB_DEFAULT_WINDOWS[@]}")

    # De-dup while preserving order, so a stale/corrupt layout file (or an old
    # duplicated session captured by bb-save-layout) can't spawn twin windows.
    local -a uniq=()
    local -A seen=()
    local n
    for n in "${names[@]}"; do
        [[ -z "$n" || -n "${seen[$n]:-}" ]] && continue
        seen[$n]=1
        uniq+=("$n")
    done
    names=("${uniq[@]}")

    local first=1 name cmd
    for name in "${names[@]}"; do
        [[ -z "$name" ]] && continue
        if ((first)); then
            # Create through byobu-tmux so a fresh server loads byobu's profile
            # (-f ...); plain tmux would come up with the stock green status bar.
            byobu-tmux new-session -d -s "$session" -n "$name" -c "$PWD"
            first=0
        else
            tmux new-window -t "=$session" -n "$name" -c "$PWD"
        fi
        # Pin the tab name so tmux/apps don't auto-rename it to the running cmd.
        tmux set-window-option -t "=$session:$name" automatic-rename off >/dev/null
        tmux set-window-option -t "=$session:$name" allow-rename off >/dev/null
        cmd="${__BB_WINDOW_CMD[$name]}"
        [[ -n "$cmd" ]] && tmux send-keys -t "=$session:$name" "$cmd" Enter
    done
    tmux select-window -t "=$session:${names[0]}"
    tmux set-option -t "$session" @project "$rawproj" 2>/dev/null
    byobu attach -t "$session"
}

# Reset a project's tabs to the defaults — forgets the saved layout and kills the
# session (asks first); reopen with `bb' (or C-t in Emacs) for fresh defaults.
bb-reset() {
    local session="projectile/${PROJECTILE_PROJECT_NAME:-$(basename "$PWD")}"
    local ans
    read -rp "Reset '$session' to default tabs? Kills the session. [y/N] " ans
    case "$ans" in
        [yY]*) ;;
        *)
            echo "aborted"
            return 1
            ;;
    esac
    rm -f "$(__bb_layout_file "$session")"
    echo "Cleared saved layout for '$session'."
    if tmux has-session -t "=$session" 2>/dev/null; then
        echo "Killing it — reopen with 'bb' (or C-t in Emacs) for default tabs."
        tmux kill-session -t "=$session" 2>/dev/null
    fi
}

# ghostel / Emacs integration.  Active in a bare ghostel shell AND inside the
# byobu session `bb' attaches (INSIDE_EMACS=ghostel is inherited by byobu panes).
#   * emacsclient (a unix socket) for the editor + "open in Emacs" helpers — it
#     pierces tmux, so these work identically inside or outside byobu.
#   * OSC escape sequences for directory tracking — tmux swallows these unless
#     passthrough-wrapped (see __ghostel_emit) and `set -g allow-passthrough on'.
if [[ "${INSIDE_EMACS%%,*}" = 'ghostel' || "$TERM" = 'xterm-ghostty' ]]; then

    # Editor: git commit / `git rebase -i' / any $EDITOR child opens in the outer
    # Emacs and blocks until you finish (C-c C-c) / cancel (C-c C-k).
    if command -v emacsclient >/dev/null 2>&1; then
        export EDITOR='emacsclient'
        export VISUAL='emacsclient'
        export GIT_EDITOR='emacsclient'
        export GIT_SEQUENCE_EDITOR='emacsclient'

        # Interactive shortcuts -> the vendored `eopen' script (one impl, shared
        # with Claude; `my-ensure-shell-integration' puts it on PATH).
        e() { eopen "$@"; }
        emacs() { eopen "$@"; }
        open() { eopen "$@"; }
    fi

    # Directory tracking (OSC 7).  Only needed inside tmux/byobu, passthrough-wrapped.
    if [[ -n "$TMUX" ]]; then
        __ghostel_emit() { printf '\ePtmux;\e\e]%s\a\e\\' "$1"; }
        __ghostel_osc7() { __ghostel_emit "7;file://${HOSTNAME}${PWD}"; }
        ghostel_cmd() {
            local payload='' arg
            for arg in "$@"; do
                payload="$payload\"$(printf '%s' "$arg" | sed -e 's|\\|\\\\|g' -e 's|"|\\"|g')\" "
            done
            __ghostel_emit "51;E${payload}"
        }
        case ";${PROMPT_COMMAND};" in
            *";__ghostel_osc7;"*) ;;
            *) PROMPT_COMMAND="__ghostel_osc7;${PROMPT_COMMAND}" ;;
        esac
        __ghostel_osc7

        # Per-byobu-window bash history.  Stock bash funnels every shell into one
        # ~/.bash_history, so up-arrow in one window replays commands from all the
        # others (merged by exit order).  Give each window its own file, keyed by
        # session + window name, under ~/.bash_history.d -- loaded at shell start
        # (not the shared file) and appended on every prompt (`history -a', no
        # -c/-r, so windows never cross-contaminate) so an abrupt shutdown keeps
        # it.  Outside tmux the shell keeps stock ~/.bash_history.
        __bb_hist_key=$(tmux display-message -p '#{session_name}__#{window_name}' \
            2>/dev/null | tr -d '\n' | tr -c 'A-Za-z0-9_.-' '_')
        if [[ -n "$__bb_hist_key" ]]; then
            mkdir -p "$HOME/.bash_history.d"
            HISTFILE="$HOME/.bash_history.d/$__bb_hist_key"
            history -c
            history -r 2>/dev/null # this window's history, not the shared one
            case ";${PROMPT_COMMAND};" in
                *";history -a;"*) ;;
                *) PROMPT_COMMAND="history -a;${PROMPT_COMMAND}" ;;
            esac
        fi
        unset __bb_hist_key
    fi

    say() { ghostel_cmd message "%s" "$*"; }
fi
# ------------------------------------------------------------------------------
