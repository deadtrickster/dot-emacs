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
    (interactive)
    (let ((current-line (line-number-at-pos (point))))
      (if (eql current-line 1)
          (progn
            (beginning-of-line)
            (newline-and-indent)
            (goto-line 1)
            (indent-according-to-mode))
        (progn
          (goto-line (1- current-line))
          (end-of-line)
          (newline-and-indent)))))
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
                  telega-root-mode-hook
                  telega-chat-mode-hook
                  erc-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0)))))

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
   '(web-mode multi-web-mode 0blayout 0x0 all-the-icons bazel cargo-mode company consult
      corfu dashboard delight diff-hl diminish dired-subtree dockerfile-mode
      dotenv-mode dumb-jump eglot-fsharp elixir-mode envrc exec-path-from-shell
      fsharp-mode gcmh ghostel git-commit git-link go-mode go-noisegate grip-mode
      inheritenv
      highlight-indentation iedit logview lsp-docker lsp-mode lsp-ui magit marginalia
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
  (warning-suppress-log-types '((auto-save) (lsp-mode)))
  (warning-suppress-types '((lsp-mode))))

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
  (unless (server-running-p)
    (server-start)))

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
  (add-hook 'emacs-startup-hook #'my-restart--maybe-restore)
  ;; First half: snapshot on every exit so a plain `C-x C-c' / laptop shutdown
  ;; comes back next launch (the startup hook restores + consumes the file).
  (add-hook 'kill-emacs-hook #'my-restart--save-state))

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
      (dolist (f '("eopen" "esay" "enotify" "ecommit" "ebuffer" "esh"))
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
                                    "Bash(ecommit:*)" "Bash(ebuffer:*)" "Bash(esh:*)"))
                      (unless (seq-contains-p allow rule)
                        (setq allow (vconcat allow (vector rule)) changed t)))
                    (puthash "allow" allow perms))
                  (when changed
                    (with-temp-file settings
                      (insert (json-serialize data)))))
              (error
               (message "inside-emacs setup: left settings.json alone (%S)" err)))))))))

(add-hook 'after-init-hook #'my-ensure-shell-integration)

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
  (select-enable-clipboard t))

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
stand-in for clicking, since the TUI owns the mouse.  Bound to `C-t C-f'."
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
      ;; Any other key (a plain letter) -> type-to-filter window switch, seeded
      ;; with that key: C-t t -> test, C-t <type a name> -> that window.  So the
      ;; mnemonic chords are kept AND every window (incl. test/custom) is one
      ;; C-t-then-type away — nothing sacrificed.
      (define-key map [t] #'my-byobu-switch-window)
      map)
    "Prefix map bound to \\`C-t' (in the global map and `ghostel-mode-map').")
  :config
  (global-set-key (kbd "C-t") my-ghostel-prefix-map)
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
     (projects . 5)
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
  (eglot-ignored-server-capabilities '())
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
  ;; No format-on-save for C/C++: clang-format ignores Emacs's indent vars and
  ;; reformats aggressively, fighting the 4-space editor indent.  Add a project
  ;; .clang-format if you want full formatting there.
  (dolist (m '(c-mode c++-mode c-ts-mode c++-ts-mode))
    (setq apheleia-mode-alist (assq-delete-all m apheleia-mode-alist))))

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
  (gcmh-mode 1))

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

  ;; Commits are prepared as a commit buffer to REVIEW, never `git commit -m'
  ;; blind.  `my-magit-commit' runs `magit-commit-create' with "-e -F FILE", so
  ;; git itself seeds the (editable) message from FILE -- robust, no fragile
  ;; prefill hook, no timeout poll.  with-editor runs git as an Emacs-owned async
  ;; process (survives the calling shell); finish C-c C-c / abort C-c C-k.  The
  ;; `ecommit' script calls this over emacsclient with a message-file path.
  (defun my-magit-commit (msgfile &optional dir)
    "Open an editable commit buffer for DIR's staged changes, seeded by git from
MSGFILE (via `git commit -e -F').  Called by the `ecommit' script."
    (require 'magit)
    (let ((default-directory (or dir default-directory)))
      (magit-commit-create (list "-e" "-F" (expand-file-name msgfile)))))

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
  (defadvice vc-mode-line (after strip-backend () activate)
    (when (stringp vc-mode)
      (let ((gitlogo (replace-regexp-in-string "^ Git." "Γ:" vc-mode)))
        (setq vc-mode gitlogo)))))

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
