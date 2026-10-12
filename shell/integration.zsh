# shell/integration.zsh --- Emacs/ghostel/byobu shell integration (zsh)
#
# The zsh half of shell/integration.bash: same features, sourced from ~/.zshrc via
# an emacs-managed block (see `my-ensure-shell-integration' in init.el, which also
# symlinks the byobu config below).  Keep this self-contained and idempotent so it
# can be sourced from any interactive zsh.
#
# Why this file exists: macOS's login shell is zsh, ghostel spawns `$SHELL', and
# zsh reads ~/.zshrc for an interactive login shell (unlike bash, whose login
# shells never read ~/.bashrc).  So on a Mac the terminal Emacs opens is THIS
# file -- which is the whole point: `bb', the byobu tabs and the `e*' bridge are
# the same in your own terminal and in Emacs's.
#
# KEEP IN SYNC WITH shell/integration.bash.  Two things are deliberately absent
# here, both because zsh already has them:
#
#   * The PROMPT.  The bash file injects a git-status segment and an execution-time
#     stamp into PS1/PS0 because a stock bash prompt carries neither.  Here the
#     prompt is starship's (~/.zshrc): it already draws branch + dirty state, and
#     rewriting a prompt the user has deliberately configured is not our business.
#   * Per-window history.  Stock bash funnels every shell into one ~/.bash_history
#     merged at exit, so the bash file gives each byobu window its own file.  zsh
#     here already runs SHARE_HISTORY with immediate appends (~/.zshrc), which
#     cannot cross-contaminate or reorder on exit -- so there is nothing to fix,
#     and setting HISTFILE would only take that away.

# mise: polyglot runtime/tool version manager (node, erlang, elixir, ...).
# Activation puts mise-managed tool shims on PATH and enables per-project version
# switching (mise.toml / .tool-versions), much like direnv does for env.  MISE_SHELL
# is set by the activation itself -- a nested shell that inherited it (or an
# ~/.zshrc that already activated mise, which this machine's does) must not
# activate twice: it would stack a second chpwd/precmd hook.
if [ -z "${MISE_SHELL:-}" ] && command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

# direnv: load each project's .envrc on `cd', so the byobu tabs get the same
# per-project environment as Emacs (via envrc).  `direnv allow' once to trust it.
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

# Bash has no built-in "re-read your rc" signal, so the bash file gives it one --
# SIGUSR1 -- and defers the re-source to the next prompt, because sourcing an rc
# with a live readline history pointer can segfault bash.  zsh has no such hazard,
# but the deferral costs nothing and keeps the two files the same shape.
_bb_reload_pending=
trap '_bb_reload_pending=1' USR1
_bb_reload_if_pending() {
    [ -n "$_bb_reload_pending" ] || return 0
    _bb_reload_pending=
    source ~/.zshrc
}

