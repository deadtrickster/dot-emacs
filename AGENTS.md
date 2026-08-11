# AGENTS.md

This repository is **`~/.emacs.d`** — one Emacs configuration that also **vendors
the shell + byobu/tmux integration it drives**. It's the monorepo for the whole
terminal/editor setup: a fresh machine clones it, launches Emacs, and Emacs wires
up the rest.

## Layout (only these files are hand-maintained / tracked)

| Path | What |
|---|---|
| `early-init.el` | Pre-package init. **Only** MELPA registration — must live here (runs before `package-initialize`). |
| `init.el` | The entire Emacs config, `use-package`-based throughout. |
| `shell/integration.bash` | Vendored shell integration: `bb`/`bb-reset`, ghostel/`emacsclient` helpers, direnv hook, git-prompt. Sourced by `~/.bashrc`. |
| `shell/bin/*` | Vendored standalone helper scripts symlinked onto PATH (`~/.local/bin`) by the installer so Claude's non-interactive shell can run them: the `e*` Emacs bridge (`eopen`, `esay`, `enotify`, `ecommit`, `ebuffer`, `esh`, `etab`, `etty`, `ediff-review`) + the `oriole-*` formatters. |
| `byobu/{status,.tmux.conf,bin/bb-save-layout}` | Vendored byobu config; symlinked into `~/.config/byobu/`. |
| `claude/{inside-emacs.md,hooks/inside-emacs-context}` | Vendored "Claude is running inside Emacs" context overlay + its `SessionStart` hook; symlinked into `~/.claude/` and registered in `~/.claude/settings.json`. |
| `bin/check` | The test suite: elisp parens + a full headless load of the config, then `bash -n`/`shellcheck` over every vendored script. Run before committing. |
| `AGENTS.md` / `CLAUDE.md` | This file; `CLAUDE.md` just `@`-imports it. |
| `.gitignore` | Everything else under `~/.emacs.d` is generated (elpa, eln-cache, quelpa, tree-sitter, caches, sessions) and ignored. |

Do **not** commit generated files. The hand-maintained set above is all there is.

## How Emacs drives the install

`my-ensure-shell-integration` (in `init.el`, on `after-init-hook`) is idempotent and:
1. Appends an emacs-managed block to `~/.bashrc` that sources `shell/integration.bash`.
2. Symlinks `byobu/{status,.tmux.conf,bin/bb-save-layout}` → `~/.config/byobu/`.
3. Symlinks `claude/{inside-emacs.md,hooks/inside-emacs-context}` → `~/.claude/`
   and registers that `SessionStart` hook in `~/.claude/settings.json` (a
   defensive, idempotent JSON merge — leaves the file untouched if already
   present or on any parse error), so Claude run from the byobu terminal is told
   it's inside Emacs (`$EDITOR=emacsclient`, `C-t` navigation, `e`/`open`, …).

So shell + byobu + the Claude overlay are edited **in this repo**; the
source-block, symlinks, and hook registration keep the live system in sync.
`~/.bashrc` itself stays stock Debian + machine `PATH`s + that one managed block.

## Development workflow

New features go on a clean branch on top of trunk (`master`):

- **Before starting a *new* feature, the working tree must be clean** (everything
  committed) so the feature starts from a known-good point.
- **If on `master` (trunk):** before doing feature work, ask whether to switch to
  a named feature branch (ask for the name), then branch off.
- **If already on a feature branch** (the feature is actively being developed): a
  dirty tree is fine — but **commit intermediate steps as you go**, so history is
  granular and any step can be rolled back. Be aggressive about this; it's safe
  because everything we care about is vendored in this repo.

## Conventions

- **`init.el` is `use-package` through and through.** Every setting is a
  `use-package … :custom` / `:custom-face`; built-ins use `:ensure nil`. There is
  **no `custom.el`** — `custom-file` points at a throwaway temp so `M-x customize`
  never writes a tracked file. The bootstrap (require package, install
  use-package) and `early-init.el` are the only non-`use-package` top-level code.
