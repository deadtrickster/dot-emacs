# Assessment

*2026-07-14*

A review of this repository: what it is, the design philosophy it actually
encodes, and where it is weak. Written against `init.el` at 2,227 lines / 74
`use-package` blocks / 55 `my-*` functions / ~15% comment density, plus 14
vendored non-Emacs files (shell, byobu, claude).

---

## 1. The thesis

**This is not an Emacs configuration. It is a development-environment monorepo in
which Emacs is the control plane.**

`my-ensure-shell-integration` (on `after-init-hook`) makes Emacs *install the rest
of the machine*, idempotently:

- appends an Emacs-managed block to `~/.bashrc` that sources `shell/integration.bash`
- symlinks `byobu/{status,.tmux.conf,bin/bb-save-layout}` into `~/.config/byobu/`
- symlinks the `e*` helper scripts onto `PATH` (`~/.local/bin`)
- symlinks the Claude context overlay and registers its `SessionStart` hook in
  `~/.claude/settings.json` (a defensive, idempotent JSON merge)

Clone the repo, launch Emacs once, and the machine is configured. **The editor
owns the environment, not the other way around.** Almost every other design
decision here is downstream of that inversion.

---

## 2. Design principles (as actually encoded in the code)

### 2.1 One file, no framework, no indirection
Everything is `use-package` + `:custom`. There is deliberately **no `custom.el`** —
`custom-file` points at a throwaway temp file specifically so that `M-x customize`
can never write to a tracked file. The config is the single source of truth and is
readable top to bottom. No layers, no module DSL, no abstraction over Emacs.

### 2.2 Built-ins first, packages second
eglot (not lsp-mode), `treesit` (not tree-sitter.el), built-in `editorconfig`, and
session persistence **hand-rolled** on `window-state-get`/`window-state-put`
rather than pulling in desktop.el. Fewer dependencies, closer to upstream, less to
break on an Emacs upgrade.

### 2.3 Every setting carries its WHY — and the WHY is causal
The comments do not describe *what* a setting does; they record *what breaks
without it*. For example: `window-state` references buffers **by name**, so a
ghostel buffer whose name is non-deterministic silently drops out of its pane on
restore — hence `ghostel-buffer-name-function`.

This is the single most valuable property of the repo: it is **institutional
memory encoded in the file** — the paid-for record of every bug already hit. It
compounds. Keep doing it.

### 2.4 The terminal is persistent; Emacs is only a *viewer* onto it
Per-project byobu/tmux sessions (`projectile/<name>`) **outlive Emacs**. Kill the
editor and the shells, dev servers, and REPLs keep running; reopen and it
reattaches. Most configs make a shell buffer a child of Emacs. This makes Emacs a
*client* of a shell that owns itself.

Everything in the terminal stack falls out of that one inversion: `bb`, the `C-t`
prefix map, session restore, and grouped views (`C-x 2`/`C-x 3` → an independent
grouped tmux session sharing the base's windows but with its own active tab and
scrollback).

### 2.5 The AI assistant is a peer, not a plugin
The claude-code-ide.el approach (MCP server, WebSocket, editor panel) was
explicitly **rejected** in favour of small shell scripts + `emacsclient`: zero
daemon, zero idle footprint, works from any shell. It is bidirectional by design:

- **Claude → Emacs:** `eopen`, `esay`, `enotify`, `ecommit`, `esh` (sudo hand-off),
  `etab` (stage a command without running it)
- **Emacs → Claude:** `C-t C-y` (cite region), `C-t C-b` (cite buffer), `ebuffer`,
  `C-t C-f` (open a file Claude referenced), `C-t C-u` (jump to the sudo window)

### 2.6 The machine prepares; the human commits
The most consistent thread in the whole repo:

- `ecommit` never runs `git commit -m` blind — it opens a magit buffer you must
  approve (`C-c C-c`).
- `etab` types a command into a tab and **refuses to press Enter** (input is
  sanitized so it *cannot* self-execute).
- `esh` hands privileged commands to the human because Claude has no password.
- Formatter wrappers **emit their input unchanged on any error** rather than risk
  mangling a buffer; pgindent flatly refuses to format code with unbalanced parens.

Nothing consequential happens without a human in the loop. That is a real
architectural stance, and it is applied uniformly.

---

## 3. Weaknesses and risks