# Reload every OTHER shell carrying that trap.  Never use a bare `pkill -USR1 zsh':
# SIGUSR1's default action is TERMINATE, so it would kill any zsh that lacks the
# trap -- including one running a script.  The bash file proves a process catches
# USR1 by reading SigCgt out of /proc/PID/status; macOS has no /proc, so this is a
# conservative shape test instead: signal only a BARE interactive/login zsh (its
# command line is exactly `zsh' or `-zsh'), never one with arguments.
reload-shells() {
    local p cmd n=0
    for p in $(pgrep -x zsh); do
        [ "$p" = "$$" ] && continue
        cmd=$(ps -o command= -p "$p" 2>/dev/null) || continue
        case "$cmd" in
            zsh|'-zsh')
                kill -USR1 "$p" 2>/dev/null && n=$((n + 1))
                ;;
        esac
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
__BB_DEFAULT_WINDOWS=(leticode shell git test)
typeset -A __BB_WINDOW_CMD
__BB_WINDOW_CMD[leticode]='leticode --continue || leticode'
__BB_WINDOW_CMD[git]='git status'

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

    # `bb -g [window]' -- a second, INDEPENDENT view of this project's session: a
    # grouped tmux session that shares the exact same windows but keeps its own
    # active-window pointer, so a second Emacs pane can sit on a different tab.
    # Two plain clients on one session move in lockstep; a grouped session is the
    # tmux mechanism that decouples the active window.  Ephemeral: killed on
    # detach, so the real session and its panes are never touched.
    if ((grouped)); then
        # Only meaningful from a fresh, non-tmux shell (tmux refuses to attach
        # inside itself) -- which is exactly what the Emacs command spawns.
        if [[ -n "$TMUX" ]]; then
            echo "bb -g: already inside tmux -- run it from a fresh shell (M-x my-ghostel-grouped-view)." >&2
            return 1
        fi
        if ! tmux has-session -t "=$session" 2>/dev/null; then
            echo "bb -g: '$session' isn't running -- start it with plain 'bb' first." >&2
            return 1
        fi
        # Emacs mints the view name so it can target this view's tabs (C-t); fall
        # back to a per-shell name for manual use.  '^' is tmux-safe (unlike '.'/':').
        local view="${BB_VIEW_SESSION:-${session}^v$$}"
        tmux has-session -t "=$view" 2>/dev/null ||
            tmux new-session -d -t "=$session" -s "$view" || return 1
        # Default the view to a DIFFERENT window than the base session is showing.
        # Two grouped clients on the SAME window at different widths fight over its
        # size (window-size latest) and tear each other's redraw -- that's what
        # briefly garbles the main terminal.  Landing apart avoids it: each window
        # sizes cleanly to its sole viewer.  Selected BEFORE `attach' so the shared
        # window never even momentarily gets a second viewer.
        if [[ -z "$startwin" ]]; then
            # Collect tabs already shown by the base session AND any sibling view,
            # then land on one nobody's on -- so several side-by-side views spread
            # across different tabs by themselves.
            local -A taken
            local sname wactive wname w
            while IFS='|' read -r sname wactive wname; do
                [[ "$wactive" == 1 ]] || continue
                [[ "$sname" == "$session" || "$sname" == "${session}^v"* ]] || continue
                taken[$wname]=1
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
        # The expansion of $view is deliberate (not single-quoted): the trap must
        # capture the view name it was armed with, because at signal time the shell
        # may be gone and we would fail to reap the session.
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

    # Already running?  Just attach -- its windows live in the tmux server.
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
        names=("${(@f)$(<"$file")}")
    else
        names=("${__BB_DEFAULT_WINDOWS[@]}")
    fi
    [[ ${#names[@]} -eq 0 ]] && names=("${__BB_DEFAULT_WINDOWS[@]}")

    # De-dup while preserving order, so a stale/corrupt layout file (or an old
    # duplicated session captured by bb-save-layout) can't spawn twin windows.
    local -a uniq
    local -A seen
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
    tmux select-window -t "=$session:${names[1]}"
    tmux set-option -t "$session" @project "$rawproj" 2>/dev/null
    byobu attach -t "$session"
}

# Reset a project's tabs to the defaults -- forgets the saved layout and kills the
# session (asks first); reopen with `bb' (or C-t in Emacs) for fresh defaults.
bb-reset() {
    # Derive the session name EXACTLY as `bb' does -- from the git top-level, with
    # . : sanitized to _ -- or the kill/rm below target a name that never exists
    # (e.g. `projectile/.emacs.d' instead of `projectile/_emacs_d'), silently
    # leaving the real session running.
    local rawproj="${PROJECTILE_PROJECT_NAME:-$(basename "$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || echo "$PWD")")}"
    local session="projectile/${rawproj//[.: ]/_}"
    local ans
    printf "Reset '%s' to default tabs? Kills the session. [y/N] " "$session"
    read -r ans
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
        echo "Killing it -- reopen with 'bb' (or C-t in Emacs) for default tabs."
        tmux kill-session -t "=$session" 2>/dev/null
    fi
}

# ghostel / Emacs integration.  Active in a bare ghostel shell AND inside the
# byobu session `bb' attaches (INSIDE_EMACS=ghostel is inherited by byobu panes).
#   * emacsclient (a unix socket) for the editor + "open in Emacs" helpers -- it
#     pierces tmux, so these work identically inside or outside byobu.
#   * OSC escape sequences for directory tracking -- tmux swallows these unless
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
        # with the assistant; `my-ensure-shell-integration' puts it on PATH).
        e() { eopen "$@"; }
        open() { eopen "$@"; }

        # `emacs' is the same shortcut, but ONLY for a plain list of files.  Any
        # option means you asked for a real Emacs process -- most of all `-nw',
        # a terminal Emacs in this pane (the natural thing over ssh, where there
        # may be no outer Emacs at all).  Without this, `emacs -nw' ran
        # `eopen -nw', which realpath'd the flag into `$PWD/-nw' and opened THAT
        # bogus file in the outer Emacs: nothing came up here, and you got a junk
        # buffer over there.
        emacs() {
            local arg
            for arg in "$@"; do
                case "$arg" in
                    -*)
                        command emacs "$@"
                        return
                        ;;
                esac
            done
            eopen "$@"
        }
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
        # zsh's equivalent of PROMPT_COMMAND is the `precmd' hook.  Registering is
        # idempotent: `(r)' returns the matching element, so a re-source (the USR1
        # reload above) cannot stack a second copy.
        if [[ -z "${precmd_functions[(r)__ghostel_osc7]}" ]]; then
            autoload -Uz add-zsh-hook
            add-zsh-hook precmd __ghostel_osc7
        fi

        say() { ghostel_cmd message "%s" "$*"; }
    fi
fi

# Same registration, outside the ghostel guard: _bb_reload_if_pending must be on
# precmd in every shell that traps USR1 (a reload is useful in a plain terminal too).
if [[ -z "${precmd_functions[(r)_bb_reload_if_pending]}" ]]; then
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _bb_reload_if_pending
fi
# ------------------------------------------------------------------------------
