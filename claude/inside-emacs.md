## Environment — you are running inside Emacs

You're in a **ghostel** terminal (an in-Emacs libghostty terminal) inside a
**byobu/tmux** session, launched from the user's Emacs. What this means:

- **`$EDITOR` / `$GIT_EDITOR` is `emacsclient`.** A bare `git commit` or
  `git rebase -i` opens a buffer in the user's *running* Emacs (magit
  `git-commit` / `git-rebase` modes) and **blocks until they finish** (`C-c C-c`
  to accept, `C-c C-k` to cancel). Pass `-m` / `-F` / `--no-edit` when you don't
  want an editor.
- **Open files in their Emacs** with `e <file>` / `open <file>` (non-blocking) —
  use this to surface a file instead of dumping it into the terminal.
- **`say <msg>`** posts a message into Emacs.
- **The user navigates with `C-t`** (a prefix): `C-t C-c` claude, `C-t C-g` git,
  `C-t C-s` shell, and `C-t C-t` toggles between their code buffer and this
  terminal — so they hop away and back; you share the one byobu session.
- `bb` (re)attaches this project's byobu session from any shell; the working
  directory is tracked back into Emacs via OSC 7.