- **Verify before trusting — run `./bin/check`.** It is the whole test suite:
  `check-parens` on both elisp files, a **full headless load** of `early-init.el` +
  `init.el` + `after-init-hook` with `debug-on-error` (this is what catches a bad
  `:custom` key, a typo'd hook, a package that vanished from MELPA — `check-parens`
  catches an unbalanced paren and *nothing else*), then `bash -n` + `shellcheck`
  over every vendored script. Run it before every commit.
  - The headless load is only **safe** because every side-effecting startup/exit
    hook is guarded with `noninteractive`: the installer
    (`my-ensure-shell-integration`), the session snapshot (`my-restart--save-state`
    on `kill-emacs-hook` — a batch Emacs exits at once and would otherwise
    **overwrite your real session with an empty one**), and `server-start` (which
    would delete the live Emacs's socket). **Add a hook that touches `$HOME`? Guard
    it the same way**, or `bin/check` becomes destructive.
  - Two footguns baked into the script, in case you run the commands by hand: the
    `(emacs-lisp-mode)` in the `check-parens` form matters (in `fundamental-mode` it
    miscounts parens inside comments/strings and false-fails on this file), and
    `emacs -Q` does **not** activate packages — without an explicit
    `(package-activate-all)` every `:ensure` package "cannot load" and the test
    passes vacuously.
- **Apply live; don't force restarts.** An Emacs server runs (`server-start`).
  Prefer `emacsclient -e` (or loading a temp lexical-binding `.el`) over asking the
  user to restart. Native modules (ghostel) are the exception — they need a restart.
- **Shell/byobu edits** go in `shell/integration.bash` / `byobu/*`, never inline
  in `~/.bashrc`.

## Terminal model (context for changes)

- **ghostel** is an in-Emacs libghostty terminal (the vterm replacement). Per
  project it runs `bb`, attaching a persistent **byobu/tmux** session
  `projectile/<name>` with tabs `claude/shell/git/test`.
- **`C-t` is a prefix map** (`my-ghostel-prefix-map`, bound in the global map and
  `ghostel-mode-map`): `C-t C-c` claude, `C-t C-g` git, `C-t C-s` shell, and
  `C-t C-t` toggles between your code and this project's terminal — from the
  terminal it returns to the *exact* buffer you jumped from (`my-ghostel-toggle-
  terminal`). `C-t` is listed in `ghostel-keymap-exceptions` so it reaches Emacs
  instead of being forwarded to the shell. (No lone-`C-t` action — it's a pure
  prefix; a real command on `C-t` can't host a chord.)
- **`bb`** works from any shell/subdirectory (derives the project from the git
  root). Session names sanitize `.`/`:`→`_` (a tmux restriction); the pretty,
  dot-preserving name is kept in the `@project` tmux option.
- Inside ghostel/byobu, `$EDITOR=emacsclient`, so `git commit` / `git rebase -i`
  open in the running Emacs (magit `git-commit` / `git-rebase` modes).
- **Grouped views** — `C-x 2`/`C-x 3` inside a ghostel terminal DWIM into a
  *second independent view* of the same byobu session (`my-ghostel-grouped-view` →
  `bb -g`), not a naive same-buffer split (which would tear — one PTY can't render
  independently in two windows). Each view is its own ghostel buffer attached to
  an **ephemeral grouped tmux session** (`projectile/<name>^vN`) that shares the
  base session's windows but keeps its own active tab + scrollback — so you can
  watch several byobu windows side by side. Views default to a different tab than
  the base is showing (auto-spread across free tabs). They're peers: the base
  session persists regardless, cleanup (kill the `^vN` session, fold the window)
  is Emacs-driven from `kill-buffer-hook` (hardened to never touch the base), and
  views are excluded from session-restore. `C-t` tab launchers switch *that
  view's* tab; `C-t C-t` returns to your code (or the project's dired).

## Emacs in a terminal / over ssh

- **One Emacs owns the session.** The instance that binds the server socket sets
  `my-emacs-primary-p`, and only it restores the session snapshot at startup and
  writes it on exit. Every other Emacs is stateless. So the way to preserve your
  layout is simply **start the GUI Emacs first** — every later `emacs -nw` is
  then a secondary and cannot touch it.
- **`EMACS_NO_RESTORE=1 emacs -nw`** for the case that rule can't cover: no GUI
  to be secondary to (ssh'd in from another machine, or just after a crash).
  Skips restore *and* save, leaving the snapshot for the next real start.
- **`etty`** opens a tty frame of the *running* Emacs (`emacsclient -nw -a ''`),
  so buffers, kill ring, ghostel terminals and the `e*` bridge are the ones you
  are sitting in. Prefer it over a second `emacs -nw` when an Emacs is up.
- tty frames get the clipboard (OSC 52 — `setSelection` had to be declared,
  `term/tmux.el` skips xterm's probe), `xterm-mouse-mode`, a silent bell, and
  themed `tty-menu-*` faces. ghostel terminals render fine in a tty frame.
- Color is 24-bit here off `COLORTERM`, not `TERM`, so theme hex values render
  exactly through byobu — don't "fix" this by chasing a `*-direct` terminfo.

## Gotchas

- tmux session names can't contain `.`/`:` (silently rewritten to `_`). Set
  session options with `-t "$session"` (no `=` prefix — `=` is for window/pane
  targets and `set-option` rejects it).
- ghostel ≥ 0.39 spawns via a native PTY: send input with `ghostel-send-string`,
  not `process-send-string`.
- byobu's `custom` status indicator runs scripts through `printf` (eats a literal
  `%`) and only sits in one spot — the status line uses direct `#()` scripts.
- projectile caches negative project-root lookups; the `C-t` launchers use
  `my-project-root`, which bypasses that cache and prompts for a folder when none
  is found.
