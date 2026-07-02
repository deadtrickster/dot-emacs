## Environment — you are running inside Emacs

You're in a **ghostel** terminal (an in-Emacs libghostty terminal) inside a
**byobu/tmux** session, launched from the user's Emacs. What this means:

- **`$EDITOR` / `$GIT_EDITOR` is `emacsclient`.** A bare `git commit` or
  `git rebase -i` opens a buffer in the user's *running* Emacs (magit
  `git-commit` / `git-rebase` modes) and **blocks until they finish** (`C-c C-c`
  to accept, `C-c C-k` to cancel). Pass `-m` / `-F` / `--no-edit` when you don't
  want an editor.
- **Commit via `ecommit <msg>`, not `git commit -m`.** Stage with `git add`, then
  `ecommit "<message>"` opens a magit commit buffer *pre-filled* with the message
  for the STAGED changes; the user reviews and finishes with `C-c C-c` (or aborts
  with `C-c C-k`). Use `-F <file>` (or stdin) for multi-line messages. Commits
  here are reviewed in magit — don't `-m` them blind.
- **Open files in their Emacs** with `eopen <file>` (non-blocking) — use it to
  surface a file instead of dumping it into the terminal. (`eopen`/`esay` are
  standalone scripts on PATH and pre-approved; the bare `open`/`e`/`say` are
  interactive-shell-only functions you don't have and `open` would hit
  `/usr/bin/open` — always use the `e`-prefixed scripts.)
- **"Write X and show me" → write it, then `eopen X`.** When asked to create or
  edit a file *and* show it ("write README.md and show me", "open it"), do the
  write, then `eopen <file>` so it pops up in their Emacs. The buffer
  auto-reverts, so further edits to the file appear live there — prefer this over
  pasting file contents into the terminal.
- **"this / that / the buffer" → run `ebuffer`, then `Read` what it prints.** When
  the user refers to a buffer deictically ("what do you think about that buffer?",
  "this buffer", "the file I'm in"), they mean the one they last toggled from.
  `ebuffer` prints a path -- the real file if saved & unmodified, else a temp
  snapshot capturing unsaved edits / non-file buffers (scratch, REPL, output) --
  which you then `Read`. If they *name* a buffer, run `ebuffer <name>`. To pick a
  *specific* one from a list, they press `C-t C-b` in Emacs (a native picker that
  sends you the reference) — don't try to pop a selector yourself. Never make them
  paste a whole buffer — fetch it.
- **`sudo` commands → `esh`, never run them yourself.** You have no password, so
  any command needing `sudo` will just fail. Hand it off with this three-step
  dance (ONLY for privileged/`sudo` commands — everything else you run normally):
  1. `esh "sudo apt install ripgrep"` opens a *dedicated* `sudo` byobu window
     (the user's `shell` tab stays untouched), runs the command there (the
     password prompt appears), raises a notice, and prints an `id=<N>`.
  2. Immediately run **`esh -w <id>` in the BACKGROUND** (`run_in_background`). It
     blocks until the command finishes and returns `EXIT=<code>` plus the captured
     output — that completion is the signal that wakes you back up. Tell the user
     to hit `C-t C-u` (jumps to the `sudo` window) and enter their password.
  3. When `esh -w` returns, report the exit code / output, then **`esh -k <id>`**
     to close the sudo window and clean up. You close it — never the user, and it
     never auto-closes.
- **`esay <msg>`** posts a *transient* message into their Emacs echo area.
- **`enotify <msg>` when you finish and are handing back** — a long/background
  task (build, test run, big edit) *or* simply the end of your turn when they may
  have switched away while you worked. It raises a *persistent* notice (frame
  title + mode-line flag + an echo line) so they know to switch back to you; it
  clears when they return to a terminal. Use `enotify` for "come back / done"
  signals and `esay` for quick transient ones.
- **The user navigates with `C-t`** (a prefix): `C-t C-c` claude, `C-t C-g` git,
  `C-t C-s` shell, and `C-t C-t` toggles between their code buffer and this
  terminal — so they hop away and back; you share the one byobu session. They
  can also `C-t C-f` to open any file you name in your output (Write/Edit/Read
  etc.) — so just reference files by path; no need to paste them.
- `bb` (re)attaches this project's byobu session from any shell; the working
  directory is tracked back into Emacs via OSC 7.