### 3.1 The projectile block is a squat  *(structural)*
Roughly 600 lines of `:init` defuns — the **entire** ghostel/byobu/`C-t` terminal
subsystem — live inside `(use-package projectile …)` purely because they need
projectile at load time. The repo's most important subsystem is hiding inside an
unrelated package's block. It deserves its own top-level section.

### 3.2 Load-order fragility — the bug this config keeps re-learning  *(highest recurrence)*
Two instances in a single day:

- apheleia's `:config` added a `c-ts-mode-hook`, but **session-restore reopened
  files before that hook existed** → pgindent silently dead on restored buffers.
  Fixed by scoping via `apheleia-mode-alist` (resolved at *save* time), not a hook.
- `my-magit-commit` lived in magit's **deferred** `:config`, so `ecommit` failed
  with `void-function` on every fresh Emacs. Fixed by moving it to `:init`.

Both are the same lesson, and it should be written into `AGENTS.md` as a rule:

> **Anything an external caller (emacsclient, a script) depends on must be defined
> eagerly (`:init`, not a deferred `:config`). Anything that must apply to
> session-restored buffers must not hang off a hook that runs later than restore —
> resolve it at use time instead.**

### 3.3 No CI, and the shell scripts are load-bearing  *(highest value gap)*
`shell/integration.bash` is sourced by **every shell you open** — a syntax error
bricks your terminal. The `e*` tools are on `PATH` and run constantly. There is
currently no guard: a 12-file reformat was validated by hand.

A ~10-line CI would be cheap insurance:

```
bash -n <every script>            # parses
shellcheck <every script>         # no new findings
emacs --batch check-parens init.el
```

### 3.4 Machine-specific paths leak into a "portable" repo
e.g. `/home/dead/bin/elp` hardcoded in `eglot-server-programs`. The README promises
"clone it on a fresh machine and launching the editor configures it"; parts quietly
assume *this* machine. (The oriole formatters are better — they discover the repo
via `git rev-parse` and degrade to a no-op passthrough when the toolchain is
absent.)

### 3.5 Emacs is a single point of failure for the whole toolchain
The corpse-socket bug demonstrated the coupling: a hard-killed Emacs left a stale
server socket → `server-start` failed to bind → **no server** → every `e*` tool
dead → you could not even `ecommit` your way out of it. Now fixed
(`server-force-delete` before `server-start`), but the dependency is structural:
the shell tooling assumes a healthy Emacs.

---

## 4. In one line

> **Emacs is the control plane for the entire development environment; everything
> it drives is vendored beside it; every setting records what breaks without it;
> prefer what ships with Emacs; and the human approves anything that matters.**

---

## 5. What to steal from other configs

Surveyed by reading actual source: **Spacemacs, Doom, Prelude, Purcell, Centaur,
Crafted**. Filtered against §2 — no layers, no DSL, no evil, no org workflows, no
ricing. Everything below is small, self-contained, and liftable into one `init.el`.

### 5.0 Where the survey independently converged

Four agents reading six unrelated codebases landed on the same gaps. That
convergence is the strongest signal in this document:

| Gap | Flagged by |
|---|---|
| **No headless full-load test** (`check-parens` is not enough) | Purcell, Centaur, *and* §3.3 |
| **No `so-long` / large-file guard** — a minified or generated file can wedge Emacs | Doom, Centaur, Spacemacs |
| **`ffap-machine-p-known`** — Emacs does a *blocking DNS lookup* on any token that looks like a hostname | Prelude, Spacemacs |
| **`early-init.el` is 6 lines** — GC runs at the stock 800k threshold for all of startup | Doom (benchmarked), Centaur |

### Tier 1 — do these

**T1. A headless full-load smoke test.** *(Purcell `test-startup.sh`; Centaur `ci.yml`)*
The single highest-value item in this document. `check-parens` catches unbalanced
parens and **nothing else** — not a bad `:custom` key, not a typo'd hook, not a
package that vanished. The scripts are worse: `shell/integration.bash` is sourced
by **every shell you open**, so a syntax error bricks your terminal.

```bash
emacs -q --batch --eval '(progn (load (locate-user-emacs-file "early-init.el"))
                                (load (locate-user-emacs-file "init.el")))'
bash -n <every script> && shellcheck <every script>
```
Guard `my-ensure-shell-integration` behind an env var so the batch path doesn't
write to `$HOME`. Add to `AGENTS.md` beside `check-parens`; it is a strict superset.

