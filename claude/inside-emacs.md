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
- **"put this / that command in the `<tab>` tab" → `etab <tab> -F <file>`.** When
  they ask you to *stage* a command in a byobu tab for them to run (e.g. "put that
  command into the test tab for me") — rather than running it yourself — write the
  command to a scratchpad file and run `etab <tab> -F <file>` (a lone command, so
  `Bash(etab:*)` doesn't trip; also avoids quoting a big string). It **types the
  text into that tab and stops — no Enter** (sanitized so it can't execute itself:
  CR/ESC/control stripped, bracketed paste), so they switch there (`C-t <tab>`),
  review, and press Enter to run. Short one-liners can go inline: `etab test "…"`.
  This is the inverse of `esh` (which runs a sudo command); `etab` never runs
  anything. The `<tab>` is the byobu window name they said (`test`, `shell`, …).
- **The user navigates with `C-t`** (a prefix): `C-t C-c` claude, `C-t C-g` git,
  `C-t C-s` shell, and `C-t C-t` toggles between their code buffer and this
  terminal — so they hop away and back; you share the one byobu session. They
  can also `C-t C-f` to open any file/line you reference in your output — so just
  reference files by path; no need to paste them.
- **Point at a line as `path:line`, never as prose.** When you refer to a specific
  location — "the leftover blank lines", "the missing return", "this hunk" — write
  it as `src/io.c:1320`, because ghostel auto-linkifies that shape: the user clicks
  it (or `RET`/`C-t C-f`) and lands on that line in their Emacs. Prose like "line
  1320 of io.c" is dead text they navigate by hand; a `path:line` is a click.
  - **The path must resolve to a file that EXISTS from your current directory** —
    ghostel only linkifies a `path:line` when `file-exists-p` succeeds relative to
    the terminal's `pwd`. So use exactly the path you'd `cat` from where you are: a
    relative path from `pwd` (`src/io.c:1320`, not a bare `io.c:1320` unless `pwd`
    is that file's own directory), or an absolute path. A repo-root-relative path
    only works when `pwd` is the repo root. When unsure, prefer the absolute path.
  - Give the real current-file line number, and prefer several concrete `path:line`
    refs over describing a region vaguely.
  - A column (`path:line:col`) is understood too but usually **not worth adding** —
    `line` is what the user wants, and a column that's off (tabs, 0- vs 1-indexed,
    a stale count) sends them to the wrong spot. Add `:col` only when you're
    genuinely pointing at a character position and are sure of it.
- `bb` (re)attaches this project's byobu session from any shell; the working
  directory is tracked back into Emacs via OSC 7.
