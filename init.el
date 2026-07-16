;;; -*- lexical-binding: t; -*-

;; Bootstrap: MELPA is registered in early-init.el (before Emacs auto-runs
;; `package-initialize'); here we just ensure use-package exists before we start
;; declaring packages.  Everything else installs via :ensure on first run.
(require 'package)
;; Only touch the network on a truly fresh install (use-package missing).
;; use-package's own :ensure refreshes on demand for any package added later.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package custom
  :ensure nil
  :no-require t
  :config
  ;; init.el is the single source of truth: every setting is declared here via
  ;; use-package `:custom' / `:custom-face'.  Point `custom-file' at a throwaway
  ;; temp so interactive `M-x customize' still works in-session but never writes
  ;; a tracked `custom.el' that would drift out of sync with init.el.
  (setq custom-file (make-temp-file "emacs-custom-")))

(use-package emacs
  :init
  (defvar powerline-selected-window (frame-selected-window)
    "Selected window.")
  (defun powerline-selected-window-active ()
    "Return whether the current window is active."
    (eq powerline-selected-window (selected-window)))
  (defun powerline-set-selected-window (frame)
    "Set the variable `powerline-selected-window' appropriately."
    (when (not (minibuffer-window-active-p (frame-selected-window frame)))
      (setq powerline-selected-window (frame-selected-window frame))
      (force-mode-line-update)))
  (defun powerline-unset-selected-window ()
    "Unset the variable `powerline-selected-window' and update the mode line."
    (setq powerline-selected-window nil)
    (force-mode-line-update))
  ;; Function to reuse a non-focused window
  (defun my-reuse-non-focused-window (buffer-or-name alist)
    "Reuse a non-focused window if available."
    (let* ((current-window (selected-window))
           (windows (window-list nil nil))
           (non-focused-windows (remove current-window windows)))
      (when non-focused-windows
        (let ((target-window (car non-focused-windows)))
          (select-window target-window)
          (switch-to-buffer buffer-or-name)
          target-window))))
  (defun indent-whole-buffer ()
    "Indent whole buffer."
    (interactive)
    (delete-trailing-whitespace)
    (indent-region (point-min) (point-max) nil)
    (untabify (point-min) (point-max)))
  (defun insert-newline-before-line ()
    "Open an indented line above the current one, leaving point on it.
Bound to \\`C-<return>'.

Was a `goto-line'-based reimplementation, which was wrong twice over:
`line-number-at-pos' counts from the start of the ACCESSIBLE portion while
`goto-line' takes an ABSOLUTE line number, so under narrowing it jumped somewhere
else entirely; and `goto-line' pushes the mark, so the command clobbered your mark
ring on every use.  Neither line numbers nor a special case for line 1 are needed
-- just move to the start of the line and insert."
    (interactive)
    (move-beginning-of-line nil)
    ;; Plain `insert', not `newline-and-indent': in modes that set
    ;; `electric-indent-inhibit' (python-mode) the latter would re-indent the line
    ;; we are pushing down.
    (insert "\n")
    (forward-line -1)
    (indent-according-to-mode))
  (defun my-kill-line-no-save (&optional arg)
    "Like \\[kill-line], but DELETE the text -- never save it to the kill ring
or the system clipboard.  Bound to \\`C-k' here because this config forwards the
kill ring to the clipboard (see the `select' block), so a stray `C-k' otherwise
clobbers whatever you had copied.

Reuses `kill-line' verbatim -- same point-to-EOL / whole-line / prefix-count /
visual-line semantics -- but shadows the kill ring with a throwaway copy and
disables the clipboard hook for the duration, so nothing escapes.  Yank still
holds whatever it held before."
    (interactive "P")
    (let ((kill-ring kill-ring)
          (kill-ring-yank-pointer kill-ring-yank-pointer)
          (interprogram-cut-function nil))
      (kill-line arg)))
  (defun rename-file-and-buffer ()
    "Rename the current buffer and file it is visiting."
    (interactive)
    (let ((filename (buffer-file-name)))
      (if (not (and filename (file-exists-p filename)))
          (message "Buffer is not visiting a file!")
        (let ((new-name (read-file-name "New name: " filename)))
          (cond
           ((vc-backend filename) (vc-rename-file filename new-name))
           (t
            (rename-file filename new-name t)
            (set-visited-file-name new-name t t)))))))
  (defun ignore-error-wrapper (fn)
    "Wrap a function with `ignore-errors'."
    (let ((fn fn))
      (lambda ()
        (interactive)
        (ignore-errors
          (funcall fn)))))
  :custom
  (mode-line-percent-position nil)
  (create-lockfiles nil)
  (make-backup-files nil)
  (version-control t)
  (backup-by-copying t)
  (delete-old-versions t)
  (kept-old-versions 5)
  (kept-new-versions 5)
  (backup-directory-alist (list (cons "." "/home/dead/.emacs.d/backups/")))
  (tramp-backup-directory-alist backup-directory-alist)
  (auto-save-default t)
  (auto-save-include-big-deletions t)
  (auto-save-list-file-prefix "/home/dead/.emacs.d/autosave/")
  (tramp-auto-save-directory "/home/dead/.emacs.d/tramp-autosave/")
  (auto-save-file-name-transforms
   (list (list "\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
               (concat auto-save-list-file-prefix "tramp-\\2") t)
         (list ".*" auto-save-list-file-prefix t)))
  (indent-tabs-mode nil)
  (tab-width 4)                 ; a literal TAB is 4 columns everywhere
  (native-comp-async-report-warnings-errors 'silent)
  ;; (split-window-preferred-function nil) ; Disable automatic window splitting
  ;; (delete-window-preferred-function nil) ; Disable automatic window deletion
  :config
  ;; Uniform 4-space indent step.  The code modes (js, css, sh, python, c, ts,
  ;; lisp) already default to 4; these default to 2, so bump them.  Leave
  ;; whitespace-sensitive formats like YAML at their own convention.
  (setq-default sgml-basic-offset 4      ; html / sgml / mhtml
                nxml-child-indent 4      ; xml
                nxml-attribute-indent 4)
  ;; deeper-blue is enabled via `custom-enabled-themes' during init, and a theme
  ;; clobbers face overrides applied before it (so `:custom-face' here lost).
  ;; Re-apply our mode-line tweaks after startup and on any theme (re-)enable.
  (defun my-tune-mode-line-faces (&rest _)
    "Calm the mode-line over deeper-blue: dark slate bar, white buffer name,
dimmed envrc `none' (inactive windows dimmer than active)."
    (set-face-attribute 'mode-line nil :background "#2a2f3d" :foreground "#a9b1c2")
    (when (facep 'mode-line-active)
      (set-face-attribute 'mode-line-active nil :background "#2a2f3d" :foreground "#a9b1c2"))
    (set-face-attribute 'mode-line-inactive nil :background "#1e212b" :foreground "#5e6573")
    ;; buffer name: same foreground as the byobu active window name (was blue4)
    (set-face-attribute 'mode-line-buffer-id nil :foreground "#e3e7ee" :weight 'bold)
    ;; envrc "none": drop the bright `warning' yellow inheritance
    (when (facep 'envrc-mode-line-none-face)
      (set-face-attribute 'envrc-mode-line-none-face nil :inherit nil
                          :foreground "#75808f" :weight 'normal)))
  (add-hook 'emacs-startup-hook #'my-tune-mode-line-faces)
  (add-hook 'enable-theme-functions #'my-tune-mode-line-faces)
  ;; C-t is a prefix map (set up in the `projectile' block): C-t C-t = byobu
  ;; terminal, C-t C-c = claude.  Each toggles, so the same chord returns you.
  (global-set-key (kbd "<home>") 'beginning-of-line)
  (global-set-key (kbd "<end>") 'end-of-line)
  (global-set-key "\C-cc" 'comment-or-uncomment-region)
  (global-set-key [f2] 'rename-file-and-buffer)
  (global-set-key [f12] 'indent-whole-buffer)
  (global-set-key [f11] 'delete-trailing-whitespace)
  (global-set-key "\C-d" 'dired-jump)
  (global-set-key [C-return] 'insert-newline-before-line)
  (global-set-key "\C-k" #'my-kill-line-no-save)  ; delete-to-EOL, never clobbers the clipboard
  (global-set-key (kbd "C-x b") #'ido-switch-buffer)
  (add-to-list 'auto-mode-alist '("\\(/\\|\\`\\)[Mm]akefile" . makefile-gmake-mode))
  (advice-add 'view-echo-area-messages
              :filter-return (lambda (win) (select-window win :mark-for-redisplay)))
  (add-hook 'window-selection-change-functions 'powerline-set-selected-window)
  (setq-default mode-line-buffer-identification
                '(:eval (if (powerline-selected-window-active)
                            active-buffer-id
                          inactive-buffer-id)))
  (setq mode-line-modes
        (let ((recursive-edit-help-echo "Recursive edit, type M-C-c to get out"))
          (list (propertize "%[" 'help-echo recursive-edit-help-echo)
                `(:propertize ("" mode-name)
                              help-echo "Major mode\n\
mouse-1: Display major mode menu\n\
mouse-2: Show help for major mode\n\
mouse-3: Toggle minor modes"
                              mouse-face mode-line-highlight
                              local-map ,mode-line-major-mode-keymap)
                '("" mode-line-process)
                `(:propertize ("" minor-mode-alist)
                              mouse-face mode-line-highlight
                              help-echo "Minor mode\n\
mouse-1: Display minor mode menu\n\
mouse-2: Show help for minor mode\n\
mouse-3: Toggle minor modes"
                              local-map ,mode-line-minor-mode-keymap)
                (propertize "%n" 'help-echo "mouse-2: Remove narrowing from buffer"
                            'mouse-face 'mode-line-highlight
                            'local-map (make-mode-line-mouse-map
                                        'mouse-2 #'mode-line-widen))
                (propertize "%]" 'help-echo recursive-edit-help-echo)
                " ")))
  (setf active-buffer-id
        '(#("%12b" 0 4
            (face mode-line-buffer-id help-echo "Buffer name
mouse-1: Previous buffer
mouse-3: Next buffer" mouse-face mode-line-highlight local-map
                  (keymap
                   (header-line keymap
                                (mouse-3 . mode-line-next-buffer)
                                (down-mouse-3 . ignore)
                                (mouse-1 . mode-line-previous-buffer)
                                (down-mouse-1 . ignore))
                   (mode-line keymap
                              (mouse-3 . mode-line-next-buffer)
                              (mouse-1 . mode-line-previous-buffer)))))))
  (setf inactive-buffer-id
        '(#("%12b" 0 4
            (face mode-line-inactive help-echo "Buffer name
mouse-1: Previous buffer
mouse-3: Next buffer" mouse-face mode-line-highlight local-map
                  (keymap
                   (header-line keymap
                                (mouse-3 . mode-line-next-buffer)
                                (down-mouse-3 . ignore)
                                (mouse-1 . mode-line-previous-buffer)
                                (down-mouse-1 . ignore))
                   (mode-line keymap
                              (mouse-3 . mode-line-next-buffer)
                              (mouse-1 . mode-line-previous-buffer)))))))
  ;; Configure display-buffer to reuse non-focused windows for transient buffers
  (setq display-buffer-alist
        '(( "\\*\\(magit: .*\\|transient\\|help\\|Help\\|Completions\\|Warnings\\|Backtrace\\|Flymake\\|eglot\\).*"
            (display-buffer-reuse-window my-reuse-non-focused-window)
            (inhibit-same-window . t)
            (reusable-frames . nil))
          (".*"
            (display-buffer-same-window))))
  (setq my-unignored-buffers '("*Messages*" "*scratch*"))
  ;; Ensure minibuffer is not used for completions
  (setq completion-auto-select nil)
  (defun my-ido-ignore-func (name)
    "Ignore all non-user buffers except those in `my-unignored-buffers'."
    (and (string-match-p "^*" name)
         (not (member name my-unignored-buffers))))
  (setq ido-ignore-buffers '("\\` " "\\*"))
  (setq-default indent-tabs-mode nil)
  ;; Erlang mode ships inside the Erlang/OTP install; load it only when present
  ;; (version-independent path) so a machine without Erlang still starts cleanly.
  (let ((erlang-tools (car (file-expand-wildcards
                            "/usr/lib/erlang/lib/tools-*/emacs"))))
    (when erlang-tools
      (add-to-list 'load-path erlang-tools)
      (setq erlang-root-dir "/usr/lib/erlang")
      (add-to-list 'exec-path "/usr/lib/erlang/bin")
      (require 'erlang-start nil t))))

(use-package ansi-color
  :ensure nil
  :custom
  (ansi-color-names-vector
   [("black" . "#555753")
    ("#CC0000" . "#EF2929")
    ("#4E9A06" . "#8AE234")
    ("#C4A000" . "#FCE94F")
    ("#3465A4" . "#739FCF")
    ("#75507B" . "#AD7FA8")
    ("#06989A" . "#34E2E2")
    ("#D3D7CF" . "#EEEEEC")])
  :config
  (defun display-ansi-colors ()
    (interactive)
    (ansi-color-apply-on-region (point-min) (point-max))))

(use-package auth-source
  :ensure nil
  :custom
  (auth-source-save-behavior nil))

(use-package autorevert
  :ensure nil
  :custom
  (auto-revert-avoid-polling t)
  (global-auto-revert-mode t))

(use-package simple
  :ensure nil
  :custom
  (blink-cursor-mode nil)
  ;; Flash the frame instead of the audible bell (KDE now plays the system beep
  ;; on every C-g / quit, which the old X setup swallowed).
  (visible-bell t)
  (delete-selection-mode t)
  (column-number-mode t)
  ;; Show position as `line:column' (e.g. 12:5) instead of the default `(12,5)'.
  (mode-line-position-column-line-format '(" %l:%c"))
  (truncate-lines t)
  ;; Preserve an external clipboard value into the kill-ring before a kill
  ;; overwrites it (clipboard hygiene; pairs with the `select' block).
  (save-interprogram-paste-before-kill t))

(use-package cus-edit
  :ensure nil
  :custom
  (custom-enabled-themes '(deeper-blue)))

(use-package dired
  :ensure nil
  :custom
  (dired-kill-when-opening-new-dired-buffer t))

;; Git status in dired, in git's own two columns.
;;
;; Deliberately NOT `diff-hl-dired-mode' (which we could have had for one line,
;; diff-hl already being installed): it goes through VC's generic `dir-status-files',
;; and the git backend collapses staged and unstaged into a single `edited' state --
;; so a file you have staged and a file you have not look identical.  That is the one
;; distinction worth having.  `git status --porcelain' reports it natively as XY:
;; X = the index (staged), Y = the worktree (unstaged).  So read that instead.
;;
;;   M_  staged            _M  unstaged         MM  staged, then edited again
;;   A_  new, staged       ??  untracked        !!  ignored        UU  conflict
;;
;; Rendered as an overlay just left of the filename -- no buffer text is touched, so
;; dired's own parsing, marks and `dired-subtree' are unaffected, and a revert (`g')
;; recomputes everything.  One `git status' per listing.
(use-package emacs
  :ensure nil
  :init
  (defvar my-dired-git-show-ignored t
    "Whether the dired git column marks ignored files (`!!').")

  ;; Don't invent colours -- ASK GIT.  `git config --get-color' returns the exact
  ;; SGR escape git would print for a slot, honouring the user's `color.status.*'
  ;; (and git's own defaults when unset: added=green, changed/untracked=red).  We
  ;; translate that escape through Emacs's `ansi-color-*' faces, which ARE the
  ;; terminal palette -- so the column matches what `git status' looks like in the
  ;; byobu tab next door, down to the shade (ansi red is red3, not the red1 an
  ;; eyeballed face would pick), and it keeps matching if the git config changes.
  (defconst my-dired-git--ansi-faces
    '((30 . ansi-color-black)   (31 . ansi-color-red)
      (32 . ansi-color-green)   (33 . ansi-color-yellow)
      (34 . ansi-color-blue)    (35 . ansi-color-magenta)
      (36 . ansi-color-cyan)    (37 . ansi-color-white)
      (90 . ansi-color-bright-black)   (91 . ansi-color-bright-red)
      (92 . ansi-color-bright-green)   (93 . ansi-color-bright-yellow)
      (94 . ansi-color-bright-blue)    (95 . ansi-color-bright-magenta)
      (96 . ansi-color-bright-cyan)    (97 . ansi-color-bright-white))
    "SGR foreground code -> the Emacs face carrying that terminal colour.")

  (defvar my-dired-git--faces nil
    "Cache of slot -> face plist, as answered by `git config --get-color'.
Reset with \\[my-dired-git-refresh-faces] after changing your git colour config.")

  (defun my-dired-git--face (slot default)
    "The face plist git would use for SLOT (a `color.status.<slot>' name)."
    (require 'ansi-color)
    (or (cdr (assoc slot my-dired-git--faces))
        (let ((escape (with-temp-buffer
                        (when (eq 0 (ignore-errors
                                      (process-file "git" nil t nil "config" "--get-color"
                                                    (concat "color.status." slot)
                                                    default)))
                          (buffer-string))))
              (spec nil))
          (dolist (code (and escape
                             (split-string
                              (string-trim (or (car (split-string escape "m" t)) "")
                                           "\e\\[")
                              ";" t)))
            (let* ((n (string-to-number code))
                   (face (cdr (assq n my-dired-git--ansi-faces))))
              (cond
               (face (setq spec (plist-put spec :foreground
                                           (face-foreground face nil t))))
               ;; 40-47 are the same colours, as a background.
               ((and (>= n 40) (<= n 47))
                (when-let* ((bg (cdr (assq (- n 10) my-dired-git--ansi-faces))))
                  (setq spec (plist-put spec :background (face-foreground bg nil t)))))
               ((= n 1) (setq spec (plist-put spec :weight 'bold)))
               ((= n 2) (setq spec (plist-put spec :weight 'light)))
               ((= n 4) (setq spec (plist-put spec :underline t))))))
          (push (cons slot spec) my-dired-git--faces)
          spec)))

  (defun my-dired-git-refresh-faces ()
    "Re-read the git colour config (after editing `color.status.*')."
    (interactive)
    (setq my-dired-git--faces nil))

  (defvar-local my-dired-git--overlays nil
    "Overlays this buffer's git column is made of, so a refresh can clear them.")

  (defvar-local my-dired-git--proc nil
    "In-flight `git status' for this dired buffer, so a revert can cancel it.")

  (defun my-dired-git--merge (a b)
    "Merge two XY status codes for a directory rollup.
Same char wins, a space loses to a real one, and genuinely different states
collapse to `*' -- \"something in here, more than one kind of something\"."
    (if (null a)
        b
      (mapconcat (lambda (i)
                   (let ((x (aref a i)) (y (aref b i)))
                     (cond ((eq x y) (string x))
                           ((eq x ?\s) (string y))
                           ((eq y ?\s) (string x))
                           (t "*"))))
                 '(0 1) "")))

  (defun my-dired-git--parse (output root)
    "Parse porcelain-v1 -z OUTPUT into a map of absolute path -> XY code.
Directories get the merged state of everything beneath them, so a collapsed subdir
still tells you there is something in there."
    (let ((table (make-hash-table :test 'equal))
          (fields (split-string output "\0" t)))
      (while fields
        (let* ((field (pop fields))
               (xy (substring field 0 2))
               ;; porcelain v1 is "XY PATH"; paths are repo-root-relative.
               (path (expand-file-name (directory-file-name (substring field 3))
                                       root)))
          ;; A rename/copy is followed by its ORIGINAL path as its own NUL field.
          ;; Drop it, or it gets parsed as the next status entry.
          (when (memq (aref xy 0) '(?R ?C))
            (pop fields))
          (puthash path xy table)
          ;; Roll the state up into every parent directory, stopping at root.
          (let ((parent (file-name-directory path))
                (stop (file-name-as-directory (expand-file-name root))))
            (while (and parent (string-prefix-p stop parent)
                        (not (equal parent stop)))
              (let ((dir (directory-file-name parent)))
                (puthash dir (my-dired-git--merge (gethash dir table) xy) table)
                (setq parent (file-name-directory dir)))))))
      table))

  (defun my-dired-git--render (xy)
    "Propertize the XY code for display, or return blanks to keep columns aligned."
    (let ((s (concat xy " ")))
      (cond
       ;; git prints both chars of ?? in one colour, so we do too.
       ((equal xy "??") (propertize s 'face (my-dired-git--face "untracked" "red")))
       ;; ...but NOT `!!'.  git paints ignored the same red as unstaged changes, and
       ;; in ~/.emacs.d (elpa, eln-cache, session files -- nearly everything) that is
       ;; a carpet of alarm-red over files you have already decided not to care about.
       ;; Red carries meaning here ("not staged"); spending it on "ignored, as
       ;; intended" devalues it.
       ;;
       ;; It needs an EXPLICIT quiet face, though -- leaving it unpropertized is not
       ;; "no colour", it inherits the dired LINE's face, and dired paints directories
       ;; in bold `dired-directory' blue.  That lit every ignored folder up instead of
       ;; playing it down.  `shadow' overrides the line face and recedes.
       ((equal xy "!!") (propertize s 'face 'shadow))
       ((string-match-p "U" xy) (propertize s 'face (my-dired-git--face "unmerged" "red")))
       (t
        ;; The whole point: colour the two columns SEPARATELY, exactly as `git status
        ;; --short' does -- so "MM" reads at a glance as green-then-red: staged, and
        ;; then modified AGAIN since.  Green/red here is git's index-vs-worktree
        ;; convention ("Changes to be committed" vs "Changes not staged"), not a
        ;; good/bad signal: a red M means "not staged yet", not "error".
        (concat (propertize (substring xy 0 1) 'face (my-dired-git--face "added" "green"))
                (propertize (substring xy 1 2) 'face (my-dired-git--face "changed" "red"))
                " ")))))

  (defun my-dired-git--draw (table)
    "Hang the XY overlays off every file line in the current dired buffer."
    (mapc #'delete-overlay my-dired-git--overlays)
    (setq my-dired-git--overlays nil)
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (when-let* ((file (dired-get-filename nil t))
                    (base (file-name-nondirectory file))
                    ((not (member base '("." ".."))))
                    (pos (dired-move-to-filename)))
          (let ((ov (make-overlay pos pos))
                (xy (gethash (directory-file-name (expand-file-name file)) table)))
            ;; Clean files get three spaces rather than nothing, so the filename
            ;; column sits in the same place whether or not a file has any status.
            ;; NB: no `evaporate' -- these overlays are empty by construction (a
            ;; pure `before-string' marker), and an evaporating overlay is deleted
            ;; the instant it is empty, which silently removed all of them.
            (overlay-put ov 'before-string
                         (if xy (my-dired-git--render xy) "   "))
            (push ov my-dired-git--overlays)))
        (forward-line 1))))

  (defun my-dired-git-annotate ()
    "Annotate this dired listing with `git status', ASYNCHRONOUSLY.

Async is not a nicety here.  `git status' on the 51-submodule serenedb takes ~0.85s
-- git has to walk every submodule to decide if it is dirty -- and dired reverts on
every `g', every file operation, and every window switch back.  Running that inline
on `dired-after-readin-hook' would stall redisplay for the better part of a second
each time.  So the listing draws immediately and the column lands a moment later."
    (when (derived-mode-p 'dired-mode)
      ;; A revert supersedes an in-flight query: drop it, or a slow answer for the
      ;; old listing arrives late and paints stale state over the new one.
      (when (process-live-p my-dired-git--proc)
        (delete-process my-dired-git--proc))
      (when-let* ((root (locate-dominating-file default-directory ".git"))
                  (dired-buf (current-buffer))
                  (out (generate-new-buffer " *dired-git-status*" t)))
        (setq my-dired-git--proc
              (ignore-errors
                (make-process
                 :name "dired-git-status"
                 :buffer out
                 :noquery t
                 :connection-type 'pipe
                 :command (append
                           '("git" "status" "--porcelain" "-z")
                           (if my-dired-git-show-ignored
                               ;; `traditional' collapses a wholly-ignored directory
                               ;; to ONE entry -- never enumerate elpa/, or a
                               ;; 12k-file build/, just to draw a column.
                               '("--ignored=traditional")
                             '("--ignored=no")))
                 :sentinel
                 (lambda (proc _event)
                   (unless (process-live-p proc)
                     (let ((output (with-current-buffer out (buffer-string))))
                       (kill-buffer out)
                       (when (and (buffer-live-p dired-buf)
                                  (eq (process-exit-status proc) 0))
                         (with-current-buffer dired-buf
                           (with-silent-modifications
                             (my-dired-git--draw
                              (my-dired-git--parse output root)))))))))))
        ;; make-process failed (no git on PATH): don't leak the output buffer.
        (unless my-dired-git--proc
          (kill-buffer out)))))
  :hook (dired-after-readin . my-dired-git-annotate))

(use-package display-line-numbers
  :ensure nil
  :custom
  (display-line-numbers-grow-only t)
  (display-line-numbers-widen t)
  (display-line-numbers-width 2)
  (display-line-numbers-width-start t)
  (global-display-line-numbers-mode t)
  :config
  (dolist (mode '(org-mode-hook
                  term-mode-hook
                  shell-mode-hook
                  treemacs-mode-hook
                  eshell-mode-hook
                  ghostel-mode-hook
                  compilation-mode-hook
                  ;; Diff buffers: the line-number gutter would count the DIFF
                  ;; buffer's own lines (1, 2, 3...), which look like file line
                  ;; numbers but are not -- actively misleading.  The real source
                  ;; line numbers are in each hunk header (@@ -old,+new @@), where
                  ;; diff-mode already shows them.
                  diff-mode-hook
                  magit-diff-mode-hook
                  magit-status-mode-hook
                  magit-revision-mode-hook
                  telega-root-mode-hook
                  telega-chat-mode-hook
                  erc-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0)))))

(use-package ediff
  :ensure nil
  :custom
  ;; Keep ediff IN THE CURRENT FRAME.  The default (`ediff-setup-windows-default')
  ;; pops the control panel into a SEPARATE FRAME in a GUI -- a second window that
  ;; steals focus and litters the display.  `plain' puts the control panel in a
  ;; window of the current frame instead.
  (ediff-window-setup-function #'ediff-setup-windows-plain)
  ;; Side-by-side (A | B), not stacked -- code diffs read far better in columns.
  (ediff-split-window-function #'split-window-horizontally)
  (ediff-merge-split-window-function #'split-window-horizontally)
  :config
  ;; The layout fix.  ediff commandeers your windows to lay out A/B/control and
  ;; does NOT put them back on quit -- so `vc-ediff', `vc-branch-diff''s ediff kin,
  ;; magit's ediff actions and smerge all leave your carefully-split frame wrecked.
  ;; Snapshot the whole window configuration the instant before ediff sets up, and
  ;; restore it when ediff quits (depth 100 -> after ediff's own cleanup runs).
  (defvar my-ediff--window-config nil
    "Window configuration captured before ediff took over the frame.")
  (add-hook 'ediff-before-setup-hook
            (lambda () (setq my-ediff--window-config (current-window-configuration))))
  (dolist (hook '(ediff-quit-hook ediff-suspend-hook))
    (add-hook hook
              (lambda ()
                (when (window-configuration-p my-ediff--window-config)
                  (set-window-configuration my-ediff--window-config)))
              100)))

(use-package flymake
  :ensure nil
  :custom
  (flymake-fringe-indicator-position 'right-fringe))

(use-package mini-frame
  :custom
  (mini-frame-create-lazy nil)
  (mini-frame-resize t))

(use-package package
  :ensure nil
  :custom
  (package-selected-packages
   ;; NB: this list is only what `package-autoremove' considers "wanted" -- what is
   ;; actually installed is driven by :ensure on the use-package blocks below.  It
   ;; drifts, so don't trust it as an inventory.  (lsp-mode/lsp-ui/lsp-docker lived
   ;; here long after the config moved to eglot, and weren't even installed.)
   '(web-mode multi-web-mode 0blayout 0x0 all-the-icons bazel cargo-mode company consult
      corfu dashboard delight diff-hl diminish dired-subtree dockerfile-mode
      dotenv-mode dumb-jump eglot-fsharp elixir-mode envrc exec-path-from-shell
      fsharp-mode gcmh ghostel git-commit git-link go-mode go-noisegate grip-mode
      inheritenv
      highlight-indentation iedit logview magit marginalia
      markdown markdown-mode mini-frame orderless origami posframe projectile rg rust-mode
      transient treesit-auto undo-fu vertico yaml-mode)))

(use-package paren
  :ensure nil
  :custom
  (show-paren-mode t)
  (show-paren-priority -50)
  (show-paren-style 'expression))

(use-package tool-bar
  :ensure nil
  :custom
  (tool-bar-mode nil))

(use-package menu-bar
  :ensure nil
  :custom
  (menu-bar-mode nil))

(use-package tramp
  :ensure nil
  :custom
  (connection-local-criteria-alist
   '(((:application eshell)
      eshell-connection-default-profile)
     ((:application tramp :protocol "kubernetes")
      tramp-kubernetes-connection-local-default-profile)
     ((:application tramp :protocol "flatpak")
      tramp-container-connection-local-default-flatpak-profile
      tramp-flatpak-connection-local-default-profile)
     ((:application tramp)
      tramp-connection-local-default-system-profile
      tramp-connection-local-default-shell-profile)))
  (connection-local-profile-alist
   '((eshell-connection-default-profile
      (eshell-path-env-list))
     (tramp-flatpak-connection-local-default-profile
      (tramp-remote-path "/app/bin" tramp-default-remote-path "/bin" "/usr/bin"
                         "/sbin" "/usr/sbin" "/usr/local/bin" "/usr/local/sbin"
                         "/local/bin" "/local/freeware/bin" "/local/gnu/bin"
                         "/usr/freeware/bin" "/usr/pkg/bin" "/usr/contrib/bin"
                         "/opt/bin" "/opt/sbin" "/opt/local/bin"))
     (tramp-kubernetes-connection-local-default-profile
      (tramp-config-check . tramp-kubernetes--current-context-data)
      (tramp-extra-expand-args 97
                               (tramp-kubernetes--container
                                (car tramp-current-connection))
                               104
                               (tramp-kubernetes--pod
                                (car tramp-current-connection))
                               120
                               (tramp-kubernetes--context-namespace
                                (car tramp-current-connection))))
     (tramp-container-connection-local-default-flatpak-profile
      (tramp-remote-path "/app/bin" tramp-default-remote-path "/bin" "/usr/bin"
                         "/sbin" "/usr/sbin" "/usr/local/bin" "/usr/local/sbin"
                         "/local/bin" "/local/freeware/bin" "/local/gnu/bin"
                         "/usr/freeware/bin" "/usr/pkg/bin" "/usr/contrib/bin"
                         "/opt/bin" "/opt/sbin" "/opt/local/bin"))
     (tramp-connection-local-darwin-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o"
                                       "pid,uid,user,gid,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                       "-o" "state=abcde" "-o"
                                       "ppid,pgid,sess,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etime,pcpu,pmem,args")
      (tramp-process-attributes-ps-format
       (pid . number)
       (euid . number)
       (user . string)
       (egid . number)
       (comm . 52)
       (state . 5)
       (ppid . number)
       (pgrp . number)
       (sess . number)
       (ttname . string)
       (tpgid . number)
       (minflt . number)
       (majflt . number)
       (time . tramp-ps-time)
       (pri . number)
       (nice . number)
       (vsize . number)
       (rss . number)
       (etime . tramp-ps-time)
       (pcpu . number)
       (pmem . number)
       (args)))
     (tramp-connection-local-busybox-ps-profile
      (tramp-process-attributes-ps-args "-o"
                                       "pid,user,group,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                       "-o" "stat=abcde" "-o" "ppid,pgid,tty,time,nice,etime,args")
      (tramp-process-attributes-ps-format
       (pid . number)
       (user . string)
       (group . string)
       (comm . 52)
       (state . 5)
       (ppid . number)
       (pgrp . number)
       (ttname . string)
       (time . tramp-ps-time)
       (nice . number)
       (etime . tramp-ps-time)
       (args)))
     (tramp-connection-local-bsd-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o"
                                       "pid,euid,user,egid,egroup,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                       "-o"
                                       "state,ppid,pgid,sid,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etimes,pcpu,pmem,args")
      (tramp-process-attributes-ps-format
       (pid . number)
       (euid . number)
       (user . string)
       (egid . number)
       (group . string)
       (comm . 52)
       (state . string)
       (ppid . number)
       (pgrp . number)
       (sess . number)
       (ttname . string)
       (tpgid . number)
       (minflt . number)
       (majflt . number)
       (time . tramp-ps-time)
       (pri . number)
       (nice . number)
       (vsize . number)
       (rss . number)
       (etime . number)
       (pcpu . number)
       (pmem . number)
       (args)))
     (tramp-connection-local-default-shell-profile
      (shell-file-name . "/bin/sh")
      (shell-command-switch . "-c"))
     (tramp-connection-local-default-system-profile
      (path-separator . ":")
      (null-device . "/dev/null")))))

(use-package warnings
  :ensure nil
  :custom
  ;; auto-save warnings are suppressed at the LOG level, so they never reach the
  ;; *Warnings* buffer at all -- which is why there is no `warning-suppress-types'
  ;; (display-only suppression) counterpart here any more.  Its sole entry was
  ;; lsp-mode, dropped with the rest of the lsp leftovers: this config has been
  ;; eglot-only for a long time and lsp-mode isn't even installed.
  (warning-suppress-log-types '((auto-save))))

(use-package web-mode
  :custom
  (web-mode-markup-indent-offset 2))

(use-package faces
  :ensure nil
  :custom-face
  (default ((t (:inherit nil :extend nil :stipple nil :background "#181a26"
                        :foreground "gray80" :inverse-video nil :box nil
                        :strike-through nil :overline nil :underline nil
                        :slant normal :weight regular :height 95 :width normal
                        :foundry "GOOG" :family "Roboto Mono"))))
  ;; Lucid-toolkit scrollbar takes its colour from this face; unspecified, it
  ;; renders bright.  Match the background, muted thumb (readable on KDE).
  (scroll-bar ((t (:background "#181a26" :foreground "#3a3f52"))))
  (compilation-error ((t (:foreground "#D9786B"))))
  (compilation-info ((t (:foreground "#A3A9CE" :weight normal))))
  (compilation-warning ((t (:inherit warning :foreground "#FDB262"))))
  (custom-button ((t (:background "#606163" :foreground "#e8e9e9"
                                  :box (:line-width (2 . 2) :style flat-button)))))
  (eglot-highlight-symbol-face ((t (:distant-foreground "orange" :foreground "black"
                                           :weight ultra-heavy))))
  (flycheck-error ((t (:background "#553333" :underline (:color "Red1" :style wave)))))
  (fringe ((t (:background "#181a26"))))
  (highlight ((t (:underline t))))
  (hl-line ((t (:background "#2b2d36"))))
  (line-number ((t (:inherit (shadow default) :foreground "gray34" :height 95))))
  (line-number-current-line ((t (:inherit line-number :foreground "gray60"))))
  (link ((t (:slant italic))))
  (mode-line ((t (:background "#282b35" :foreground "#737475"
                              :box (:line-width (1 . 1) :style flat-button)))))
  (mode-line-buffer-id ((t (:distant-foreground "#969696" :foreground "gray75"
                                                :weight bold))))
  (mode-line-inactive ((t (:background "#282b35" :foreground "#737475"
                                       :box (:line-width (1 . 1) :color "#121214"
                                             :style flat-button)))))
  (parenthesis ((t (:inherit default :foreground "dim gray"))))
  (show-paren-match ((t (:background "#2f334b"))))
  (term-color-black ((t (:background "#555753" :foreground "black"))))
  (term-color-blue ((t (:background "#739FCF" :foreground "#3465A4"))))
  (term-color-cyan ((t (:background "#34E2E2" :foreground "#06989A"))))
  (term-color-green ((t (:background "#8AE234" :foreground "#4E9A06"))))
  (term-color-magenta ((t (:background "#AD7FA8" :foreground "#75507B"))))
  (term-color-red ((t (:background "#EF2929" :foreground "#CC0000"))))
  (term-color-white ((t (:background "#EEEEEC" :foreground "#D3D7CF"))))
  (term-color-yellow ((t (:background "#FCE94F" :foreground "#C4A000"))))
  (tooltip ((t (:inherit default :height 1.0))))
  (widget-field ((t (:extend t :background "#171A27"
                             :box (:line-width (1 . 3) :color "#737687"
                                   :style flat-button) :weight bold :height 1.0)))))

(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize))
  ;; Robust regardless of launch context (terminal, systemd, desktop): the
  ;; `window-system' guard above skips the shell import for non-GUI launches,
  ;; so explicitly put the per-user tool dirs on `exec-path' too.  Matters for
  ;; gopls (~/go/bin) and cargo/rust-analyzer when launched without the shell
  ;; PATH (see also the Go/Rust tooling).
  ;; ~/.local/share/mise/shims: mise-managed runtimes/servers (node + the npm
  ;; LSP servers, ruff, ...) — so eglot finds them even on a non-shell launch.
  (dolist (dir '("~/.local/share/mise/shims"
                 "~/.cargo/bin" "~/go/bin" "~/.local/bin" "~/bin"))
    (let ((p (expand-file-name dir)))
      (when (file-directory-p p)
        (add-to-list 'exec-path p)
        (setenv "PATH" (concat p path-separator (getenv "PATH")))))))

;; Emacs server: let `emacsclient' (and the terminal $EDITOR integration in
;; ~/.bashrc) open files and git commit/rebase buffers in this running Emacs.
(use-package server
  :ensure nil
  :config
  ;; A hard-killed Emacs (crash, SIGKILL after a freeze) never runs its cleanup,
  ;; so it leaves its socket FILE behind.  `server-running-p' then correctly says
  ;; "no server" -- nothing is listening on it -- so we proceed to `server-start',
  ;; which promptly fails to BIND that path: "Cannot bind server socket: Address
  ;; already in use".  use-package catches it, and you're left with no server at
  ;; all: emacsclient, ecommit, eopen and ebuffer all dead until you restart.
  ;; Delete the corpse socket first.  The `unless' still protects a server that is
  ;; genuinely alive in ANOTHER Emacs (`server-running-p' returns `:other' there,
  ;; which is non-nil, so we never touch it).
  ;; Never in batch: the headless smoke test loads this config, and a batch Emacs
  ;; must not `server-force-delete' (it could remove the socket of the REAL Emacs
  ;; you have running) nor `server-start' (it would exit and leave a stale socket
  ;; behind -- recreating the very bug this block exists to fix).
  (unless (or noninteractive (server-running-p))
    (server-force-delete)
    (server-start)))

;; `emacsclient foo.c:123:4' -> open foo.c and go to 123:4.
;;
;; Everything in a byobu tab speaks `path:line:col': rg, grep, gcc, a Python
;; traceback, a Claude code reference.  With $EDITOR=emacsclient the natural move
;; is to paste one straight back -- and stock Emacs then creates a NEW, empty file
;; literally named `foo.c:123:4'.  (emacsclient does have +LINE:COL, but that is
;; not the shape the tools print, and you'd have to hand-edit every paste.)
;;
;; server.el already knows how to jump: it threads a (LINE . COLUMN) cons through
;; `server-visit-files' as the cdr of each (FILENAME . FILEPOS) pair.  So we don't
;; need to reimplement anything -- just rewrite the args on the way in.
(use-package server
  :ensure nil
  :config
  (defun my-server--split-file-line-col (file)
    "Rewrite (\"foo.c:12:3\" . nil) into (\"foo.c\" . (12 . 3)) for `server-visit-files'.
Only when the literal name does NOT exist on disk but the stripped one does, so a
file honestly named with a colon still opens as itself."
    (pcase-let ((`(,name . ,pos) file))
      (if (and (stringp name)
               (null pos)
               (not (file-exists-p name))
               ;; path:LINE, path:LINE:COL, and the trailing colon rg/grep print.
               (string-match "\\`\\(.+?\\):\\([0-9]+\\)\\(?::\\([0-9]+\\)\\)?:?\\'" name)
               (file-exists-p (match-string 1 name)))
          (cons (match-string 1 name)
                ;; `server-goto-line-column' treats column 0 as "don't move", and
                ;; otherwise takes a 1-based column -- exactly what tools print.
                (cons (string-to-number (match-string 2 name))
                      (if (match-string 3 name)
                          (string-to-number (match-string 3 name))
                        0)))
        file)))

  (define-advice server-visit-files (:filter-args (args) my-file-line-col)
    "Teach `emacsclient' the `path:line:col' shape every CLI tool prints."
    (cons (mapcar #'my-server--split-file-line-col (car args)) (cdr args))))

;; The other half of the loop above: PRODUCE a `path:line:col' for where you are.
;; That string is the unit of exchange with everything outside Emacs -- paste it
;; into a Claude prompt, an `rg' follow-up, `git blame -L', a bug report.  Bound on
;; the C-t map next to the other hand-it-to-the-terminal commands (C-t C-y cites a
;; region, C-t C-b cites a buffer), so: C-t C-w.
(use-package emacs
  :ensure nil
  :init
  (defun my-copy-file-path-with-line (&optional absolute)
    "Copy `path:line:col' for point to the kill ring.
Relative to the project root when the file is inside one -- that is the form you
paste into a prompt or a review.  With a prefix arg, copy the ABSOLUTE path
instead (what you want for `emacsclient' from an unrelated directory; either form
is understood on the way back in, see `server-visit-files')."
    (interactive "P")
    (let* ((file (or buffer-file-name
                     (user-error "This buffer is not visiting a file")))
           (root (and (not absolute)
                      (fboundp 'projectile-project-root)
                      (ignore-errors (projectile-project-root))))
           (path (if (and root (string-prefix-p (expand-file-name root)
                                                (expand-file-name file)))
                     (file-relative-name file root)
                   file))
           (ref (format "%s:%d:%d" path
                        (line-number-at-pos nil t)
                        (1+ (current-column)))))
      (kill-new ref)
      (message "Copied: %s" ref)
      ref)))

;; Session save/restore.  On EVERY exit (`kill-emacs-hook' — so a plain `C-x C-c'
;; or a laptop shutdown counts) we stash an explicit snapshot (file list +
;; `window-state' + frame geometry + terminal project roots); on the next launch
;; `emacs-startup-hook' reopens the files, re-creates the project terminals, and
;; puts the layout back, then consumes the snapshot.  `M-x my-restart-everything'
;; is the same snapshot plus killing the project byobu sessions and an explicit
;; `restart-emacs'.  We stash rather than lean on `desktop' (whose hook-driven
;; restore is unreliable).  Since `window-state' references buffers by name, the
;; re-created ghostel terminals (deterministic names) land back in their panes.
(use-package emacs
  :init
  (defvar my-restart--state-file
    (expand-file-name ".restart-state.el" user-emacs-directory)
    "Where `my-restart-everything' stashes the session snapshot across a restart.")

  (defvar my-restart--log-file
    (expand-file-name ".restart-state.log" user-emacs-directory)
    "Where the last session-restore records what it did (for debugging).")

  (defun my-restart--log (fmt &rest args)
    "Append a line to `my-restart--log-file' (never signals)."
    (ignore-errors
      (write-region (concat (apply #'format fmt args) "\n")
                    nil my-restart--log-file 'append 'silent)))

  (defun my-restart--terminals ()
    "Every live ghostel terminal as (BUFFER-NAME . PROJECT-ROOT), deduped by name.
The exact buffer NAME is saved (not just the dir) so restore can recreate each
terminal under the SAME name — `window-state' references buffers by name, so a
name mismatch would leave the terminal out of its pane."
    (let (acc)
      (dolist (b (buffer-list))
        (with-current-buffer b
          ;; Skip ephemeral grouped VIEWS (`my-ghostel-grouped-view') -- they're
          ;; throwaway peers; restoring one via plain `bb' would make a bogus
          ;; second direct-attach instead of a grouped view.
          (when (and (derived-mode-p 'ghostel-mode)
                     (not my-ghostel--view-session))
            (let ((name (buffer-name b)))
              (unless (assoc name acc)
                (push (cons name
                            (or (ignore-errors
                                  (projectile-project-root default-directory))
                                default-directory))
                      acc))))))
      (nreverse acc)))

  (defun my-restart--make-terminal (bufname root)
    "Recreate a ghostel terminal named exactly BUFNAME, rooted at ROOT, via `bb'.
Named as saved so `window-state-put' matches it back into its pane."
    (require 'ghostel)
    (when (and (stringp bufname) (stringp root) (file-directory-p root)
               (not (get-buffer bufname)))
      (let* ((default-directory root)
             (project (or (ignore-errors (projectile-project-root root)) root))
             (pname (ignore-errors (projectile-project-name project)))
             (process-environment
              (if pname (cons (concat "PROJECTILE_PROJECT_NAME=" pname)
                              process-environment)
                process-environment))
             (ghostel-buffer-name bufname)
             (buffer (ghostel)))
        (with-current-buffer buffer
          (setq-local my-ghostel--project project)
          (ghostel-send-string "bb\n"))
        buffer)))

  (defun my-restart--kill-byobu ()
    "Kill the per-project byobu/tmux sessions (projectile/*)."
    (when (executable-find "tmux")
      (dolist (s (split-string
                  (with-output-to-string
                    (call-process "tmux" nil standard-output nil
                                  "list-sessions" "-F" "#{session_name}"))
                  "\n" t))
        (when (string-prefix-p "projectile/" s)
          (call-process "tmux" nil nil nil "kill-session" "-t" (concat "=" s))))))

  (defun my-restart--save-state ()
    "Snapshot the session (open files, window layout, frame geometry, project
terminals) to `my-restart--state-file' for restore on the next startup.
Wrapped so a snapshot failure can never block Emacs from quitting.  Runs on
`kill-emacs-hook' (so a plain `C-x C-c' / laptop shutdown restores next boot)
and from `my-restart-everything'."
    (ignore-errors
      (with-temp-file my-restart--state-file
        (prin1 (list :files (delq nil
                             (mapcar (lambda (b)
                                       (with-current-buffer b
                                         ;; (FILE . POINT); skip terminals — a
                                         ;; ghostel buffer's point is the PTY's,
                                         ;; not a cursor to restore.
                                         (when (and buffer-file-name
                                                    (not (derived-mode-p 'ghostel-mode)))
                                           (cons buffer-file-name (point)))))
                                     (buffer-list)))
                     :frame (let ((f (selected-frame)))
                              (list (cons 'fullscreen (frame-parameter f 'fullscreen))
                                    (cons 'width  (frame-parameter f 'width))
                                    (cons 'height (frame-parameter f 'height))
                                    (cons 'left   (frame-parameter f 'left))
                                    (cons 'top    (frame-parameter f 'top))))
                     :windows (window-state-get (frame-root-window) t)
                     :terminals (my-restart--terminals))
               (current-buffer)))))

  (defun my-restart-everything ()
    "Kill the project byobu sessions, restart Emacs, then restore the open file
buffers, window layout, and project terminals."
    (interactive)
    (when (yes-or-no-p "Kill byobu sessions and restart Emacs (restoring after)? ")
      (save-some-buffers)
      (my-restart--save-state)
      (my-restart--kill-byobu)
      (restart-emacs)))

  (defun my-restart--maybe-restore ()
    "If `my-restart-everything' left a snapshot, restore it once."
    (when (file-exists-p my-restart--state-file)
      (let ((data (ignore-errors
                    (with-temp-buffer (insert-file-contents my-restart--state-file)
                                      (read (current-buffer))))))
        (delete-file my-restart--state-file)   ; consume even on partial restore
        (when data
          (ignore-errors (write-region "" nil my-restart--log-file nil 'silent)) ; fresh log
          (my-restart--log "restore begin: %d files, %d terminals"
                           (length (plist-get data :files))
                           (length (plist-get data :terminals)))
          ;; 1. reopen the files (so window-state can place them by name) and
          ;;    restore point.  Entries are (FILE . POINT); older snapshots stored
          ;;    a bare FILE string, so accept both.  `window-state-put' already
          ;;    restores point for DISPLAYED windows; this also covers files that
          ;;    were open but not showing (which would otherwise land at bob).
          (dolist (entry (plist-get data :files))
            (let ((f (if (consp entry) (car entry) entry))
                  (pos (and (consp entry) (cdr entry))))
              (when (and (stringp f) (file-exists-p f))
                (let ((buf (ignore-errors (find-file-noselect f))))
                  (if buf
                      (progn
                        (when (integerp pos)
                          (with-current-buffer buf
                            (goto-char (min pos (point-max)))))
                        (my-restart--log "file ok:  %s @%s" f pos))
                    (my-restart--log "file FAIL: %s" f))))))
          ;; 2. re-create the project terminals under their EXACT saved names.
          (dolist (term (plist-get data :terminals))
            (cond
             ((consp term)             ; (name . root) -- recreate by exact name
              (ignore-errors (my-restart--make-terminal (car term) (cdr term)))
              (my-restart--log "term %s: %s -> present=%s" (car term) (cdr term)
                               (and (get-buffer (car term)) t)))
             ((and (stringp term) (file-directory-p term)) ; back-compat: bare dir
              (let ((default-directory term))
                (ignore-errors (my-project-tab "shell"))))))
          ;; 3. restore frame geometry (window-state covers only the inner
          ;;    layout, not the frame's own size/position/maximized state)
          (ignore-errors
            (let* ((fp (plist-get data :frame))
                   (fs (alist-get 'fullscreen fp)))
              (if fs
                  (set-frame-parameter (selected-frame) 'fullscreen fs)
                (modify-frame-parameters
                 (selected-frame)
                 (list (cons 'width  (alist-get 'width fp))
                       (cons 'height (alist-get 'height fp))
                       (cons 'left   (alist-get 'left fp))
                       (cons 'top    (alist-get 'top fp)))))))
          ;; 4. apply the window layout on a short timer -- AFTER the dashboard,
          ;;    the ghostel terminal display, and any other startup reflow have
          ;;    run, and after slow buffers settle, so our layout is the final
          ;;    word.  Doing it synchronously here let late reflows clobber panes.
          (let ((ws (plist-get data :windows)))
            (run-at-time
             0.3 nil
             (lambda ()
               (ignore-errors (window-state-put ws (frame-root-window) t))
               (my-restart--log "layout applied; windows: %S"
                                (mapcar (lambda (w) (buffer-name (window-buffer w)))
                                        (window-list))))))))))
  :config
  ;; NOT in batch.  The headless smoke test (AGENTS.md) LOADS this config, and a
  ;; batch Emacs exits immediately -- which would fire `kill-emacs-hook' and
  ;; overwrite the real session snapshot with the batch session's (empty) state,
  ;; destroying it.  The restore side is equally unwanted headless: it would
  ;; reopen files and respawn project terminals.
  (unless noninteractive
    (add-hook 'emacs-startup-hook #'my-restart--maybe-restore)
    ;; First half: snapshot on every exit so a plain `C-x C-c' / laptop shutdown
    ;; comes back next launch (the startup hook restores + consumes the file).
    (add-hook 'kill-emacs-hook #'my-restart--save-state)))

;; Monorepo self-install: this .emacs.d repo also vendors the shell + byobu
;; integration (shell/integration.bash, byobu/*).  Ensure, idempotently at
;; startup, that ~/.bashrc sources the snippet and that the vendored byobu files
;; are symlinked into ~/.config/byobu — so a fresh clone wires itself up.
(defun my-ensure-shell-integration ()
  "Wire this repo's shell/byobu integration into ~/.bashrc and ~/.config/byobu."
  (let* ((repo  (expand-file-name user-emacs-directory))
         (integ (expand-file-name "shell/integration.bash" repo))
         (bashrc (expand-file-name "~/.bashrc"))
         (begin "# >>> emacs-managed shell integration >>>")
         (end   "# <<< emacs-managed shell integration <<<"))
    ;; 1. Make ~/.bashrc source the vendored integration (append the block once).
    (when (file-exists-p integ)
      (let ((content (and (file-readable-p bashrc)
                          (with-temp-buffer (insert-file-contents bashrc)
                                            (buffer-string)))))
        (unless (and content (string-search begin content))
          (with-temp-buffer
            (when content (insert content) (unless (bolp) (insert "\n")))
            (insert "\n" begin "\n"
                    (format "[ -r %s ] && . %s\n"
                            (shell-quote-argument integ)
                            (shell-quote-argument integ))
                    end "\n")
            (write-region (point-min) (point-max) bashrc)))))
    ;; 1b. Symlink the vendored Claude/Emacs helper scripts onto PATH so a
    ;;     non-interactive shell (Claude's Bash tool) can run them, and ensure
    ;;     they stay executable even if git didn't preserve the mode.
    (let ((bin-src (expand-file-name "shell/bin" repo))
          (bin-dst (expand-file-name "~/.local/bin")))
      (dolist (f '("eopen" "esay" "enotify" "ecommit" "ebuffer" "esh" "etab"
                   "ediff-review" "oriole-pgindent" "oriole-yapf"))
        (let ((src (expand-file-name f bin-src))
              (dst (expand-file-name f bin-dst)))
          (when (file-exists-p src)
            (make-directory bin-dst t)
            (set-file-modes src #o755)
            (unless (and (file-symlink-p dst)
                         (string= (file-truename dst) (file-truename src)))
              (when (file-exists-p dst) (delete-file dst))
              (make-symbolic-link src dst t))))))
    ;; 2. Symlink the vendored byobu config files into ~/.config/byobu.
    (let ((src-dir (expand-file-name "byobu" repo))
          (dst-dir (expand-file-name "~/.config/byobu")))
      (dolist (f '("status" ".tmux.conf" "bin/bb-save-layout"))
        (let ((src (expand-file-name f src-dir))
              (dst (expand-file-name f dst-dir)))
          (when (file-exists-p src)
            (make-directory (file-name-directory dst) t)
            (unless (and (file-symlink-p dst)
                         (string= (file-truename dst) (file-truename src)))
              (when (file-exists-p dst) (delete-file dst))
              (make-symbolic-link src dst t))))))
    ;; 3. Claude "inside Emacs" context overlay (vendored in ~/.emacs.d/claude):
    ;;    symlink the hook + content into ~/.claude, and register the
    ;;    SessionStart hook in ~/.claude/settings.json.  The JSON edit is
    ;;    idempotent and defensive — it leaves the file untouched if our hook is
    ;;    already there or on any parse/serialize error.
    (let ((claude-src (expand-file-name "claude" repo)))
      (when (file-directory-p claude-src)
        (dolist (pair '(("inside-emacs.md" . "~/.claude/context/_env/inside-emacs.md")
                        ("hooks/inside-emacs-context" . "~/.claude/hooks/inside-emacs-context")))
          (let ((src (expand-file-name (car pair) claude-src))
                (dst (expand-file-name (cdr pair))))
            (when (file-exists-p src)
              (make-directory (file-name-directory dst) t)
              (unless (and (file-symlink-p dst)
                           (string= (file-truename dst) (file-truename src)))
                (when (file-exists-p dst) (delete-file dst))
                (make-symbolic-link src dst t)))))
        (let ((settings (expand-file-name "~/.claude/settings.json"))
              (cmd "~/.claude/hooks/inside-emacs-context"))
          (when (and (file-readable-p settings) (fboundp 'json-parse-string))
            (condition-case err
                (let* ((text (with-temp-buffer (insert-file-contents settings)
                                               (buffer-string)))
                       (data (json-parse-string text)) ; hash-tables = mutable form
                       (changed nil))
                  ;; (a) append our hook to each existing SessionStart matcher.
                  (unless (string-search cmd text)
                    (let* ((hooks (gethash "hooks" data))
                           (ss (and hooks (gethash "SessionStart" hooks))))
                      (when (and ss (> (length ss) 0))
                        (dotimes (i (length ss))
                          (let* ((entry (aref ss i))
                                 (hs (gethash "hooks" entry))
                                 (mh (make-hash-table :test 'equal)))
                            (puthash "type" "command" mh)
                            (puthash "command" cmd mh)
                            (puthash "hooks" (vconcat hs (vector mh)) entry)))
                        (setq changed t))))
                  ;; (b) allowlist the vendored eopen/esay scripts, so Claude runs
                  ;;     them without a permission prompt.
                  (let* ((perms (or (gethash "permissions" data)
                                    (let ((h (make-hash-table :test 'equal)))
                                      (puthash "permissions" h data) h)))
                         (allow (or (gethash "allow" perms) (vector))))
                    (dolist (rule '("Bash(eopen:*)" "Bash(esay:*)" "Bash(enotify:*)"
                                    "Bash(ecommit:*)" "Bash(ebuffer:*)" "Bash(esh:*)"
                                    "Bash(ediff-review:*)"))
                      (unless (seq-contains-p allow rule)
                        (setq allow (vconcat allow (vector rule)) changed t)))
                    (puthash "allow" allow perms))
                  (when changed
                    (with-temp-file settings
                      (insert (json-serialize data)))))
              (error
               (message "inside-emacs setup: left settings.json alone (%S)" err)))))))))

;; Never run the installer in batch: the headless smoke test (see AGENTS.md) LOADS
;; this config to prove it still works, and it must not write to ~/.bashrc, create
;; symlinks, or touch ~/.claude/settings.json as a side effect of being tested.
(unless noninteractive
  (add-hook 'after-init-hook #'my-ensure-shell-integration))

;; Clipboard interop with X11 apps (xfce4-terminal, Chrome, ...).
;; `C-y' reads the CLIPBOARD selection; also fall back to the PRIMARY selection
;; so a plain mouse-select in another app is yankable.  (xfce4-terminal is
;; additionally set to copy-on-select to CLIPBOARD via
;; ~/.config/xfce4/terminal/terminalrc; `save-interprogram-paste-before-kill'
;; lives in the `simple' block above.)
(use-package select
  :ensure nil
  :custom
  (select-enable-primary t)
  (select-enable-clipboard t)
  ;; Don't let an ACTIVE REGION overwrite the PRIMARY selection.  Otherwise the
  ;; replace-with-yank workflow breaks: `C-w' a string, mouse-select the target to
  ;; replace, `C-y' -- and yank reads the just-set PRIMARY (the target) instead of
  ;; the CLIPBOARD (your C-w), so with `delete-selection-mode' the selection is
  ;; deleted and pasted back over itself: nothing changes.  This only stops Emacs
  ;; WRITING its own selections to PRIMARY; `select-enable-primary' stays on, so
  ;; yanking ANOTHER app's mouse-selection into Emacs still works.
  (select-active-regions nil))

;; direnv integration: each buffer picks up the environment from its project's
;; .envrc, so eglot, `compile', and shell commands run with that project's tools
;; and env vars.  `envrc-global-mode' is enabled on `after-init-hook' so it
;; loads late and wins over other process-environment managers
;; (exec-path-from-shell, the explicit exec-path entries above, ...).
;; `C-c e' in a managed buffer -> envrc-command-map (e = allow, r = reload, ...).
(use-package envrc
  :hook (after-init . envrc-global-mode)
  :config
  (define-key envrc-mode-map (kbd "C-c e") 'envrc-command-map))

(use-package projectile
  :init
  (defun my-project-root ()
    "Project root for the current buffer, for the C-t terminal launchers.
Detect FRESH every time — `projectile-project-root' memoizes failures in
`projectile-project-root-cache', so a directory checked before its `git
init' stays cached as \"no project\".  We bind a throwaway cache so a
just-created marker is always seen.  When still no project is found, ask
for a folder to use as the root instead of projectile's project picker.
Inside a project terminal, return that terminal's own project (stamped on the
buffer when it opened), so the C-t commands never re-prompt from there -- which
matters when the folder isn't a git/projectile project yet (e.g. before `git
init')."
    (require 'projectile)
    (or (and (derived-mode-p 'ghostel-mode) (bound-and-true-p my-ghostel--project))
        (let ((projectile-project-root-cache (make-hash-table :test 'equal)))
          (projectile-project-root default-directory))
        (my-project--pick-root)))

  (defun my-project--pick-root ()
    "Ask for a project root, listing projects open in this Emacs session first,
then other known projects, then a browse-for-folder escape.  Order preserved."
    (require 'projectile)
    (let* ((open  (projectile-open-projects))
           (known (seq-remove (lambda (p) (member p open))
                              (projectile-known-projects)))
           (browse "Browse for a folder…")
           (cands (append open known (list browse)))
           (choice (completing-read
                    "Project root (open projects first): "
                    (lambda (str pred action)
                      (if (eq action 'metadata)
                          '(metadata (display-sort-function . identity))
                        (complete-with-action action cands str pred)))
                    nil t)))
      (file-name-as-directory
       (expand-file-name
        (if (equal choice browse)
            (read-directory-name "Use folder as project root: " default-directory nil t)
          choice)))))

  (defvar my-project-tab-commands
    '(("claude" . "claude --continue || claude"))
    "Startup command per byobu tab when the window has to be created.
Tabs not listed here open as a plain shell.")

  (defvar-local my-ghostel--return-buffer nil
    "The code buffer THIS terminal was entered from; `C-t C-t' returns here.
Buffer-local on the terminal, so two projects' terminals each go back to their
own editor buffer instead of sharing one global \"last buffer\".  Stamped at
entry by `my-ghostel--enter-from' / `my-project-tab'; navigating between tabs
from inside a terminal leaves it alone.")

  (defun my-ghostel--enter-from (term-buffer src)
    "Switch to TERM-BUFFER, recording SRC as its `my-ghostel--return-buffer'.
Skips the recording when SRC is itself a terminal, so moving between tabs doesn't
overwrite where you came in from."
    (when (and (buffer-live-p src)
               (not (provided-mode-derived-p (buffer-local-value 'major-mode src)
                                             'ghostel-mode)))
      (with-current-buffer term-buffer (setq-local my-ghostel--return-buffer src)))
    (switch-to-buffer term-buffer))

  (defvar-local my-ghostel--cited-session nil
    "Sticky byobu-session association for an unprojected buffer.  Set when you
cite from here with `C-t C-y'; `C-t C-t' then jumps to that session's terminal
instead of asking for a folder.  Lives for the buffer's lifetime.")

  (defvar-local my-ghostel--project nil
    "Project root this ghostel terminal was opened for.  Stamped by
`my-project-tab' so `my-project-root' (and thus every `C-t' command) resolves to
it from inside the terminal instead of re-detecting -- crucial when the folder
isn't a git/projectile project yet.")

  (defvar my-ghostel--view-counter 0
    "Monotonic counter for unique grouped-view session names (see
`my-ghostel-grouped-view').")

  (defvar-local my-ghostel--view-session nil
    "For a grouped-VIEW terminal, its own tmux session name (`…^vN').
Set by `my-ghostel-grouped-view'.  Non-nil marks this buffer as a view, so the
`C-t' tab launchers switch THIS view's tab (its grouped session shares the base
session's windows) instead of popping the main terminal.")

  (defun my-ghostel--delete-window-safely (win)
    "Delete WIN if it is a live, non-sole window.  Deferred grouped-view cleanup
helper -- passed as a timer ARG (not a closure), so it fires regardless of
binding mode."
    (when (and (window-live-p win) (window-parent win))
      (ignore-errors (delete-window win))))

  (defun my-ghostel--kill-tmux-session (name)
    "Kill tmux session NAME (a grouped view).  Deferred cleanup helper."
    (call-process "tmux" nil nil nil "kill-session" "-t" (concat "=" name)))

  (defun my-ghostel--view-cleanup ()
    "Kill-buffer-hook for a grouped VIEW: fold its window, reap its tmux session.

Windows: mark them dedicated so `kill-buffer's own `replace-buffer-in-windows'
DELETES them, instead of filling the freed window with the main terminal buffer
-- one ghostel buffer shown in a second window flips into a stuck copy-mode.
Dedicating only at kill time keeps the window normal during use (toggle/switch
work).  A deferred `delete-window' backstops it.

Tmux: kill ONLY the view's own `…^vN' session (never the shared base -- the regex
guard makes a base name impossible to match), DEFERRED so its teardown can't race
the window resize above (that combination once wedged the sibling terminal).
Done in Emacs so it is reliable however the PTY died -- `C-x k' hard-kills it, so
the shell-side trap never runs."
    (let ((wins (get-buffer-window-list (current-buffer) nil t)))
      (dolist (w wins) (ignore-errors (set-window-dedicated-p w t)))
      (dolist (w wins) (run-at-time 0 nil #'my-ghostel--delete-window-safely w)))
    (when (and (stringp my-ghostel--view-session)
               (string-match-p "\\^v[0-9]+\\'" my-ghostel--view-session))
      (run-at-time 0 nil #'my-ghostel--kill-tmux-session my-ghostel--view-session)))

  (defun my-byobu--session (project)
    "tmux session name for PROJECT, sanitized like `bb' (./: -> _)."
    (concat "projectile/"
            (replace-regexp-in-string "[.: ]" "_" (projectile-project-name project))))

  (defun my-byobu--ghostel-buffer (session)
    "The live ghostel buffer attached to SESSION, or nil."
    (seq-find (lambda (b)
                (with-current-buffer b
                  (and (derived-mode-p 'ghostel-mode)
                       (equal (ignore-errors (my-byobu--session default-directory))
                              session))))
              (buffer-list)))

  (defun my-project-tab (window &optional arg)
    "Open the project's byobu session and select WINDOW.
WINDOW is a tab name (string), a tmux window index (integer), or nil to leave
the session's active tab as-is (just show the terminal).  Starts the
session with `bb' if needed (default tabs claude/shell/git/test); a string
names a tab (created on demand from `my-project-tab-commands', else a plain
shell), an integer selects that window index — unambiguous when names clash.
All tabs share one ghostel buffer; `my-ghostel-toggle-terminal' returns to your
code."
    (require 'ghostel)
    (if (bound-and-true-p my-ghostel--view-session)
        ;; In a grouped VIEW, switch THAT view's own tab and stay put -- don't pop
        ;; the main terminal.  The view is its own tmux session sharing the base
        ;; session's windows, so selecting there moves only this pane.
        (progn
          (when window
            (call-process "tmux" nil nil nil "select-window"
                          "-t" (if (integerp window)
                                   (format "=%s:%d" my-ghostel--view-session window)
                                 (format "=%s:%s" my-ghostel--view-session window))))
          (current-buffer))
    (let* ((src (current-buffer))
           (project (my-project-root))
           (name (projectile-project-name project))
           (session (my-byobu--session project))
           (ghostel-buffer-name (projectile-generate-process-name "ghostel" arg project))
           (fresh (not (get-buffer ghostel-buffer-name)))
           (default-directory project)
           (process-environment
            (cons (concat "PROJECTILE_PROJECT_NAME=" name) process-environment))
           (buffer (ghostel)))
      ;; Stamp the project on the terminal buffer so `my-project-root' resolves
      ;; to it from inside (no re-prompt even when the folder isn't a project).
      (with-current-buffer buffer (setq-local my-ghostel--project project))
      ;; Record where we entered from, per terminal -- but not when coming from
      ;; another terminal (tab navigation must not move the return target).
      (unless (provided-mode-derived-p (buffer-local-value 'major-mode src) 'ghostel-mode)
        (with-current-buffer buffer (setq-local my-ghostel--return-buffer src)))
      (when fresh
        (with-current-buffer buffer (ghostel-send-string "bb\n")))
      (cond ((integerp window)                ; index -> that window
             (call-process "tmux" nil nil nil "select-window"
                           "-t" (format "=%s:%d" session window)))
            (window                            ; name -> ensure/select that tab
             (my-projectile--byobu-ensure-window
              session window project (cdr (assoc window my-project-tab-commands)))))
      ;; WINDOW nil -> leave the session's active tab as-is (the toggle wants this)
      buffer)))

  (defun my-project-tab-test   (&optional arg) "Select the byobu `test' tab."   (interactive "P") (my-project-tab "test"   arg))
  (defun my-project-tab-claude (&optional arg) "Select the byobu `claude' tab." (interactive "P") (my-project-tab "claude" arg))
  (defun my-project-tab-git    (&optional arg) "Select the byobu `git' tab."    (interactive "P") (my-project-tab "git"    arg))
  (defun my-project-tab-shell  (&optional arg) "Select the byobu `shell' tab."  (interactive "P") (my-project-tab "shell"  arg))
  (defun my-project-tab-sudo   (&optional arg) "Select the byobu `sudo' tab (an `esh'-spawned window awaiting your password)." (interactive "P") (my-project-tab "sudo" arg))

  (defun my-ghostel--read-view-tab ()
    "Read a grouped-view starting tab from a prefix arg (nil = auto-pick)."
    (when current-prefix-arg
      (let ((w (read-string "Grouped view starting tab (blank = auto): ")))
        (unless (string-empty-p w) w))))

  (defun my-ghostel-grouped-view (&optional window direction)
    "Split and open another INDEPENDENT view of this project's byobu session.
Opens a fresh ghostel buffer attached via `bb -g' -- its own grouped tmux session
that SHARES the base session's windows but keeps its own active tab AND its own
scrollback.  So you can split off as many panes as you like (like file buffers)
and watch different byobu windows side by side, each scrolling independently --
e.g. several live-stat windows at once.

Peers, not children: the persistent byobu session is never destroyed by closing
these (only the ephemeral view is), and \"main\" (the base-named `*ghostel P*'
buffer) matters only as the `C-t C-t'-from-a-file target.

By default the view opens on a DIFFERENT tab than the base session is showing (so
two panes never fight over one window's size).  WINDOW, a tab name, picks the
starting tab (prefix arg prompts; blank = auto).  DIRECTION is `right' (default)
or `below' for where to split -- `my-ghostel-split-view-right'/`-below' (bound to
`C-x 3'/`C-x 2' in a terminal) pass it."
    (interactive (list (my-ghostel--read-view-tab) 'right))
    (require 'ghostel)
    (let* ((project (my-project-root))
           (name (projectile-project-name project))
           (session (my-byobu--session project))
           (view-session (format "%s^v%d" session
                                 (setq my-ghostel--view-counter
                                       (1+ my-ghostel--view-counter))))
           (src (current-buffer))
           (default-directory project)
           (process-environment
            (append (list (concat "PROJECTILE_PROJECT_NAME=" name)
                          (concat "BB_VIEW_SESSION=" view-session))
                    process-environment)))
      ;; The byobu session must exist to group with -- but it lives on the tmux
      ;; server, so this works even with no Emacs terminal currently open for it.
      (unless (eq 0 (call-process "tmux" nil nil nil "has-session"
                                  "-t" (concat "=" session)))
        (user-error "No byobu session for %s yet -- start it first (C-t C-t)" name))
      (select-window (if (eq direction 'below) (split-window-below) (split-window-right)))
      (let ((buffer (ghostel t)))          ; `t' = fresh buffer -> own `*ghostel NAME*<N>'
        (with-current-buffer buffer
          ;; Stamp project + view identity so `my-project-root' and the C-t tab
          ;; launchers resolve to THIS view (switch its own tab, not the main's).
          (setq-local my-ghostel--project project)
          (setq-local my-ghostel--view-session view-session)
          ;; `C-t C-t' from here returns to the buffer we split from.
          (setq-local my-ghostel--return-buffer src)
          ;; Close = reap the view's tmux session + drop this window (deferred),
          ;; reliably from Emacs -- see `my-ghostel--view-cleanup'.
          (add-hook 'kill-buffer-hook #'my-ghostel--view-cleanup nil t)
          ;; A view is throwaway -> `C-x k' shouldn't prompt.  ghostel gates the
          ;; kill via `ghostel-query-before-killing' (a `kill-buffer-query-functions'
          ;; hook), NOT a process flag -- so quiet that, buffer-locally.
          (setq-local ghostel-query-before-killing nil)
          (ghostel-send-string
           (if window (format "bb -g %s\n" (shell-quote-argument window)) "bb -g\n")))
        buffer)))

  (defun my-ghostel-split-view-right (&optional window)
    "Split right into an INDEPENDENT grouped view of this project's byobu session.
DWIM `C-x 3' inside a ghostel terminal: a naive split would show the same PTY in
two windows (torn -- no independent tab/scroll), so open a grouped view instead.
See `my-ghostel-grouped-view'."
    (interactive (list (my-ghostel--read-view-tab)))
    (my-ghostel-grouped-view window 'right))

  (defun my-ghostel-split-view-below (&optional window)
    "Split below into an INDEPENDENT grouped view (DWIM `C-x 2' in a terminal).
See `my-ghostel-split-view-right' / `my-ghostel-grouped-view'."
    (interactive (list (my-ghostel--read-view-tab)))
    (my-ghostel-grouped-view window 'below))

  (defun my-ghostel-collapse-to-main ()
    "Close all of this project's grouped VIEWS and show its main terminal, alone.
A composite of \"kill the secondaries\" + \"bring back the main\": kills every
`my-ghostel-grouped-view' buffer whose grouped session belongs to this project
\(each reaps its own `^vN' tmux session; the persistent base session is never
touched), then shows the base-named `*ghostel P*' terminal in this window and
makes it the sole window.  The undo for fanning out several side-by-side views."
    (interactive)
    (require 'ghostel)
    (let* ((project (my-project-root))
           (name (projectile-project-name project))
           (session (my-byobu--session project))
           (main-name (format "*ghostel %s*" name))
           (killed 0))
      ;; 1. kill the secondaries -- grouped views of THIS project's base session.
      ;;    Each view's `kill-buffer-hook' reaps its own `^vN' session + window.
      (dolist (b (buffer-list))
        (let ((vs (and (buffer-live-p b)
                       (buffer-local-value 'my-ghostel--view-session b))))
          (when (and (stringp vs) (string-prefix-p (concat session "^v") vs))
            (kill-buffer b)
            (setq killed (1+ killed)))))
      ;; 2. bring the main terminal into this window, alone (create it if the base
      ;;    session is up but no Emacs buffer is showing it).
      (let ((main (or (get-buffer main-name)
                      (save-window-excursion (my-project-tab nil)))))
        (when (buffer-live-p main)
          (switch-to-buffer main)
          (delete-other-windows)))
      (message "Collapsed %d view%s into %s" killed (if (= killed 1) "" "s") main-name)))

  (defun my-byobu--windows (project)
    "List of (INDEX NAME ACTIVE) for PROJECT's byobu windows, in tmux order.
Falls back to the default tab names if the session isn't running yet."
    (let ((lines (split-string
                  (with-output-to-string
                    (call-process "tmux" nil standard-output nil "list-windows"
                                  "-t" (concat "=" (my-byobu--session project))
                                  "-F" "#{window_index} #{window_active} #{window_name}"))
                  "\n" t)))
      (if lines
          (mapcar (lambda (l)
                    (let ((p (split-string l " ")))
                      (list (string-to-number (nth 0 p))
                            (string-join (nthcdr 2 p) " ")
                            (equal (nth 1 p) "1"))))
                  lines)
        (seq-map-indexed (lambda (n i) (list i n nil))
                         '("claude" "shell" "git" "test")))))

  (defun my-byobu--labeled (windows)
    "Alist (LABEL . INDEX) for WINDOWS (each (INDEX NAME ACTIVE)).
Clashing names are disambiguated Emacs-style with the tmux index —
\"shell<2>\", \"shell<4>\" — so every window is uniquely selectable even when
tmux folds same-named tabs to one `:name' target."
    (let ((dups (make-hash-table :test 'equal)))
      (dolist (w windows) (puthash (nth 1 w) (1+ (gethash (nth 1 w) dups 0)) dups))
      (mapcar (lambda (w)
                (let ((nm (nth 1 w)) (idx (nth 0 w)))
                  (cons (if (> (gethash nm dups) 1) (format "%s<%d>" nm idx) nm) idx)))
              windows)))

  (defun my-byobu--prefix-sort (cands)
    "Sort CANDS so windows whose name prefixes the current minibuffer input come
first; non-prefix (substring) matches still appear, just ranked lower."
    (let ((input (ignore-errors (minibuffer-contents-no-properties))))
      (if (or (null input) (string-empty-p input))
          cands
        (sort (copy-sequence cands)
              (lambda (a b) (and (string-prefix-p input a t)
                                 (not (string-prefix-p input b t))))))))

  (defun my-byobu--complete (prompt labels require-match initial default)
    "Read a window LABEL, prefix matches ranked first (not exclusive — substring
matches still show, just lower).  See `my-byobu--prefix-sort'."
    (completing-read
     prompt
     (lambda (str pred action)
       (if (eq action 'metadata)
           (list 'metadata (cons 'display-sort-function #'my-byobu--prefix-sort))
         (complete-with-action action labels str pred)))
     nil require-match initial nil default))

  (defun my-byobu-switch-window ()
    "Switch to a byobu window of the current project.
Bound to `C-t <key>' for any key that isn't one of the C- chords:
a digit jumps to that window index (`C-t 3'), unambiguous when names clash;
a letter that uniquely prefixes one window jumps straight there (`C-t g');
otherwise a type-to-filter list seeded by the key, clashing names shown as
`shell<2>'/`shell<4>'.  A name not in the list is created."
    (interactive)
    (let ((seed (let ((e last-command-event))
                  (and (characterp e) (<= ?! e ?~) (char-to-string e)))))
      (if (and seed (string-match-p "\\`[0-9]\\'" seed))
          (my-project-tab (string-to-number seed))
        (let* ((labeled (my-byobu--labeled (my-byobu--windows (my-project-root))))
               (labels (mapcar #'car labeled))
               (hits (and seed (seq-filter (lambda (l) (string-prefix-p seed l t)) labels))))
          (if (and hits (null (cdr hits)))
              (my-project-tab (cdr (assoc (car hits) labeled)))
            (let ((choice (my-byobu--complete "byobu window: " labels nil seed nil)))
              (when (and (stringp choice) (not (string-empty-p choice)))
                (my-project-tab (or (cdr (assoc choice labeled)) choice)))))))))

  (defun my-byobu-new-window (name)
    "Create byobu window NAME in the current project's session and switch to it."
    (interactive "sNew byobu window: ")
    (setq name (string-trim name))
    (unless (string-empty-p name)
      (my-project-tab name)))

  (defun my-byobu-close-window ()
    "Kill a byobu window of the current project, targeted by index.
Defaults to the current window; clashing names are disambiguated by index, so
every window — including duplicate `shell' tabs that are unkillable by name —
can be selected.  (Bound to `C-t C-k'; copy mode is `C-c C-t', no clash.)"
    (interactive)
    (let* ((project (my-project-root))
           (windows (my-byobu--windows project))
           (labeled (my-byobu--labeled windows))
           (current (let ((a (seq-find (lambda (w) (nth 2 w)) windows)))
                      (and a (car (rassoc (nth 0 a) labeled)))))
           (choice (my-byobu--complete "Close byobu window: " (mapcar #'car labeled)
                                       t nil current))
           (idx (cdr (assoc choice labeled))))
      (when (and idx (y-or-n-p (format "Kill byobu window %s? " choice)))
        (call-process "tmux" nil nil nil "kill-window"
                      "-t" (format "=%s:%d" (my-byobu--session project) idx)))))

  (defun my-claude--send-to-tab (text)
    "Bracketed-paste TEXT into the current project's byobu `claude' tab and focus
it (without swapping the current window's buffer, which would hide the fresh
paste).  No project -> ask which running session.  Records the source buffer so
`C-t C-t' returns here.  Shared by the region-cite and buffer-reference commands."
    (let* ((src (current-buffer))
           (root (ignore-errors (projectile-project-root default-directory)))
           (session
            (or (and root (my-byobu--session root))
                (let ((ss (seq-filter
                           (lambda (s) (string-prefix-p "projectile/" s))
                           (split-string
                            (with-output-to-string
                              (call-process "tmux" nil standard-output nil
                                            "list-sessions" "-F" "#{session_name}"))
                            "\n" t))))
                  (unless ss (user-error "No project byobu sessions running"))
                  (completing-read "Send to session: " ss nil t))))
           (target (concat "=" session ":claude")))
      (unless (zerop (call-process "tmux" nil nil nil "select-window" "-t" target))
        (user-error "No `claude' tab in %s (open it with C-t C-c)" session))
      (unless root (setq my-ghostel--cited-session session)) ; sticky association
      (with-temp-buffer
        (insert text)
        (call-process-region (point-min) (point-max) "tmux" nil nil nil
                             "load-buffer" "-b" "emacs-cite" "-"))
      (call-process "tmux" nil nil nil
                    "paste-buffer" "-d" "-p" "-b" "emacs-cite" "-t" target)
      (let* ((gbuf (my-byobu--ghostel-buffer session))
             (win (and gbuf (get-buffer-window gbuf))))
        (when (and gbuf (not (provided-mode-derived-p
                              (buffer-local-value 'major-mode src) 'ghostel-mode)))
          (with-current-buffer gbuf (setq-local my-ghostel--return-buffer src)))
        (cond (win  (select-window win))       ; byobu visible -> refocus, no swap
              (root (my-project-tab "claude"))  ; not visible -> open project claude
              (gbuf (pop-to-buffer gbuf))))))   ; ask-path, hidden -> reveal

  (defun my-send-region-to-claude (start end)
    "Cite the region to the project's byobu `claude' tab (single line as inline
code, multi-line as a fenced block), then focus the claude tab to add a question.
No project -> ask which running session.  Bound to `C-t C-y'."
    (interactive "r")
    (unless (use-region-p) (user-error "Select a region first"))
    (let ((sel (buffer-substring-no-properties start end)))
      (my-claude--send-to-tab
       (if (string-match-p "\n" sel) (concat "```\n" sel "\n```\n") (concat "`" sel "`"))))
    (deactivate-mark)
    (message "Cited region to claude"))

  (defun my-cite-buffer-to-claude ()
    "Pick a buffer (`C-x b'-style) and send a *reference* to it -- a path Claude
can Read, not the pasted content -- to the project's claude tab, then focus it.
A saved, unmodified file gives its real path; anything else a live snapshot.
Bound to `C-t C-b': the no-jank way to point Claude at a specific buffer (the
picker runs natively in Emacs, not via a remote `read-buffer')."
    (interactive)
    (let* ((name (read-buffer "Reference buffer to Claude: " nil t))
           (path (my-ebuffer-ref name)))
      (my-claude--send-to-tab (format "Please Read this buffer for me: %s\n" path))
      (message "Referenced %s to claude" name)))

  (defun my-projectile--byobu-window (session)
    "Return the active tmux window name in SESSION (\"\" if not running)."
    (string-trim
     (shell-command-to-string
      (format "tmux display -p -t '=%s' '#{window_name}' 2>/dev/null" session))))

  (defun my-projectile--byobu-ensure-window (session window dir cmd &optional tries)
    "Select tmux WINDOW in SESSION, creating it (in DIR, running CMD) if absent.
Polls because a fresh `bb' session spawns asynchronously; the attached
ghostel buffer redraws whichever tab ends up selected."
    (let ((tries (or tries 12))
          (tgt (format "=%s:%s" session window)))
      (cond
       ((<= tries 0) nil)
       ;; Session not up yet (fresh bb still spawning) -> wait and retry.
       ((not (zerop (call-process "tmux" nil nil nil "has-session" "-t"
                                  (format "=%s" session))))
        (run-at-time 0.25 nil #'my-projectile--byobu-ensure-window
                     session window dir cmd (1- tries)))
       ;; Window exists -> select it.
       ((zerop (call-process "tmux" nil nil nil "select-window" "-t" tgt)) nil)
       ;; Window missing, but a fresh `bb' may still be spawning its default tabs
       ;; (claude/shell/git/test one by one) -> keep WAITING rather than racing bb
       ;; into a duplicate window.  Only fall through to create as a last resort,
       ;; for a genuinely custom tab bb never makes.
       ((> tries 2)
        (run-at-time 0.25 nil #'my-projectile--byobu-ensure-window
                     session window dir cmd (1- tries)))
       ;; Still missing after the wait -> create, pin name, run CMD, select.
       (t
        (call-process "tmux" nil nil nil "new-window" "-t" (format "=%s" session)
                      "-n" window "-c" dir)
        (call-process "tmux" nil nil nil "set-window-option" "-t" tgt
                      "automatic-rename" "off")
        (call-process "tmux" nil nil nil "set-window-option" "-t" tgt
                      "allow-rename" "off")
        (when (and cmd (not (string-empty-p cmd)))
          (call-process "tmux" nil nil nil "send-keys" "-t" tgt cmd "Enter"))))))

  (defun my-ghostel-toggle-terminal ()
    "Toggle between your code and THIS project's byobu terminal.
From a ghostel terminal, return to the exact buffer you jumped from (not
the window's previous buffer, which may belong to another project).  From
code, switch to the current project's terminal buffer (its active tab),
remembering this buffer to come back to."
    (interactive)
    (if (derived-mode-p 'ghostel-mode)
        (if (and (buffer-live-p my-ghostel--return-buffer)
                 (not (eq my-ghostel--return-buffer (current-buffer))))
            (switch-to-buffer my-ghostel--return-buffer)
          ;; No recorded return buffer (entered via session-restore, or the code
          ;; buffer was killed) -> open THIS project's dired: a deterministic,
          ;; same-project landing.  Never fall through to `switch-to-prev-buffer',
          ;; which is project-blind and surfaced another project's terminal.
          (let ((root (or (and (stringp my-ghostel--project) my-ghostel--project)
                          default-directory)))
            (if (and root (file-directory-p root))
                (dired root)
              (switch-to-prev-buffer (selected-window) 1))))
      (let* ((src (current-buffer))
             (root (ignore-errors
                     (let ((projectile-project-root-cache (make-hash-table :test 'equal)))
                       (projectile-project-root default-directory))))
             ;; unprojected buffer that cited somewhere -> its sticky terminal
             (cited (and (not root) my-ghostel--cited-session
                         (my-byobu--ghostel-buffer my-ghostel--cited-session))))
        (cond (cited (my-ghostel--enter-from cited src))
              (root  (let ((buf (get-buffer (projectile-generate-process-name
                                             "ghostel" nil root))))
                       (if buf (my-ghostel--enter-from buf src) (my-project-tab nil))))
              (t     (my-project-tab nil))))))               ; prompt (open projects first)

  (defun my-ghostel-open-referenced-file ()
    "Open a file Claude referenced in the visible terminal.
Scans the visible region for tool forms -- `Write(path)' / `Edit(path)' /
`Read(path)' / `Update(path)' etc. -- and opens the one you pick (or the only
one) in the other window, resolved against the terminal's directory.  A robust
stand-in for clicking, since the TUI owns the mouse.  Bound to `C-t C-f'.

(For `path:line' / `path:line:col' references, ghostel linkifies those itself --
click or RET on one and it jumps to the line; see `ghostel--open-link'.)"
    (interactive)
    (let* ((text (buffer-substring-no-properties (window-start) (window-end nil t)))
           (re (concat "\\_<\\(?:Write\\|Edit\\|Read\\|Update\\|Create\\|"
                       "MultiEdit\\|NotebookEdit\\)(\\([^),\n]+\\)"))
           (paths nil) (pos 0))
      (while (string-match re text pos)
        (push (string-trim (match-string 1 text)) paths)
        (setq pos (match-end 1)))
      (setq paths (delete-dups paths))   ; most-recent (bottom of screen) first
      (let ((choice (cond ((null paths) (user-error "No file references on screen"))
                          ((null (cdr paths)) (car paths))
                          (t (completing-read "Open referenced file: " paths nil nil)))))
        ;; open in THIS window (no surprise split); C-t C-t toggles back.
        (find-file (expand-file-name choice default-directory)))))

  (defun my-ebuffer-ref (&optional which)
    "Return a file path whose contents represent a buffer, for the `ebuffer'
script -- so Claude can Read the buffer you mean without you pasting it.
WHICH is nil for the byobu return buffer (\"this/that/the buffer\"), or a
buffer-name string.  A saved, unmodified file buffer yields its own path;
anything else (unsaved edits, a non-file buffer) is snapshotted to a temp file
first.  (To *pick* a buffer, the user runs `C-t C-b' in Emacs -- no remote
`read-buffer' here, which tangled with the terminal.)"
    (let ((buf (cond ((and (stringp which) (not (string-empty-p which)))
                      (get-buffer which))
                     (t (and (buffer-live-p my-ghostel--return-buffer)
                             my-ghostel--return-buffer)))))
      (unless (buffer-live-p buf)
        (user-error "ebuffer: no buffer (the user can pick one with C-t C-b)"))
      (with-current-buffer buf
        (if (and buffer-file-name (not (buffer-modified-p)))
            buffer-file-name
          (let ((tmp (expand-file-name
                      (concat "ebuffer-"
                              (replace-regexp-in-string "[^A-Za-z0-9._-]+" "_" (buffer-name)))
                      temporary-file-directory)))
            (write-region (point-min) (point-max) tmp nil 'silent)
            tmp)))))

  ;; --- "task done, come back" notice -------------------------------------------
  ;; `esay' messages vanish on the next echo; this one persists in the frame
  ;; title (WM bar, visible even when Emacs is unfocused) and the mode line until
  ;; you return to a terminal.  The `enotify' script calls `my-claude-notify'.
  (defvar my-claude--notice nil
    "Pending \"Claude is ready\" notice, shown in the frame title and mode line
until you next select a terminal.  Set by `my-claude-notify' / `enotify'.")

  (defun my-claude-notify (&optional msg)
    "Raise a persistent notice (frame title + mode-line flag + an echo line) that
a background/long task finished, so you can switch back.  Cleared automatically
when you next select a terminal buffer."
    (interactive)
    (setq my-claude--notice (or msg "ready"))
    (force-mode-line-update t)
    (message "🔔 Claude: %s" my-claude--notice))

  (defun my-claude-clear-notice (&rest _)
    "Clear `my-claude--notice' (frame title + mode-line flag)."
    (interactive)
    (when my-claude--notice
      (setq my-claude--notice nil)
      (force-mode-line-update t)))

  (defun my-claude--clear-on-terminal (&rest _)
    "Clear the notice once a terminal is the selected window (you came back)."
    (when (and my-claude--notice
               (provided-mode-derived-p
                (buffer-local-value 'major-mode (window-buffer (selected-window)))
                'ghostel-mode))
      (my-claude-clear-notice)))
  (add-hook 'window-selection-change-functions #'my-claude--clear-on-terminal)

  (defun my-claude--clear-on-terminal-input ()
    "Clear the notice once you act inside a terminal — typing, or switching byobu
tabs with `C-t C-s' (e.g. to run an `esh'-queued sudo command), doesn't change
the selected Emacs window, so `window-selection-change-functions' alone misses
it.  Guarded on the notice being set, so it's a cheap no-op the rest of the time."
    (when (and my-claude--notice (derived-mode-p 'ghostel-mode))
      (my-claude-clear-notice)))
  (add-hook 'post-command-hook #'my-claude--clear-on-terminal-input)

  ;; Persist the notice on the frame title and the mode line (both clear with it).
  (setq frame-title-format
        '((my-claude--notice (:eval (concat "🔔 " my-claude--notice "  —  ")))
          (multiple-frames "%b" ("" "%b - GNU Emacs at " system-name))))
  (add-to-list 'global-mode-string
               '(my-claude--notice
                 (:eval (propertize (concat "🔔 " my-claude--notice " ") 'face 'warning)))
               t)

  ;; C-t is a real PREFIX keymap (not a command — a command can't host a chord).
  ;; C-t C-t toggles code<->this project's terminal; C-t C-c/C-g/C-s pick a tab.
  ;; (A C-g *after* the C-t prefix is a normal key, not a quit, so it binds fine.)
  (defvar my-ghostel-prefix-map
    (let ((map (make-sparse-keymap)))
      ;; C- chords = direct actions (C-t toggles back to your code).
      (define-key map (kbd "C-t") #'my-ghostel-toggle-terminal)
      (define-key map (kbd "C-c") #'my-project-tab-claude)
      (define-key map (kbd "C-g") #'my-project-tab-git)
      (define-key map (kbd "C-s") #'my-project-tab-shell)
      (define-key map (kbd "C-u") #'my-project-tab-sudo)    ; jump to esh's sudo window
      (define-key map (kbd "C-n") #'my-byobu-new-window)    ; new window (ask name)
      (define-key map (kbd "C-k") #'my-byobu-close-window)  ; close (default: current)
      (define-key map (kbd "C-y") #'my-send-region-to-claude) ; cite region to claude
      (define-key map (kbd "C-f") #'my-ghostel-open-referenced-file) ; open file Claude referenced
      (define-key map (kbd "C-b") #'my-cite-buffer-to-claude)        ; reference a buffer to claude
      (define-key map (kbd "C-w") #'my-copy-file-path-with-line)     ; kill `path:line:col' at point
      ;; Any other key (a plain letter) -> type-to-filter window switch, seeded
      ;; with that key: C-t t -> test, C-t <type a name> -> that window.  So the
      ;; mnemonic chords are kept AND every window (incl. test/custom) is one
      ;; C-t-then-type away — nothing sacrificed.
      (define-key map [t] #'my-byobu-switch-window)
      map)
    "Prefix map bound to \\`C-t' (in the global map and `ghostel-mode-map').")
  :custom
  ;; Fast, INTERRUPTIBLE project indexing.  `alien' shells out to git -- skips
  ;; gitignored dirs (a huge `build/'), respects .gitignore -- instead of a
  ;; native elisp walk that ignores C-g (that walk hard-froze Emacs on a
  ;; 51-submodule C++ repo).  Cache the file list; and DON'T recurse the 51
  ;; submodules (their files aren't wanted in the project list, and enumerating
  ;; them is the slow part).
  (projectile-indexing-method 'alien)
  (projectile-enable-caching t)
  (projectile-git-submodule-command "")
  :config
  (global-set-key (kbd "C-t") my-ghostel-prefix-map)

  ;; ...but a major mode's own map beats the global one, and `dired-mode-map' binds
  ;; C-t as the image-dired prefix (C-t d thumbnails, C-t t tag, ...).  Emacs
  ;; composes the two with image-dired's FIRST, so from dired every key image-dired
  ;; defines shadows ours: `C-t C-t' toggled marked thumbnails instead of jumping to
  ;; the terminal, and the letters it claims (d a e f c i j r t x .) swallowed the
  ;; type-to-filter window switch -- `C-t t' for the *test* tab among them.  Take the
  ;; prefix over in dired, and move image-dired's out to `C-c t' rather than dropping
  ;; it on the floor.
  (with-eval-after-load 'dired
    (let ((image-dired-map (lookup-key dired-mode-map (kbd "C-t"))))
      (when (keymapp image-dired-map)
        (define-key dired-mode-map (kbd "C-c t") image-dired-map)))
    (define-key dired-mode-map (kbd "C-t") my-ghostel-prefix-map))
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1)
  (setq projectile-mode-line-function '(lambda () (format " Π[%s]" (projectile-project-name)))))

(use-package all-the-icons)

(use-package company
  :diminish company-mode
  :custom
  (company-minimum-prefix-length 1)
  :config
  (company-tng-mode)
  (global-company-mode t))

(use-package dashboard
  :custom
  (dashboard-items
   '((recents . 30)
     (bookmarks . 5)
     (projects . 15)
     (registers . 5)))
  ;; This config drives projects through projectile (bb, the C-t launchers,
  ;; `my-project-root'); the default `project-el' backend has an empty list here,
  ;; so the Projects section showed nothing.  Read from projectile instead.
  (dashboard-projects-backend 'projectile)
  :config
  (dashboard-setup-startup-hook))

(use-package undo-fu
  :custom
  (undo-fu-allow-undo-in-region t)
  :config
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z") 'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo))

(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :bind
  (("M-A" . marginalia-cycle)
   :map minibuffer-local-map
   ("M-A" . marginalia-cycle))
  :config
  (marginalia-mode))

(use-package consult)

(use-package iedit
  :bind
  ("C-;" . iedit-mode)
  (:map isearch-mode-map
        ("C-;" . iedit-mode-from-isearch))
  (:map esc-map
        ("C-;" . iedit-execute-last-modification))
  (:map help-map
        ("C-;" . iedit-mode-toggle-on-function)))

(use-package ghostel
  :init
  (defun er-switch-to-previous-buffer ()
    "Switch to previously open buffer."
    (interactive)
    (switch-to-prev-buffer (selected-window) 1))
  (defun my-ghostel--name-by-project (_title)
    "Deterministic ghostel buffer name — one naming path for every terminal.
Ignores the OSC-2 TITLE (byobu/shells set noisy titles that used to rename the
buffer) and names by the buffer's project instead, derived from
`default-directory'.  So a terminal keeps a stable `*ghostel PROJECT*' name
however it was created — the `C-t' launchers, session restore, or a bare
`M-x ghostel' all converge on the same name (a second terminal in one project
just gets a `<2>' suffix).  This is what makes save/restore match reliably."
    (let* ((root (or (ignore-errors (projectile-project-root default-directory))
                     default-directory))
           (name (or (ignore-errors (projectile-project-name root))
                     (abbreviate-file-name (directory-file-name root)))))
      (format "*ghostel %s*" name)))
  :custom
  ;; One naming path: name every terminal by its project, ignoring OSC-2 title
  ;; noise (byobu/shells).  Keeps the name fixed per project (the old intent)
  ;; AND canonicalises buffers made by any path, so `window-state' save/restore
  ;; always matches.  (Was `ghostel-set-title-function nil', which only disabled
  ;; renaming and so let divergent names — e.g. `*ghostel ~/.emacs.d/*' — persist.)
  (ghostel-buffer-name-function #'my-ghostel--name-by-project)
  ;; Rendering for Claude Code (run directly in ghostel via C-t C-c).  Ink does
  ;; aggressive partial screen updates and emits >256 bytes per keystroke, so the
  ;; default incremental path + 256-byte immediate-redraw budget defers the frame
  ;; to the idle timer — making a typed space appear only on the next keystroke.
  ;;   * full-redraw t        — robust with Claude Code's partial updates (per the
  ;;                            option's own docs); costs a little more CPU.
  ;;   * larger redraw budget — treat bigger per-key echoes as interactive and
  ;;                            redraw them immediately instead of on the timer.
  (ghostel-full-redraw t)
  (ghostel-immediate-redraw-threshold 16384)
  (ghostel-immediate-redraw-interval 0.1)
  ;; Honor OSC 52 clipboard writes from programs in the terminal so a mouse
  ;; selection inside byobu/tmux (which forwards the drag to tmux, not ghostel's
  ;; own copy-mode) lands in the Emacs kill ring + system clipboard.  Paired with
  ;; `set-clipboard on' in ~/.config/byobu/.tmux.conf.  ghostel's freeze-the-grid
  ;; copy-mode (C-c C-t) can't be used here — it unpins tmux's alt-screen status
  ;; line.  Off by default for security; we accept the risk for the clipboard win.
  (ghostel-enable-osc52 t)
  ;; Don't freeze the terminal into copy mode just because point left the live
  ;; prompt.  Default is `copy': an isearch through the scrollback (which lands
  ;; point away from the cursor) flips the whole terminal read-only, and since a
  ;; terminal is where you TYPE, you then hit "Buffer is read-only" on the next
  ;; keystroke.  nil keeps semi-char input alive; deliberate copy gestures (mouse
  ;; drag, an activated region) still enter copy mode via their own settings.
  (ghostel-point-leave-input-mode nil)
  ;; Let C-t pass through to Emacs instead of being sent to the shell, so our
  ;; C-t prefix (toggle / tab switch, bound in `ghostel-mode-map') works inside
  ;; the terminal.  Without this, ghostel's semi-char input map forwards C-t to
  ;; the PTY.  (The :set on this defcustom rebuilds the input keymap.)
  (ghostel-keymap-exceptions '("C-c" "C-x" "C-u" "C-h" "M-x" "M-:" "C-\\" "C-t"
                               "C-<up>" "C-<down>" "C-<left>" "C-<right>"))
  :custom-face
  ;; The installed ghostel palette inherits `ansi-color-*' (red3, green3, …),
  ;; but the theme customizes `term-color-*'.  Point the palette at the themed
  ;; faces — same trick the old vterm-color-* faces used — so the terminal uses
  ;; the Emacs theme colors.  ghostel reads each face's :foreground.
  (ghostel-color-black          ((t (:inherit term-color-black))))
  (ghostel-color-red            ((t (:inherit term-color-red))))
  (ghostel-color-green          ((t (:inherit term-color-green))))
  (ghostel-color-yellow         ((t (:inherit term-color-yellow))))
  (ghostel-color-blue           ((t (:inherit term-color-blue))))
  (ghostel-color-magenta        ((t (:inherit term-color-magenta))))
  (ghostel-color-cyan           ((t (:inherit term-color-cyan))))
  (ghostel-color-white          ((t (:inherit term-color-white))))
  (ghostel-color-bright-black   ((t (:inherit term-color-black))))
  (ghostel-color-bright-red     ((t (:inherit term-color-red))))
  (ghostel-color-bright-green   ((t (:inherit term-color-green))))
  (ghostel-color-bright-yellow  ((t (:inherit term-color-yellow))))
  (ghostel-color-bright-blue    ((t (:inherit term-color-blue))))
  (ghostel-color-bright-magenta ((t (:inherit term-color-magenta))))
  (ghostel-color-bright-cyan    ((t (:inherit term-color-cyan))))
  (ghostel-color-bright-white   ((t (:inherit term-color-white))))
  :config
  ;; ghostel-max-scrollback defaults to 5MB — fine as-is.
  ;; C-t inside a terminal is the same prefix as everywhere else: C-t C-t toggles
  ;; back to your code, C-t C-c/g/s pick a byobu tab.
  (define-key ghostel-mode-map [?\C-t] my-ghostel-prefix-map)
  (define-key ghostel-mode-map [M-w] #'kill-ring-save)
  (define-key ghostel-mode-map (kbd "M-w") #'kill-ring-save)
  (define-key ghostel-mode-map [C-up] (ignore-error-wrapper 'windmove-up))
  (define-key ghostel-mode-map [C-down] (ignore-error-wrapper 'windmove-down))
  (define-key ghostel-mode-map [C-left] (ignore-error-wrapper 'windmove-left))
  (define-key ghostel-mode-map [C-right] (ignore-error-wrapper 'windmove-right))
  ;; C-x 2 / C-x 3 in a terminal DWIM into a grouped VIEW: a naive split would show
  ;; the same PTY in two windows (torn -- no independent tab/scroll), so split into
  ;; a fresh grouped-view buffer instead.  (C-x is in `ghostel-keymap-exceptions',
  ;; so it reaches Emacs.)  C-x 1 / C-x 0 stay stock (window ops, not closes).
  (define-key ghostel-mode-map (kbd "C-x 3") #'my-ghostel-split-view-right)
  (define-key ghostel-mode-map (kbd "C-x 2") #'my-ghostel-split-view-below))

(use-package windmove
  :config
  (global-set-key [C-left] (ignore-error-wrapper 'windmove-left))
  (global-set-key [C-right] (ignore-error-wrapper 'windmove-right))
  (global-set-key [C-up] (ignore-error-wrapper 'windmove-up))
  (global-set-key [C-down] (ignore-error-wrapper 'windmove-down)))

(use-package posframe)

(use-package diff-hl
  :after posframe
  :custom
  (diff-hl-global-modes '(not image-mode))
  (diff-hl-show-hunk-function 'diff-hl-show-hunk-posframe)
  :custom-face
  (diff-hl-change ((t (:background "#333355" :foreground "DeepSkyBlue1"))))
  (diff-hl-delete ((t (:inherit diff-removed :foreground "red1"))))
  (diff-hl-insert ((t (:inherit diff-added :foreground "green1"))))
  :config
  (global-diff-hl-mode t)
  (global-diff-hl-show-hunk-mouse-mode t)
  (diff-hl-flydiff-mode 1))

(use-package diminish
  :diminish
  abbrev-mode
  org-indent-mode
  apheleia-mode
  auto-revert-mode
  hungry-delete-mode
  hungry-delete
  lisp-interaction-mode
  visual-line-mode
  subword-mode
  auto-fill-function
  gcmh-mode
  auto-sudoedit-mode)

(use-package delight
  :config
  (delight '((company-mode nil company)
             (abbrev-mode nil abbrev)
             (eldoc-mode nil eldoc)
             (flyspell-mode nil flyspell)
             (paredit-mode nil paredit)
             (rainbow-mode nil rainbow-mode)
             (yas-minor-mode nil yasnippet)
             (page-break-lines-mode nil page-break-lines)
             (auto-revert-mode nil auto-revert))))

(use-package eglot
  :commands lsp
  :custom
  ;; Don't let servers reformat as you type: clangd (and others) advertise
  ;; on-type formatting with `\n' as a trigger, so pressing RET reformats the
  ;; line you just finished -- e.g. collapsing tab-aligned struct columns.
  (eglot-ignored-server-capabilities '(:documentOnTypeFormattingProvider))
  ;; Stop logging the LSP wire protocol.  By default eglot pretty-prints EVERY
  ;; JSON-RPC message into a 2000-event ring buffer, PER SERVER -- with clangd on
  ;; OrioleDB/Postgres that is continuous consing and GC pressure for a buffer
  ;; nobody reads.  `:size 0' turns it off; set it back to e.g. 2000 when actually
  ;; debugging a server.
  (eglot-events-buffer-config '(:size 0 :format short))
  ;; Don't leave a clangd (or pyright, or ...) running with no buffers to serve.
  (eglot-autoshutdown t)
  ;; Batch keystrokes before telling the server about them: the default (0.5s in
  ;; recent eglot, but it has changed) is what we want explicitly -- no didChange
  ;; storm per keypress on a big C file.
  (eglot-send-changes-idle-time 0.5)
  :hook
  ((elixir-mode elixir-ts-mode heex-ts-mode) . eglot-ensure)
  (erlang-mode . eglot-ensure)
  (go-mode . eglot-ensure)
  (sh-mode . eglot-ensure)
  ((typescript-ts-mode tsx-ts-mode js-ts-mode) . eglot-ensure)
  (python-ts-mode . eglot-ensure)
  ((css-ts-mode web-mode) . eglot-ensure)
  ((cmake-ts-mode cmake-mode) . eglot-ensure)
  ((c-mode c-ts-mode c++-mode c++-ts-mode) . eglot-ensure)
  (sql-mode . eglot-ensure)
  :config
  ;; Servers eglot doesn't know by default (it already knows
  ;; typescript-language-server, pyright, cmake-language-server).
  (add-to-list 'eglot-server-programs
               '((elixir-ts-mode heex-ts-mode elixir-mode)
                 "/home/dead/bin/elixir-ls/language_server.sh"))
  (add-to-list 'eglot-server-programs '(erlang-mode "/home/dead/bin/elp" "server"))
  (add-to-list 'eglot-server-programs '(sql-mode "sqls"))
  ;; Tailwind LSP for templates/CSS (class completion + linting).
  (add-to-list 'eglot-server-programs
               '((web-mode css-ts-mode css-mode html-mode html-ts-mode mhtml-mode)
                 "tailwindcss-language-server" "--stdio"))
  (add-to-list 'recentf-exclude "\\*EGLOT ")
  (with-eval-after-load 'consult
    (add-to-list 'consult-buffer-filter "\\*EGLOT "))
  (setq eldoc-echo-area-prefer-doc-buffer t
        eldoc-echo-area-use-multiline-p nil))

;; ---------------------------------------------------------------------------
;; Modern language setups.  Pattern (matching rust above): built-in tree-sitter
;; modes + eglot (servers hooked in the `eglot' block) + apheleia format-on-save.
;; LSP servers/runtimes are installed via mise (node/erlang/elixir) + go/pip.
;; ---------------------------------------------------------------------------

;; BEAM: Elixir (+ HEEx templates) and Erlang.  elixir-ts-mode/heex-ts-mode are
;; built-in tree-sitter modes; elixir-mode stays as a fallback.
(use-package elixir-ts-mode
  :ensure nil
  :mode (("\\.exs?\\'" . elixir-ts-mode)
         ("mix\\.lock\\'" . elixir-ts-mode)
         ("\\.heex\\'" . heex-ts-mode)))

(use-package elixir-mode :defer t)

(use-package erlang
  :mode (("\\.erl\\'" . erlang-mode)
         ("\\.hrl\\'" . erlang-mode)
         ("\\(rebar\\.config\\|relx\\.config\\|sys\\.config\\)\\'" . erlang-mode)))

;; TypeScript / JavaScript / React.  The tsx grammar parses JSX, so .jsx/.tsx
;; both use tsx-ts-mode; plain .js/.ts use the ts-modes when grammars are ready.
(use-package typescript-ts-mode
  :ensure nil
  :mode (("\\.ts\\'"  . typescript-ts-mode)
         ("\\.mts\\'" . typescript-ts-mode)
         ("\\.cts\\'" . typescript-ts-mode)
         ("\\.tsx\\'" . tsx-ts-mode)
         ("\\.jsx\\'" . tsx-ts-mode)))

(use-package js
  :ensure nil
  :init
  (when (and (require 'treesit nil t) (treesit-ready-p 'javascript t))
    (dolist (m '((js-mode . js-ts-mode) (javascript-mode . js-ts-mode)))
      (add-to-list 'major-mode-remap-alist m))))

;; Python — remap to the built-in tree-sitter mode; server is pyright (eglot
;; default), formatting is ruff (set in the apheleia block).
(use-package python
  :ensure nil
  :init
  (when (and (require 'treesit nil t) (treesit-ready-p 'python t))
    (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))))

;; CSS -> css-ts-mode; CMake -> built-in cmake-ts-mode.
(use-package css-mode
  :ensure nil
  :init
  (when (and (require 'treesit nil t) (treesit-ready-p 'css t))
    (add-to-list 'major-mode-remap-alist '(css-mode . css-ts-mode))))

(use-package cmake-ts-mode
  :ensure nil
  :mode (("CMakeLists\\.txt\\'" . cmake-ts-mode)
         ("\\.cmake\\'" . cmake-ts-mode)))

;; C / C++ -> built-in tree-sitter modes; server is clangd (eglot default),
;; formatting is clang-format (apheleia default for these modes).
(use-package cc-mode
  :ensure nil
  :custom
  (c-basic-offset 4)            ; indent step for the classic c-mode / c++-mode
  (c-ts-mode-indent-offset 4)   ; indent step for c-ts-mode / c++-ts-mode
  :hook ((c-mode-common c-ts-base-mode) . (lambda () (setq tab-width 4)))
  :init
  (when (and (require 'treesit nil t) (treesit-ready-p 'c t))
    (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode)))
  (when (and (require 'treesit nil t) (treesit-ready-p 'cpp t))
    (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))))

;; SQL — keep the built-in sql-mode (interactive REPLs to psql/sqlite/…) and add
;; smart indentation; the LSP server is sqls (registered in the `eglot' block).
(use-package sql-indent
  :hook (sql-mode . sqlind-minor-mode))

;; Emmet abbreviations (C-j to expand) in markup/CSS/JSX buffers.
(use-package emmet-mode
  :hook ((web-mode html-mode html-ts-mode mhtml-mode css-mode css-ts-mode
          tsx-ts-mode) . emmet-mode))

;; Format on save.  apheleia ships the formatter defs: prettier for
;; js/ts/tsx/css/html/json, ruff for Python, etc.  Runs async, off the main
;; buffer, so saves stay snappy.
(use-package apheleia
  :diminish apheleia-mode
  :hook (after-init . apheleia-global-mode)
  :config
  ;; Use ruff (installed) for Python instead of the default black.
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff)
        (alist-get 'python-mode    apheleia-mode-alist) '(ruff-isort ruff))
  ;; shfmt for shell scripts -- gofmt-for-shell.  apheleia already maps
  ;; `bash-ts-mode'; add plain `sh-mode', which is what the extensionless helper
  ;; scripts (esh, etab, oriole-pgindent, ...) open in.  apheleia passes shfmt NO
  ;; style flags on purpose: style comes from `.editorconfig' (4-space indent,
  ;; indented `case' branches -- see this repo's .editorconfig).
  (add-to-list 'apheleia-mode-alist '(sh-mode . shfmt))
  ;; No format-on-save for C/C++: clang-format ignores Emacs's indent vars and
  ;; reformats aggressively, fighting the 4-space editor indent.  Add a project
  ;; .clang-format if you want full formatting there.
  (dolist (m '(c-mode c++-mode c-ts-mode c++-ts-mode))
    (setq apheleia-mode-alist (assq-delete-all m apheleia-mode-alist)))
  ;; ...but DO format OrioleDB C on save with pgindent -- its canonical formatter,
  ;; gofmt-style.  `oriole-pgindent' wraps pgindent (a perl+pg_bsd_indent tool) as
  ;; a stdin->stdout filter.  Scope it to OrioleDB C/H by file PATH, resolved at
  ;; SAVE time from `apheleia-mode-alist' -- not a mode hook, which would miss
  ;; files session-restore reopens before this block has run.  (`apheleia-global-
  ;; mode' turns `apheleia-mode' on; the formatter is looked up here.)  Needs
  ;; `pgindent'/`pg_bsd_indent' on PATH and a repo `orioledb.typedefs'.
  (setf (alist-get 'oriole-pgindent apheleia-formatters)
        '("oriole-pgindent" filepath))   ; buffer content on stdin, path as $1
  (add-to-list 'apheleia-mode-alist '("/orioledb/.*\\.[ch]\\'" . oriole-pgindent))
  ;; ...and yapf for OrioleDB Python (that's `make USE_PGXS=1 yapf'), same
  ;; per-path scoping so it beats the global ruff formatter for oriole .py only.
  ;; `oriole-yapf' runs yapf with the repo's `.style.yapf'; needs yapf on PATH.
  (setf (alist-get 'oriole-yapf apheleia-formatters) '("oriole-yapf" filepath))
  (add-to-list 'apheleia-mode-alist '("/orioledb/.*\\.py\\'" . oriole-yapf)))

;; Respect per-project `.editorconfig' (built-in since Emacs 30).  Lets a repo
;; set editor-side indentation by filename glob regardless of major mode -- e.g.
;; OrioleDB's `.editorconfig' switches its C files to tab indentation (Postgres
;; style) so typing there doesn't fight pgindent.
(use-package editorconfig
  :ensure nil
  :hook (after-init . editorconfig-mode))

;; Tame mouse-wheel acceleration, decoupled from `double-click-time'.  With
;; `mouse-wheel-progressive-speed' on, mwheel multiplies each notch by the event
;; click-count -- but its timing threshold is `double-click-time' (500ms), so
;; almost any spin accelerates (little room for slow, deliberate scrolling) and
;; it squares up too fast.  Replace that multiplier with our own: only notches
;; closer together than `my-wheel-accel-window' accelerate, capped at
;; `my-wheel-accel-cap'.  So a slow spin stays 1x; only a fast spin ramps up.
;; Real mouse clicks fall through untouched.  (Pixel-smooth needs XInput2/PGTK.)
(defvar my-wheel-accel-cap 2
  "Maximum mouse-wheel acceleration factor (ceiling on the speed-up).")
(defvar my-wheel-accel-window 0.1
  "Seconds between wheel notches that still count as a fast spin.  SMALLER = more
room for slow scrolling (you must spin faster to accelerate); larger ramps up
more readily.")
(defvar my-wheel--accel-last nil "Internal: time of the previous wheel notch.")
(defvar my-wheel--accel-mult 1 "Internal: current acceleration multiplier.")
(define-advice event-click-count (:around (orig event) my-cap-wheel-accel)
  "Time-based, capped wheel-scroll acceleration; real clicks use the original."
  (if (memq (event-basic-type event)
            '(wheel-up wheel-down wheel-left wheel-right
              mouse-4 mouse-5 mouse-6 mouse-7))
      (let ((now (float-time)))
        (if (and my-wheel--accel-last
                 (< (- now my-wheel--accel-last) my-wheel-accel-window))
            (setq my-wheel--accel-mult (min (1+ my-wheel--accel-mult) my-wheel-accel-cap))
          (setq my-wheel--accel-mult 1))
        (setq my-wheel--accel-last now)
        my-wheel--accel-mult)
    (funcall orig event)))

(use-package bazel)

(use-package grip-mode
  :bind (:map markdown-mode-command-map
              ("g" . grip-mode)))

(use-package dired-subtree
  :after dired
  :config
  (define-key dired-mode-map (kbd "<tab>") 'dired-subtree-toggle))

(use-package origami
  ;; Bind via :commands/global-set-key so the keybinding does not depend on the
  ;; package's :config block running to completion.
  :commands (origami-toggle-node origami-mode)
  :init
  (global-set-key [C-tab] 'origami-toggle-node))

(use-package gcmh
  :diminish gcmh-mode
  :config
  ;; The startup GC threshold is raised in early-init.el (with a fail-safe there
  ;; in case this package ever fails to load); from here on gcmh owns it.
  (gcmh-mode 1))

;; Don't wedge on a long-lines file.  A minified blob, a generated header, one
;; 200k-character line in a log -- Emacs's regexp-based font-lock and bidi are
;; superlinear in line length, and a single such line can hang the whole editor
;; with C-g unable to help.  `so-long' detects it and defangs the expensive modes.
(use-package so-long
  :ensure nil
  :custom
  ;; A "long line" here is 400+ chars; only look at the first 100 lines to decide.
  (so-long-threshold 400)
  (so-long-max-lines 100)
  ;; `so-long-minor-mode' over the default `so-long-mode': it keeps the buffer
  ;; USABLE (major mode, and thus font-lock and treesit, stay) and just disables
  ;; the modes that actually cost you, instead of dumping you into fundamental-mode.
  (so-long-action 'so-long-minor-mode)
  :config
  (global-so-long-mode 1))

;; The other half of the same problem: a file that is huge in BYTES rather than in
;; line length.  eglot + treesit + font-lock on a 20MB file is a multi-second
;; freeze on visit, and you almost never want any of them there -- you want to
;; look at it.  fundamental-mode is that.
(use-package emacs
  :ensure nil
  :init
  (defvar my-large-file-threshold (* 10 1024 1024)
    "Visit files bigger than this in `fundamental-mode', without the heavy modes.")

  (defun my-large-file-guard ()
    "Drop to `fundamental-mode' on very large files, so visiting one can't hang Emacs."
    (when-let* ((file (buffer-file-name))
                (size (file-attribute-size (file-attributes file)))
                ((> size my-large-file-threshold)))
      (fundamental-mode)
      (setq buffer-read-only t
            bidi-display-reordering nil)
      (message "%s is %.1fMB -- opened read-only in fundamental-mode (%s to override)"
               (file-name-nondirectory file)
               (/ size 1024.0 1024.0)
               (substitute-command-keys "\\[read-only-mode]"))))
  :hook (find-file . my-large-file-guard))

;; `ffap' and several completion backends will try to resolve any buffer token
;; that LOOKS like a hostname (`foo.bar', i.e. most qualified symbol names and
;; filenames) by actually asking the network -- a blocking DNS lookup / ping, on a
;; keystroke.  On a slow or captive network that is a multi-second hang for
;; nothing.  Never treat a token as a machine name.
(use-package ffap
  :ensure nil
  :custom
  (ffap-machine-p-known 'reject))

(use-package go-mode
  :config
  (defun eglot-go-install-save-hooks ()
    (add-hook 'before-save-hook #'eglot-format-buffer -10 t)
    (add-hook 'before-save-hook #'eglot-code-action-organize-imports nil t))
  (add-hook 'go-mode-hook #'eglot-go-install-save-hooks))

(use-package rust-mode
  :init
  ;; rust-mode's own font-lock is flat; prefer the built-in tree-sitter
  ;; `rust-ts-mode' (richer faces, on par with python-mode).  Pin the grammar
  ;; to an ABI-14 tag — this Emacs supports tree-sitter ABI 13-14, and current
  ;; tree-sitter-rust is ABI 15.  rust-mode stays as the fallback when the
  ;; grammar is unavailable.
  (add-to-list 'treesit-language-source-alist
               '(rust "https://github.com/tree-sitter/tree-sitter-rust" "v0.21.2"))
  (when (treesit-ready-p 'rust t)
    (add-to-list 'major-mode-remap-alist '(rust-mode . rust-ts-mode)))
  :hook ((rust-ts-mode rust-mode) . eglot-ensure)
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '((rust-ts-mode rust-mode) .
                   ("rust-analyzer" :initializationOptions (:check (:command "clippy")))))))

(use-package cargo-mode
  :hook ((rust-ts-mode rust-mode) . cargo-minor-mode))

;; Common Lisp (SBCL-only) via SLY — not eglot.  SLY is the CL IDE layer
;; (REPL/inspector/debugger over slynk); `M-x sly' starts SBCL + slynk.
;; Quicklisp is loaded by ~/.sbclrc, so (ql:quickload ...) works in the REPL.
(use-package sly
  :custom
  (inferior-lisp-program "sbcl")
  :config
  (add-to-list 'auto-mode-alist '("\\.cl\\'" . lisp-mode)))

;; Structural editing + nested-paren colors for every Lisp (CL, Elisp, REPL).
(use-package paredit
  :hook ((emacs-lisp-mode lisp-mode lisp-data-mode lisp-interaction-mode
          sly-mrepl-mode)
         . enable-paredit-mode)
  :config
  ;; Don't let paredit's slurp/barf shadow windmove on the C-arrows; they stay
  ;; available on C-) / C-} (and M-( ).
  (define-key paredit-mode-map (kbd "C-<right>") nil)
  (define-key paredit-mode-map (kbd "C-<left>") nil))

;; Dim parens to a low-contrast gray (the `parenthesis' face) so the symbols
;; read cleanly, instead of coloring each nesting level.  All Lisps + SLY REPL.
(use-package paren-face
  :hook ((emacs-lisp-mode lisp-mode lisp-data-mode lisp-interaction-mode
          sly-mrepl-mode)
         . paren-face-mode))

(use-package markdown-mode
  :custom
  ;; GitHub-flavored rendering for the live preview, via node's `marked' (gfm).
  (markdown-command "marked"))

(use-package markdown-preview-mode
  ;; GitHub-flavored live preview: `C-c C-c g' toggles a browser preview that
  ;; updates as you type.  The markdown is rendered locally (`markdown-command'
  ;; = marked) and pushed over a localhost websocket, so the draft is NEVER
  ;; uploaded -- unlike grip, which POSTs it to GitHub.  The preview page itself
  ;; still pulls jquery + the github-markdown CSS from public CDNs (styling only,
  ;; no document content leaves the machine).
  :after markdown-mode
  :bind (:map markdown-mode-command-map ("g" . markdown-preview-mode))
  :custom
  (markdown-preview-stylesheets
   (list "https://cdn.jsdelivr.net/npm/github-markdown-css@5/github-markdown.css")))

(use-package magit
  :commands (magit-status magit-dispatch)
  :init
  ;; Commits are prepared as a commit buffer to REVIEW, never `git commit -m'
  ;; blind.  `my-magit-commit' runs `magit-commit-create' with "-e -F FILE", so
  ;; git itself seeds the (editable) message from FILE -- robust, no fragile
  ;; prefill hook, no timeout poll.  with-editor runs git as an Emacs-owned async
  ;; process (survives the calling shell); finish C-c C-c / abort C-c C-k.  The
  ;; `ecommit' script calls this over emacsclient with a message-file path.
  ;;
  ;; Deliberately in :init, NOT :config -- magit is DEFERRED (`:commands'), so
  ;; :config does not run until you first open magit.  `ecommit' calls this over
  ;; emacsclient on a fresh Emacs, where that hasn't happened: it failed with
  ;; "void-function my-magit-commit".  The body `require's magit itself, so
  ;; defining it eagerly is free and still loads magit on demand.
  (defun my-magit-commit (msgfile &optional dir)
    "Open an editable commit buffer for DIR's staged changes, seeded by git from
MSGFILE (via `git commit -e -F').  Called by the `ecommit' script."
    (require 'magit)
    (let ((default-directory (or dir default-directory)))
      (magit-commit-create (list "-e" "-F" (expand-file-name msgfile)))))
  :custom
  ;; No separate diff window when committing -- the commit buffer already lists
  ;; the staged files, made clickable/RET-openable by `my-git-commit-linkify-files'.
  (magit-commit-show-diff nil)
  :config
  ;; Terminal `git commit' / `git rebase -i' run with $GIT_EDITOR=emacsclient
  ;; (see ~/.bashrc).  emacsclient opens the COMMIT_EDITMSG / git-rebase-todo
  ;; buffer in this Emacs as a server buffer; loading these libraries now
  ;; installs the hooks/auto-mode so it gets `git-commit-mode' / `git-rebase-mode'
  ;; with the with-editor finish (C-c C-c) / cancel (C-c C-k) keys — giving the
  ;; "perfect rebase mode" from any ghostel/byobu shell.
  (require 'git-commit)
  (require 'git-rebase)

  ;; Make the staged-file lines in the commit buffer clickable + RET-openable
  ;; (dashboard-style), so you can jump to a changed file from the message.
  (defvar my-git-commit-file-button-map
    (let ((m (make-sparse-keymap)))
      (define-key m (kbd "RET") #'push-button)
      m)
    "Keymap on commit-buffer file buttons: RET opens (point elsewhere = newline).")
  (defun my-git-commit--open-file (button)
    ;; COMMIT_EDITMSG lives in .git/, so `default-directory' is the .git dir --
    ;; resolve the (worktree-relative) path against the worktree root instead.
    ;; Open in THIS window (like the dashboard) -- no surprise split to dismiss;
    ;; the commit buffer is one `C-x b' / `C-t C-t' away.
    (let ((root (or (magit-toplevel) default-directory)))
      (find-file (expand-file-name (button-get button 'my-file) root))))
  (defun my-git-commit-linkify-files ()
    "Buttonize the file names in the commit buffer's status comments.
Defensive -- a failure here must never block the commit buffer from opening."
    (ignore-errors
     (save-excursion
      (goto-char (point-min))
      (while (re-search-forward
              (concat "^#[ \t]+\\(?:modified\\|new file\\|deleted\\|renamed\\|"
                      "copied\\|typechange\\|both [a-z]+\\):[ \t]+\\(.+\\)$")
              nil t)
        (let* ((beg (match-beginning 1)) (end (match-end 1))
               (raw (string-trim (match-string 1)))
               (path (if (string-match " -> \\(.+\\)\\'" raw) (match-string 1 raw) raw)))
          (make-text-button beg end
                            'my-file path
                            'action #'my-git-commit--open-file
                            'follow-link t
                            'keymap my-git-commit-file-button-map
                            'help-echo (format "Open %s (RET / click)" path)))))))
  (add-hook 'git-commit-setup-hook #'my-git-commit-linkify-files))

(use-package treesit
  :ensure nil
  :config
  (setq treesit-language-source-alist
        '((bash "https://github.com/tree-sitter/tree-sitter-bash")
          (c "https://github.com/tree-sitter/tree-sitter-c" "v0.21.4")
          (cpp "https://github.com/tree-sitter/tree-sitter-cpp" "v0.22.0")
          (cmake "https://github.com/uyha/tree-sitter-cmake")
          (css "https://github.com/tree-sitter/tree-sitter-css" "v0.21.0")
          (elisp "https://github.com/Wilfred/tree-sitter-elisp")
          ;; Pin to an ABI-14 tag — this Emacs supports tree-sitter ABI 13-14,
          ;; and current tree-sitter-go is ABI 15 (see the rust pin above).
          (go "https://github.com/tree-sitter/tree-sitter-go" "v0.21.0")
          (html "https://github.com/tree-sitter/tree-sitter-html")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "v0.21.4" "src")
          (json "https://github.com/tree-sitter/tree-sitter-json")
          (make "https://github.com/alemuller/tree-sitter-make")
          (markdown "https://github.com/ikatyang/tree-sitter-markdown")
          (python "https://github.com/tree-sitter/tree-sitter-python" "v0.21.0")
          (toml "https://github.com/tree-sitter/tree-sitter-toml")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
          (elixir "https://github.com/elixir-lang/tree-sitter-elixir")
          (heex "https://github.com/phoenixframework/tree-sitter-heex" "v0.7.0")
          (yaml "https://github.com/ikatyang/tree-sitter-yaml"))))

(use-package window
  :ensure nil
  :init
  ;; Limit vertical splits to three windows
  (defun my-limit-vertical-splits (orig-fun &rest args)
    "Restrict vertical splits to a maximum of three windows."
    (if (>= (length (window-list)) 3)
        (message "Maximum of three windows reached")
      (apply orig-fun args)))
  :custom
  (split-height-threshold 80)  ; Minimum height for splitting
  (window-min-height 10)       ; Minimum height for windows
  :config
  (advice-add 'split-window-below :around #'my-limit-vertical-splits))

(use-package frame
  :ensure nil
  :custom
  (pop-up-frames nil))  ; Prevent new frames for transient buffers

(use-package vc
  :ensure nil
  :config
  ;; Shorten the mode-line VC indicator: " Git:master" -> "Γ:master".  (`defadvice'
  ;; here was obsolete as of 30.1 and the byte-compiler said so on every load.)
  (define-advice vc-mode-line (:after (&rest _) strip-backend)
    (when (stringp vc-mode)
      (setq vc-mode (replace-regexp-in-string "^ Git." "Γ:" vc-mode))))

  (defun vc-branch-diff--main-branch ()
    "The repository's main branch, best-effort.
`origin/HEAD' names it when a remote is set; otherwise take whichever of
master/main exists, else the current branch."
    (or (let ((head (string-trim
                     (shell-command-to-string
                      "git rev-parse --abbrev-ref origin/HEAD 2>/dev/null"))))
          (and (not (string-empty-p head))
               (not (string-match-p "\\`fatal" head))
               (replace-regexp-in-string "\\`origin/" "" head)))
        (seq-find (lambda (b)
                    (zerop (call-process "git" nil nil nil "rev-parse" "--verify"
                                         "--quiet" (concat "refs/heads/" b))))
                  '("master" "main"))
        (car (vc-git-branches))))

  (defun vc-branch-diff--branches ()
    "Local + remote branch names, for completion."
    (let ((default-directory (or (vc-root-dir) default-directory)))
      (split-string
       (shell-command-to-string
        "git for-each-ref --format='%(refname:short)' refs/heads refs/remotes")
       "\n" t)))

  (defun vc-branch-diff (branch)
    "Diff the current file against BRANCH's tip (default: the main branch).
With a prefix argument, prompt for BRANCH with completion.  The diff runs
from BRANCH to the working tree, so it reads as \"what this branch changed\"
-- and it is the file ON DISK, so save first to include unsaved edits."
    (interactive
     (let ((default-directory (or (vc-root-dir) default-directory)))
       (list (if current-prefix-arg
                 (completing-read "Diff against branch: " (vc-branch-diff--branches)
                                  nil nil nil nil (vc-branch-diff--main-branch))
               (vc-branch-diff--main-branch)))))
    (unless buffer-file-name
      (user-error "This buffer is not visiting a file"))
    ;; Show the diff in ANOTHER window, never on top of the file you asked about:
    ;; `inhibit-same-window' pushes `display-buffer' to reuse the other window of a
    ;; split (or make one) instead of the selected one, so the source buffer stays
    ;; put where you were reading it.
    (let ((display-buffer-overriding-action '(nil . ((inhibit-same-window . t)))))
      (vc-version-diff (list buffer-file-name) branch nil))))

;; Source line numbers in the left margin of a unified diff.
;;
;; A diff buffer's native line-number gutter counts the DIFF's OWN lines, which is
;; useless -- what you want is "which line of the actual file is this?".  Those
;; numbers are encoded once per hunk in the `@@ -old,+new @@' header; here we walk
;; each hunk and hang the running source number off every line as an overlay:
;; added/context lines get the NEW-file number (the working tree you are editing),
;; removed lines the OLD-file number, dimmed.  (This is why `diff-mode' is in the
;; `display-line-numbers' opt-out list above -- native gutter off, real one on.)
(use-package diff-mode
  :ensure nil
  :init
  (defun my-diff--lnum-put (num width dim)
    (let ((ov (make-overlay (point) (point))))
      (overlay-put ov 'my-diff-lnum t)
      (overlay-put ov 'before-string
                   (propertize (format (format "%%%dd " width) num)
                               'face (if dim 'shadow 'line-number)))))

  (defun my-diff--lnum-scan ()
    "(Re)draw source line numbers over every hunk in this diff buffer."
    (remove-overlays (point-min) (point-max) 'my-diff-lnum t)
    (let ((old 0) (new 0) (width 3))
      (save-excursion
        ;; Pass 1: widest source number, so the gutter is a fixed width.
        (goto-char (point-min))
        (let ((max 0))
          (while (re-search-forward
                  "^@@ -\\([0-9]+\\)\\(?:,[0-9]+\\)? \\+\\([0-9]+\\)\\(?:,\\([0-9]+\\)\\)? @@" nil t)
            (setq max (max max (+ (string-to-number (match-string 2))
                                  (if (match-string 3) (string-to-number (match-string 3)) 0)))))
          (setq width (max 3 (length (number-to-string max)))))
        ;; Pass 2: number each line, advancing the two counters per its kind.
        (goto-char (point-min))
        (while (not (eobp))
          (cond
           ((looking-at "^@@ -\\([0-9]+\\)\\(?:,[0-9]+\\)? \\+\\([0-9]+\\)")
            (setq old (string-to-number (match-string 1))
                  new (string-to-number (match-string 2))))
           ((looking-at "^ ")                                   ; context
            (my-diff--lnum-put new width nil) (setq old (1+ old) new (1+ new)))
           ((looking-at "^\\+")                                 ; added -> new file
            (my-diff--lnum-put new width nil) (setq new (1+ new)))
           ((looking-at "^-")                                   ; removed -> old file
            (my-diff--lnum-put old width t) (setq old (1+ old))))
          (forward-line 1)))))

  (defvar-local my-diff--lnum-timer nil)
  (defun my-diff--lnum-schedule (&rest _)
    "Coalesce rescans -- vc inserts the diff asynchronously, in chunks."
    (when (timerp my-diff--lnum-timer) (cancel-timer my-diff--lnum-timer))
    (setq my-diff--lnum-timer
          (run-with-idle-timer
           0.05 nil
           (lambda (buf)
             (when (buffer-live-p buf)
               (with-current-buffer buf
                 (when (bound-and-true-p my-diff-source-line-numbers-mode)
                   (my-diff--lnum-scan)))))
           (current-buffer))))

  (define-minor-mode my-diff-source-line-numbers-mode
    "Show each diff line's SOURCE file line number in the left margin."
    :lighter ""
    (if my-diff-source-line-numbers-mode
        (progn
          ;; The diff content may arrive after the mode turns on (async vc), so
          ;; redraw on change as well as now; both go through the debounced timer.
          (add-hook 'after-change-functions #'my-diff--lnum-schedule nil t)
          (my-diff--lnum-schedule))
      (remove-hook 'after-change-functions #'my-diff--lnum-schedule t)
      (remove-overlays (point-min) (point-max) 'my-diff-lnum t)))

  ;; ---- agent-diff: a PRE-WRITE, EDITABLE human-in-the-loop gate for an edit ----
  ;; The `e*'-script model reviews an edit only AFTER it lands (the magit commit).
  ;; This adds the missing half: show a proposed change, let you TWEAK it, and
  ;; approve/reject it BEFORE it's written.  The `ediff-review TARGET PROPOSED'
  ;; script hands off a small `<pid>.review' request file (two lines: TARGET then
  ;; PROPOSED) to a BLOCKING `emacsclient' -- the very same server-edit "wait until
  ;; you finish" routing that makes a terminal `git commit'
  ;; (GIT_EDITOR=emacsclient) block on the commit buffer until C-c C-c.  Opening
  ;; that file trips `my-agent-diff--maybe-review' (on `find-file-hook'), which
  ;; renders a unified diff INTO the buffer under `my-agent-diff-mode'.  There the
  ;; GREEN (`+') side is a real editable surface: reword a `+' line, RET to add a
  ;; `+' line, C-k to drop one.  C-c C-c applies (the diff is `patch'ed onto
  ;; TARGET), C-c C-k rejects.  Either overwrites the request file with the verdict
  ;; and `server-edit's it, releasing the client so the script prints
  ;; ACCEPTED / REJECTED -- no polling, no result file, no sleep.
  ;;
  ;; A diff + the original file IS enough to rebuild the new file (that's what
  ;; `patch'/`git apply' do).  The one invariant that keeps an EDITED diff valid is
  ;; that the hunk line numbers stay straight, so:
  ;;   - the OLD side (context + `-' removed lines) is frozen with the `read-only'
  ;;     TEXT PROPERTY (the comint-prompt technique) -- it must match TARGET
  ;;     byte-for-byte, so `patch' never fuzzes;
  ;;   - only the GREEN side is mutable, and add/remove go through commands that
  ;;     re-run `my-agent-diff--renumber' -- recomputing every `@@ -a,b +c,d @@' from
  ;;     the body (a frozen; b,d counted; c advanced by the running add-minus-remove
  ;;     delta).  So the diff is always internally consistent when applied.
  ;; Idea lifted from xenodium's agent-shell (`agent-shell-diff'); the framework is
  ;; not -- this is elisp on built-in diff-mode + the server, reusing the
  ;; source-line-number gutter above.
  ;;
  ;; Defined here in :init (not :config): diff-mode is DEFERRED (autoloaded on the
  ;; `:hook'), but the request file may open on a fresh Emacs where that hasn't
  ;; happened.  The body `require's diff-mode, so eager defun is free.
  (defvar-local my-agent-diff--state nil
    "In an `*agent-review*' buffer: (TARGET PROPOSED REQUEST-BUFFER).")
  (defvar-local my-agent-diff--resolved nil
    "Non-nil once this review has been accepted/rejected -- guards double-release.")

  (defun my-agent-diff--on-green-p ()
    "Non-nil if point's line is an added (green `+') line, not the `+++' header."
    (save-excursion
      (beginning-of-line)
      (and (eq (char-after) ?+) (not (looking-at "^\\+\\+\\+")))))

  (defun my-agent-diff--lock ()
    "Freeze everything except the CONTENT of green (`+') lines with the `read-only'
text property.  The leading `+', the trailing newline, and every non-green line
are locked; the `+' marker is rear-nonsticky so you can type right after it.  So
arbitrary keys can't corrupt the diff -- only add/remove commands (which re-lock)
change structure.  Idempotent; safe to re-run after every edit."
    (let ((inhibit-read-only t))
      (save-excursion
        (goto-char (point-min))
        (while (not (eobp))
          (let ((bol (line-beginning-position))
                (eol (line-end-position)))
            (if (and (eq (char-after bol) ?+) (not (looking-at "^\\+\\+\\+")))
                (progn                  ; green line: lock only the `+' and newline
                  (add-text-properties bol (1+ bol) '(read-only t rear-nonsticky t))
                  (when (< eol (point-max))
                    (put-text-property eol (1+ eol) 'read-only t)))
              (put-text-property bol (min (point-max) (1+ eol)) 'read-only t)))
          (forward-line 1)))))

  (defun my-agent-diff--renumber ()
    "Rewrite every hunk header so its counts match the current body: OLD start `a'
kept, `b'=context+removed, `d'=context+added, and each new start `c' advanced by
the running (added-minus-removed) delta.  Keeps an edited diff valid to `patch'."
    (let ((inhibit-read-only t)
          (delta 0))
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward
                "^@@ -\\([0-9]+\\)\\(?:,[0-9]+\\)? \\+[0-9]+\\(?:,[0-9]+\\)? @@\\(.*\\)$"
                nil t)
          (let ((a (string-to-number (match-string 1)))
                (tail (match-string 2))
                (hstart (match-beginning 0))
                (hend (match-end 0))
                (ctx 0) (add 0) (del 0))
            (save-excursion             ; count this hunk's body lines by marker
              (goto-char hend)
              (forward-line 1)
              (while (and (not (eobp))
                          (not (looking-at "^@@\\|^--- \\|^\\+\\+\\+ \\|^diff ")))
                (cond ((eq (char-after) ?\s) (setq ctx (1+ ctx)))
                      ((eq (char-after) ?+) (setq add (1+ add)))
                      ((eq (char-after) ?-) (setq del (1+ del))))
                (forward-line 1)))
            (let ((b (+ ctx del))
                  (d (+ ctx add))
                  (c (+ a delta)))
              (setq delta (+ delta (- d b)))
              (goto-char hstart)
              (delete-region hstart hend)
              (insert (format "@@ -%d,%d +%d,%d @@%s" a b c d tail))))))))

  (defun my-agent-diff--refresh ()
    "Keep the buffer consistent after a structural edit: fix the hunk counts, then
re-freeze everything but the green content.  Point is preserved (both passes wrap
`save-excursion')."
    (my-agent-diff--renumber)
    (my-agent-diff--lock))

  (defun my-agent-diff--release (reqbuf outcome)
    "Overwrite REQBUF (the `.review' request file) with OUTCOME and let its
blocking `emacsclient' go, via `server-edit' -- the same release C-c C-c does
for a commit buffer.  If no client is attached (ran by hand), just save+bury."
    (require 'server)
    (when (buffer-live-p reqbuf)
      (with-current-buffer reqbuf
        (let ((inhibit-read-only t))
          (set-text-properties (point-min) (point-max) nil)
          (erase-buffer)
          (insert outcome "\n"))
        (when (buffer-file-name) (save-buffer))
        (if server-buffer-clients        ; buffer-local list of the waiting clients
            (server-done)               ; releases emacsclient -> the script unblocks
          (kill-buffer)))))

  (defun my-agent-diff--apply (target)
    "Apply THIS review buffer's (possibly edited) unified diff onto TARGET.
Renumbers first so an added/removed green line leaves the hunk counts correct,
then `patch'es.  Signals on failure, leaving TARGET untouched."
    (my-agent-diff--renumber)
    (let ((patch (make-temp-file "agent-diff" nil ".patch"
                                 (buffer-substring-no-properties
                                  (point-min) (point-max))))
          (out (make-temp-file "agent-diff-out")))
      (unwind-protect
          (let ((status (call-process "patch" nil nil nil
                                      "-s" "--reject-file=/dev/null"
                                      "-o" out target patch)))
            (if (eq status 0)
                (copy-file out target t)
              (error "agent-diff: patch could not apply the edited diff (exit %s); %s untouched"
                     status (file-name-nondirectory target))))
        (ignore-errors (delete-file patch))
        (ignore-errors (delete-file out)))))

  (defun my-agent-diff--finish (outcome)
    "Resolve the review with OUTCOME (\"ACCEPTED\"/\"REJECTED\").
On accept, `patch' the (edited) diff onto TARGET; either way release the blocking
`emacsclient' with the verdict and close the review buffer.  If the patch fails
the review stays open (unresolved) so you can fix it or reject."
    (unless my-agent-diff--resolved
      (pcase-let ((`(,target ,_proposed ,reqbuf) my-agent-diff--state))
        (when (equal outcome "ACCEPTED")
          (my-agent-diff--apply target)         ; signals on failure -> aborts here
          (let ((buf (get-file-buffer target)))  ; refresh a live buffer on TARGET
            (when buf (with-current-buffer buf (revert-buffer t t t)))))
        (setq my-agent-diff--resolved t)         ; only past a successful apply
        (my-agent-diff--release reqbuf outcome)
        (message "agent-diff: %s" outcome)
        (when (buffer-live-p reqbuf) (kill-buffer reqbuf)))))

  (defun my-agent-diff-accept ()
    "Apply the (possibly edited) change to TARGET."
    (interactive) (my-agent-diff--finish "ACCEPTED"))
  (defun my-agent-diff-reject ()
    "Reject the change: TARGET is left untouched."
    (interactive) (my-agent-diff--finish "REJECTED"))
  (defun my-agent-diff-locked-key ()
    "Refuse an edit that isn't on the green (`+') side."
    (interactive)
    (message "agent-review: only the green (+) side is editable (RET add, C-k drop)"))

  (defun my-agent-diff-open-green ()
    "Add a new empty green (`+') line after the current one and land in it."
    (interactive)
    (if (not (my-agent-diff--on-green-p))
        (my-agent-diff-locked-key)
      (let ((inhibit-read-only t))
        (forward-line 1)
        (insert "+\n")
        (forward-line -1)
        (end-of-line))                  ; point on the new (empty) green content
      (my-agent-diff--refresh)))

  (defun my-agent-diff-kill-green ()
    "Delete the current green (`+') line entirely."
    (interactive)
    (if (not (my-agent-diff--on-green-p))
        (my-agent-diff-locked-key)
      (let ((inhibit-read-only t))
        (delete-region (line-beginning-position)
                       (min (point-max) (1+ (line-end-position)))))
      (my-agent-diff--refresh)))

  (define-derived-mode my-agent-diff-mode diff-mode "AgentReview"
    "Review, lightly EDIT, then apply/reject a proposed change to a file.
Only the green (`+') side is mutable: reword a line in place, \\[my-agent-diff-open-green] to add a
line, \\[my-agent-diff-kill-green] to drop one -- the hunk counts are kept straight automatically.
\\[my-agent-diff-accept] applies (the diff is `patch'ed onto the target), \\[my-agent-diff-reject] rejects.")

  (define-key my-agent-diff-mode-map (kbd "C-c C-c") #'my-agent-diff-accept)
  (define-key my-agent-diff-mode-map (kbd "C-c C-k") #'my-agent-diff-reject)
  (define-key my-agent-diff-mode-map (kbd "RET")     #'my-agent-diff-open-green)
  (define-key my-agent-diff-mode-map (kbd "C-j")     #'my-agent-diff-open-green)
  (define-key my-agent-diff-mode-map (kbd "C-k")     #'my-agent-diff-kill-green)
  (define-key my-agent-diff-mode-map (kbd "C-o")     #'my-agent-diff-locked-key)

  (defun my-agent-diff (target proposed reqbuf)
    "Render a review of replacing TARGET's contents with PROPOSED's INTO reqbuf --
the `.review' server buffer the blocking `emacsclient' waits on, so you act right
here (as with git-commit in COMMIT_EDITMSG).  The green side is editable."
    (require 'diff-mode)
    (setq target (expand-file-name target)
          proposed (expand-file-name proposed))
    (let* ((lbl (abbreviate-file-name target))
           (diff (let ((tmp (generate-new-buffer " *agent-diff-gen*")))
                   (unwind-protect
                       (save-window-excursion
                         (diff-no-select target proposed
                                         (list "-u" "--label" lbl "--label" lbl)
                                         t tmp)
                         (with-current-buffer tmp (buffer-string)))
                     (kill-buffer tmp)))))
      (with-current-buffer reqbuf
        (let ((inhibit-read-only t))
          (set-text-properties (point-min) (point-max) nil)
          (erase-buffer)
          (insert diff))
        (goto-char (point-min))
        (my-agent-diff-mode)
        (my-diff-source-line-numbers-mode 1)   ; the source-line gutter, explicitly
        (rename-buffer (format "*agent-review: %s*"
                               (file-name-nondirectory target))
                       t)
        (setq my-agent-diff--state (list target proposed reqbuf)
              my-agent-diff--resolved nil)
        (my-agent-diff--lock)           ; freeze all but the green content
        ;; A manual kill (anything that skips accept/reject) must still let the
        ;; blocking client go -- default an undecided review to REJECTED.
        (add-hook 'kill-buffer-hook
                  (lambda ()
                    (unless my-agent-diff--resolved
                      (setq my-agent-diff--resolved t)
                      (my-agent-diff--release (nth 2 my-agent-diff--state) "REJECTED")))
                  nil t)
        (setq header-line-format
              (concat "  agent-review   "
                      (propertize "C-c C-c" 'face 'success) " apply    "
                      (propertize "C-c C-k" 'face 'error) " reject    "
                      (propertize "RET" 'face 'link) "/" (propertize "C-k" 'face 'link)
                      " add/drop green line    "
                      (propertize (file-name-nondirectory target) 'face 'bold)))
        (set-buffer-modified-p nil))
      "OK"))

  (defun my-agent-diff--maybe-review ()
    "On `find-file-hook': if this is an `ediff-review' request file (`*.review'
under a `.git/ediff-review/' dir), read its TARGET/PROPOSED lines and render the
review INTO this buffer -- it holds the blocking client, so it must stay the
waiter."
    (let ((f (buffer-file-name)))
      (when (and f (string-suffix-p ".review" f)
                 (string-search "/ediff-review/" f))
        (let ((lines (split-string (buffer-string) "\n" t)))
          (when (and (nth 0 lines) (nth 1 lines))
            (my-agent-diff (nth 0 lines) (nth 1 lines) (current-buffer)))))))
  (add-hook 'find-file-hook #'my-agent-diff--maybe-review)
  :hook (diff-mode . my-diff-source-line-numbers-mode))

(use-package rg
  :after (projectile consult)
  :config
  (rg-enable-default-bindings)
  (setq rg-default-alias-fallback "all")
  (add-to-list 'rg-custom-type-aliases '("elixir" . "*.ex *.exs"))
  ;; Use grep-like output format with filenames and ANSI colors
  (setq rg-command-line-flags '("--color=always" "--no-heading" "--line-number" "--with-filename" "--no-config" "-S"))
  ;; Ensure rg-mode includes filenames in output
  (setq rg-show-header nil)
  ;; Ensure rg-mode parses output correctly
  (add-to-list 'compilation-error-regexp-alist-alist
               '(rg "^\\([^:]+\\):\\([0-9]+\\):\\(.*\\)" 1 2 nil nil 3))
  (add-to-list 'compilation-error-regexp-alist 'rg)
  ;; Integrate with consult for interactive searches
  (with-eval-after-load 'consult
    (setq consult-ripgrep-args
          "rg --null --line-buffered --color=always --max-columns=1000 --path-separator / \
           --smart-case --no-heading --line-number --with-filename --no-config"))
  ;; Custom rg-menu with session naming
  (defun rgs ()
    "Run rg-menu with an optional session name for named buffers."
    (interactive)
    (let* ((session-name (read-string "Session name (leave empty for default *rg*): "))
           (buffer-name (if (string-empty-p session-name)
                            "rg"
                          (format "rg %s" session-name))))
      (let ((rg-buffer-name buffer-name))
        (call-interactively 'rg))))
  ;; Override rg-get-buffer to use session-specific buffer names
  (defun my-rg-get-buffer (orig-fun &rest args)
    "Create a buffer with session-specific name for rg results."
    (let ((buffer-name (or rg-buffer-name "*rg*")))
      (get-buffer-create buffer-name)))
  (advice-add 'rg-get-buffer :around #'my-rg-get-buffer)
  ;; Apply grep-mode faces to rg-mode and process ANSI colors
  (add-hook 'rg-mode-hook
            (lambda ()
              ;; Process ANSI colors for match highlighting
              (ansi-color-apply-on-region (point-min) (point-max))
              ;; Remap rg faces to match grep-mode using face aliases
              (face-remap-add-relative 'rg-match-face
                                       '(:inherit compilation-error :underline nil))
              (face-remap-add-relative 'rg-file-tag-face
                                       '(:inherit compilation-error :underline t))
              (face-remap-add-relative 'rg-line-number-face
                                       '(:inherit compilation-line-number :underline t))
              (face-remap-add-relative 'rg-error-face
                                       '(:inherit compilation-warning :underline nil))
              ;; Prevent fallback faces from interfering
              (face-remap-add-relative 'compilation-info
                                       '(:inherit compilation-info :underline nil))
              (face-remap-add-relative 'compilation-line-number
                                       '(:inherit compilation-line-number :underline t))
              (face-remap-add-relative 'compilation-error
                                       '(:inherit compilation-error :underline nil)))))

;; Minibuffer UI is handled by `mini-frame' above.  The old config also pulled
;; in minad/mini-popup via quelpa, but it overlaps with mini-frame and required
;; a fragile GitHub fetch at startup, so it was dropped during the migration.

;; ---- Oracle: gptel -> local Ollama (see ~/Projects/oracle/PLAN.md Step 5) ----
;; M-x gptel (chat) or select code + M-x gptel-send.
;; No RAG here -- use RAGFlow (http://localhost) when you need doc-grounded answers.
(use-package gptel
  :config
  (setq gptel-model 'qwen3-coder:30b
        gptel-backend (gptel-make-ollama "Ollama"
                        :host "localhost:11434" :stream t
                        :models '(qwen3-coder:30b codestral))))