**T2. `eglot-events-buffer-config '(:size 0 :format short)`.** *(Centaur)*
Best value-per-character found. eglot currently logs **every JSON-RPC message**
into a 2000-event ring buffer of pretty-printed JSON, **per server**. With clangd
on OrioleDB/Postgres that is continuous allocation + GC you pay for and never read.
Also `(eglot-autoshutdown t)`, `(eglot-send-changes-idle-time 0.5)`.

**T3. `emacsclient file:LINE:COL`.** *(Prelude `core/prelude-editor.el:444`)*
You are terminal-centric with `$EDITOR=emacsclient`, and every `rg`/grep/compiler
/stack-trace in a byobu tab prints `path:123:4`. Today `e foo.c:123` opens a file
*literally named* `foo.c:123`. ~20 lines of `:filter-args` advice on
`server-visit-files` fixes it. Belongs in the `server` block; wire into `eopen` too.

**T4. `copy-file-path-with-line`.** *(Spacemacs `funcs.el:791`)*
The other half of T3: `kill-new` the current `path:line:col`. That string is the
canonical thing you paste into a Claude prompt, `git blame -L`, or an `rg`
follow-up. T3 consumes it, this produces it — together they close the loop between
terminal, Emacs, and the assistant. ~8 lines.

**T5. `use-package-enable-imenu-support t`.** *(Centaur `early-init.el:95`)*
One line, and it is the answer to §3.1/"2227 lines is at the edge": `consult-imenu`
(already installed) then indexes **every `use-package` block by package name**.
Framework-grade navigability, zero framework. **Must be set in `early-init.el`** —
before `use-package` is loaded.

**T6. A real `early-init.el`.** *(Doom `early-init.el:31`; Centaur `early-init.el:40`)*
Yours is 6 lines (MELPA only), so **gcmh only takes over *after* init — the entire
package-load phase runs at the stock 800k GC threshold.** Measured on *this* Emacs
32.0.50 (19 heavy libs, warm cache): **0.23–0.29s → 0.19s**.

```elisp
(setq gc-cons-percentage 1.0
      gc-cons-threshold most-positive-fixnum)   ; gcmh takes over after init
;; Fail-safe: if gcmh never loads, DON'T leave the threshold at infinity.
(add-hook 'emacs-startup-hook
          (lambda ()
            (when (= (default-value 'gc-cons-threshold) most-positive-fixnum)
              (setq-default gc-cons-threshold (* 16 1024 1024)
                            gc-cons-percentage 0.1)))
          101)
(setq use-package-enable-imenu-support t        ; T5 -- must precede use-package
      auto-mode-case-fold nil
      frame-inhibit-implied-resize t)
;; Emacs 31+: caches directory-files per load-path entry (~15% of startup).
(when (boundp 'load-path-filter-function)       ; verified bound on 32.0.50
  (setq load-path-filter-function #'load-path-filter-cache-directory-files))
```
Caveat to write into the comment: if Emacs is ever rebuilt `--with-mps` (igc),
`gc-cons-threshold` becomes meaningless and **gcmh becomes dead weight**.

**T7. `so-long` + a large-file guard.** *(Doom; Centaur; Spacemacs)*
You have **none**. A minified blob or a 40k-line generated file wedges you — and
with eglot + treesit attached, a 20 MB file is a multi-second freeze. Doom's
variant is the right one because it keeps the buffer *usable* (font-lock and line
numbers stay on, `read-only` dropped) and predicates on **both** longest-line and
line-count via `buffer-line-statistics` (a cheap C primitive, 29+).

**T8. `(setq ffap-machine-p-known 'reject)`.** *(Prelude; Spacemacs)*
One line. Otherwise `ffap`/`find-file-at-point`/several completion backends will
do a **blocking DNS lookup / ping** on any buffer token shaped like `foo.bar`. A
documented multi-second hang, for free.

### Tier 2 — worth doing

**T9. The sane-defaults block you're missing.** *(Prelude `prelude-editor.el`)*
Verified absent from your `init.el`: `savehist`, `save-place`, `winner-mode`,
`uniquify` (you *will* hit `init.el<2>` in a monorepo), `isearch-lazy-count`,
`tab-always-indent 'complete`, `require-final-newline`,
`kill-do-not-save-duplicates`, `help-window-select`, un-disabling
`narrow-to-region`. All plain variables → all fit your `:custom` style.

