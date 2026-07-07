# Development environment

One repository holding a development setup: editor configuration plus the shell,
terminal-multiplexer, and AI-assistant integration it drives. Cloning it and
launching the editor once configures the machine. Everything is kept here, so
the same setup runs on any machine.

## Per-project terminals

Each project has a persistent terminal session with tabs (default: `claude`,
`shell`, `git`, `test`). You can add named tabs and close them, and the tab
layout is saved per project — a project comes back with the tabs you left it
with. The session runs independently of the editor — closing the editor leaves
it running; reopening reattaches it. Several projects can be open at once, each
with its own session.

### Why a session per project

- **State persists.** A project's shells keep their working directories,
  scrollback, and running processes — dev server, REPL, test watcher, log tail.
  Switching projects doesn't tear any of that down or rebuild it.
- **It outlives the editor.** The session lives in the terminal multiplexer, not
  the editor, so an editor restart or crash — or an SSH drop, or closing the
  laptop — leaves the processes running. You reattach and they're still there.
- **One place per project.** Every terminal for a project sits under one named
  session, instead of a flat pile of shells you have to sort out by hand.
- **Reachable from anywhere.** The editor, a standalone terminal, and an SSH
  login all attach the same session — one environment per project, not several
  drifting copies.
- **Predictable.** Each project comes up with the same tabs, so navigation is
  the same everywhere.

### Several tabs at once

Split a terminal pane — `C-x 3` beside, `C-x 2` below — to open another
independent view of the same session on a *different* tab, with its own active
tab and scrollback. So you can watch several tabs side by side (e.g. a few live
stat or log windows) instead of flipping between them. Close a view like any
buffer (`C-x k`); one command collapses all the extra views back to a single
terminal. The views are throwaway — the session itself is never affected.

## Navigation (`C-t`)

| Key | Action |
|---|---|
| `C-t C-t` | Toggle between the code buffer and this project's terminal. |
| `C-t C-c` / `C-t C-g` / `C-t C-s` | Go to the `claude` / `git` / `shell` tab. |
| `C-t` then a letter | Go to the tab starting with that letter (directly if unique, otherwise a filtered list). |
| `C-t C-n` | Create a tab (prompts for a name). |
| `C-t C-k` | Close a tab (defaults to the current one, confirms first). |

`Ctrl`+arrow keys move between editor panes, including inside terminals.

## `bb`

Running `bb` in any shell attaches the current project's session — the same one
the editor uses. It derives the project from the working directory, so it works
from a separate terminal, an SSH session, or a subdirectory.

## Editor as `$EDITOR`

In a project terminal, `git commit` and `git rebase -i` open in the running
editor. `e <file>` and `open <file>` open files in it.

## Shell

The prompt shows the current branch and working-tree state (modified, staged,
stashed, untracked, ahead/behind upstream). The terminal tracks the working
directory.

## Languages

Completion, go-to-definition, diagnostics, and format-on-save are set up for:
Rust, Go, Common Lisp, TypeScript/React (JSX, TSX), JavaScript, Python, C/C++,
CMake, SQL, Elixir, Erlang, CSS/Tailwind, HTML, and Makefiles.

Runtimes are managed per project with **mise** — a `.tool-versions` / `mise.toml`
in the repo pins its Node/Erlang/Elixir/etc. version, which then switches
automatically on entry. Per-project environment variables come from **direnv**:
an `.envrc` in the repo (run `direnv allow` once) loads on entry and unloads on
exit, and the editor and the project's terminals see the same environment.

## Restart

One command stops the terminals and editor, restarts, and restores the open
files, pane layout, window size, and each project's terminal.

## AI assistant

When the Claude CLI runs in a project terminal, it is told it is inside the
editor: it commits through the editor, can open files, uses the same navigation,
and — instead of running something itself — can stage a command in a tab for you
to review and run, or hand a command needing a password to a dedicated window.

## New machine

Cloning the repo and launching the editor once installs the shell integration,
terminal configuration, and assistant overlay.

## Git workflow

- New features start on a clean branch off the trunk; the tree is committed
  before starting.
- Intermediate steps are committed as work proceeds.
- The editor, shell, terminal, and assistant config are all kept in this repo.