Special mention — **you vendor executable scripts**:
```elisp
(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)
```
keeps `shell/bin/*`, `byobu/bin/bb-save-layout`, `claude/hooks/*` `+x` automatically.

**T10. `winner-mode` + a toggling `C-x 1`.** *(Purcell `init-windows.el`)*
`C-x 1` becomes: delete-other-windows, or `winner-undo` if already alone. You can't
lose a layout to a fat-fingered `C-x 1`. **Careful:** you already DWIM `C-x 2`/`C-x
3` inside ghostel buffers — take the other-buffer split *only* as the non-ghostel
branch; don't clobber `my-ghostel-grouped-view`.

**T11. Run-once hooks: `first-input` / `first-file` / `first-buffer`.**
*(Doom `doom-lib.el:424`; Spacemacs `core-hooks.el:48` for the function-advice variant)*
~25 framework-free lines. Hooks that fire once, then nil themselves. They compose
with `use-package` directly — `:hook (my-first-input . savehist-mode)` — with zero
indirection. You eagerly enable a pile of global modes that need not exist before
the first keypress. Two easy-to-miss details: `find-file-hook` fires *after* major
modes (too late), so advise `after-find-file :before`; and use depth `-101`.

**T12. Hook error containment.** *(Doom `doom-lib.el:398`)*
In vanilla Emacs, one broken function in a mode hook **silently kills every
function after it**. ~15 lines of `run-hook-wrapped` reports which hook and which
function died and keeps going. You hand-maintain a lot of hooks; this is permanent
insurance, not a debug tool.

**T13. Per-Emacs-version `package-user-dir`.** *(Purcell `init-elpa.el:24`)*
```elisp
(setq package-user-dir (expand-file-name (format "elpa-%s.%s" emacs-major-version
                                                 emacs-minor-version)
                                         user-emacs-directory))
```
**You rebuild Emacs from source regularly.** A shared `elpa/` across versions is
byte-code-incompatibility hell — you have already been bitten by an Emacs rebuild
this month. Needs a matching `.gitignore` line. Spacemacs's variant
(`core-compilation.el:109`) persists `emacs-version` and purges stale `.elc`/eln on
mismatch — same insurance, also worth it.

**T14. Replace `insert-newline-before-line` with `crux-smart-open-line-above`.**
*(Prelude/crux)* Your `[C-return]` command is a `goto-line`-based reimplementation
that is **buggy on line 1 and under narrowing**. crux's is 5 correct lines and
handles `electric-indent-inhibit` (Python). Lift the *function*, not the package.
Same for `crux-move-beginning-of-line` (`C-a` toggles indentation ↔ column 0) and
`crux-kill-line-backwards`. For duplicate-line, use the **built-in** `duplicate-dwim`
(29+) — built-ins-first.

**T15. An opt-in startup profiler.** *(Spacemacs `core-debug.el:105`)*
~15 lines advising `load`/`require` with a time threshold, enabled by an env var so
it costs nothing when off. Better than `benchmark-init` (a dependency) and better
than `use-package-compute-statistics` (which only sees use-package forms — it misses
the `require` a package does at load time, which is where the seconds actually are).
**Measure before doing any more of §5.** Purcell's `sanityinc/require-times`
(`init-benchmarking.el`) is the same idea with a `tabulated-list-mode` view.

### Tier 3 — measure first

- **Incremental idle pre-warming** *(Doom `doom-emacs.el:942`)* — after 2s idle,
  `require` deferred packages on a 0.75s drip, wrapped in **`while-no-input`** so a
  keypress aborts and re-queues. Turns your `:commands` deferrals from "fast
  startup, slow first `magit-status`" into fast/fast. The `while-no-input` is the
  part hand-rolled versions always miss.
- **`file-name-handler-alist` nil during startup** — the famous one, and it
  **measured marginal (~20–40 ms)** on your build; GC deferral is the real win.
  Take it *only* with restore discipline (Doom merges it back at depth 101 and
  advises `command-line-1`, else `emacs /ssh:host:/file` breaks; Spacemacs's
  `let`-scoped form in `init.el:66` is more robust — it survives an init error).
  Keep `jka-compr-handler` or `.el.gz` loading breaks. A partial implementation is
  worse than none.
- **eglot throughput**: `read-process-output-max` to 1MB (LSP payloads are big),
  `jit-lock-defer-time 0`, `redisplay-skip-fontification-on-input t`.
- **Split into `lisp/init-*.el`** *(Purcell)* — his `init.el` is 203 lines of pure
  `(require 'init-foo)`; the load order *is* the architecture doc. Orthogonal to
  `use-package` (Prelude uses use-package inside its module files). The natural cut
  is `init-terminal.el` (§3.1's 600-line squat — by far the most self-contained).
  **But do T5 (imenu) first** — it may make the split unnecessary.
- **`init-local.el` escape hatch** *(Purcell)* — `(require 'init-local nil t)` at the
  tail: an optional, git-ignored per-machine override. The clean fix for §3.4's
  hardcoded `/home/dead/...` paths.
- **Package archives refreshed only when stale** *(Crafted)* — you only refresh when
  `use-package` itself is missing, so every *other* new package hits "unavailable"
  until you manually refresh. Bounded: one async network hit per day.

### Reject — and why

| Rejected | Why |
|---|---|
| Layer/module systems (Spacemacs `core-configuration-layer.el`, `doom!`, Crafted modules) | The DSL/indirection this config is defined against. `use-package :ensure` already does it. |
| evil, leader keys, hydra/transient-state, `spacebind` | Explicit non-goals. |
| Dashboards, themes, fonts, ASCII banners (`core-spacemacs-buffer.el` — 1711 lines) | Ricing. |
| **`super-save`** (autosave on focus change) | **Actively hostile**: you run apheleia format-on-save — it would reformat buffers behind your back. |
| Spacemacs `core-custom-settings.el`; Crafted's `customize-save-customized` | Reintroduce `custom.el` — directly contradicts your no-custom-file invariant. |
| Spacemacs's `kill-emacs` advice (`C-x C-c` → delete-frame when a server runs) | Would **break `my-restart--save-state`**, which deliberately treats `C-x C-c` as a real exit + snapshot. |
| Purcell's `desktop-save-mode` | You built your own snapshot *because* desktop's restore is unreliable, and you exclude ghostel views. Keep yours. |
| Crafted's `eglot-auto-ensure-all` | Action-at-a-distance: which modes get LSP depends on what's on `PATH`. Your explicit 12-hook list is the no-magic choice. |
| Centaur's `native-comp-jit-compilation nil` | **Its stated justification is false** — it claims packages are AOT-compiled on install, but that requires `package-native-compile t`, which Centaur never sets. As written it silently demotes every package to byte-code. |
| Doom's aggressive UI startup hacks (nulling `mode-line-format`, global `inhibit-redisplay`) | ~50–100 ms for a "my Emacs is blank and I can't tell why" failure mode. Doom itself disables them when debugging. |
| Prelude's `yank-indent-advice` | Fights apheleia and mangles pastes into indentation-sensitive buffers. Prelude needs an escape-list for it — that's the tell. |
| crux / smartparens / undo-tree / expand-region / whole-line-or-region / anzu / … | Package tax. Lift the 4 *functions* (T14); `electric-pair-mode`, `duplicate-dwim`, `expreg` (treesit) and your existing `iedit`/`undo-fu` cover the rest. |

### Verified cargo cult — do NOT copy (checked against *this* Emacs 32.0.50)

- `read-process-output-max` 64kb — **already the default** (65536). No-op.
  *(Bumping to 1MB for eglot is a separate, still-valid tweak.)*
- `load-prefer-newer nil` — already the default; and it's only *correct* in Doom
  because `doom sync` guarantees `.elc` freshness. You have no such step.
- `(delq 'native-compile features)` — only fires when native-comp is broken. Yours works.
- All `w32-*` settings — Windows only.
- Doom's `tty-run-terminal-initialization` deferral — Doom's own comment says
  "REVIEW: may no longer be needed in 29+". **Actively wrong for a terminal-centric
  config.**

### Housekeeping the survey turned up

- **`package-selected-packages` is stale**: it still lists `lsp-mode`, `lsp-ui`,
  `lsp-docker` on an eglot config. Delete or regenerate it.
- `insert-newline-before-line` is buggy (T14).
- `early-init.el` is 6 lines (T6).
