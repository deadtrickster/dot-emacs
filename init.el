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
  (native-comp-async-report-warnings-errors 'silent)
  ;; (split-window-preferred-function nil) ; Disable automatic window splitting
  ;; (delete-window-preferred-function nil) ; Disable automatic window deletion
  :config
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
  (delete-selection-mode t)
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
                (let ((text (with-temp-buffer (insert-file-contents settings)
                                              (buffer-string))))
                  (unless (string-search cmd text)
                    ;; parse as hash-tables (native JSON's mutable form), append
                    ;; our hook to each existing SessionStart matcher, write back.
                    (let* ((data (json-parse-string text))
                           (hooks (gethash "hooks" data))
                           (ss (and hooks (gethash "SessionStart" hooks))))
                      (when (and ss (> (length ss) 0))
                        (dotimes (i (length ss))
                          (let* ((entry (aref ss i))
                                 (hs (gethash "hooks" entry))
                                 (mh (make-hash-table :test 'equal)))
                            (puthash "type" "command" mh)
                            (puthash "command" cmd mh)
                            (puthash "hooks" (vconcat hs (vector mh)) entry)))
                        (with-temp-file settings
                          (insert (json-serialize data)))))))
              (error
               (message "inside-emacs hook: left settings.json alone (%S)" err)))))))))

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
for a folder to use as the root instead of projectile's project picker."
    (require 'projectile)
    (or (let ((projectile-project-root-cache (make-hash-table :test 'equal)))
          (projectile-project-root default-directory))
        (file-name-as-directory
         (expand-file-name
          (read-directory-name "Use folder as project root: "
                               default-directory nil t)))))

  (defvar my-project-tab-commands
    '(("claude" . "claude --continue || claude"))
    "Startup command per byobu tab when the window has to be created.
Tabs not listed here open as a plain shell.")

  (defvar my-ghostel--return-buffer nil
    "Code buffer to return to from a project byobu terminal (set on jump-in).")

  (defun my-project-tab (window &optional arg)
    "Open the project's byobu session and select its WINDOW tab.
Starts the session with `bb' if it isn't running yet (default tabs:
claude/shell/git/test, native PTY spawn so `ghostel-send-string' feeds
the shell), then selects WINDOW — creating it on demand (running the
command from `my-project-tab-commands', else a plain shell) for sessions
whose saved layout predates it.  All tabs share one ghostel buffer; a
a project-aware toggle (`my-ghostel-toggle-terminal') returns you to your code."
    (require 'ghostel)
    ;; Remember the code buffer we're jumping from, so the toggle returns here.
    (unless (derived-mode-p 'ghostel-mode)
      (setq my-ghostel--return-buffer (current-buffer)))
    (let* ((project (my-project-root))
           (name (projectile-project-name project))
           ;; tmux rewrites '.'/':' in session names to '_'; match that (and `bb')
           ;; so our `=session:window' targets resolve (e.g. project `.emacs.d').
           (session (concat "projectile/" (replace-regexp-in-string "[.: ]" "_" name)))
           (ghostel-buffer-name (projectile-generate-process-name "ghostel" arg project))
           (fresh (not (get-buffer ghostel-buffer-name)))
           (default-directory project)
           (process-environment
            (cons (concat "PROJECTILE_PROJECT_NAME=" name) process-environment))
           (buffer (ghostel)))
      (when fresh
        (with-current-buffer buffer (ghostel-send-string "bb\n")))
      (my-projectile--byobu-ensure-window
       session window project (cdr (assoc window my-project-tab-commands)))
      buffer))

  (defun my-project-tab-test   (&optional arg) "Select the byobu `test' tab."   (interactive "P") (my-project-tab "test"   arg))
  (defun my-project-tab-claude (&optional arg) "Select the byobu `claude' tab." (interactive "P") (my-project-tab "claude" arg))
  (defun my-project-tab-git    (&optional arg) "Select the byobu `git' tab."    (interactive "P") (my-project-tab "git"    arg))
  (defun my-project-tab-shell  (&optional arg) "Select the byobu `shell' tab."  (interactive "P") (my-project-tab "shell"  arg))

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
       ;; Window missing (legacy layout) -> create, pin name, run CMD, select.
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
          (switch-to-prev-buffer (selected-window) 1))
      (setq my-ghostel--return-buffer (current-buffer))
      (let* ((project (my-project-root))
             (buf (get-buffer (projectile-generate-process-name "ghostel" nil project))))
        (if buf (switch-to-buffer buf) (my-project-tab "shell")))))

  ;; C-t is a real PREFIX keymap (not a command — a command can't host a chord).
  ;; C-t C-t toggles code<->this project's terminal; C-t C-c/C-g/C-s pick a tab.
  ;; (A C-g *after* the C-t prefix is a normal key, not a quit, so it binds fine.)
  (defvar my-ghostel-prefix-map
    (let ((map (make-sparse-keymap)))
      (dolist (b '(("C-t" . my-ghostel-toggle-terminal) ("t" . my-ghostel-toggle-terminal)
                   ("C-c" . my-project-tab-claude)       ("c" . my-project-tab-claude)
                   ("C-g" . my-project-tab-git)          ("g" . my-project-tab-git)
                   ("C-s" . my-project-tab-shell)        ("s" . my-project-tab-shell)))
        (define-key map (kbd (car b)) (cdr b)))
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
  :custom
  ;; Keep the project-derived buffer name fixed (as vterm did): disable
  ;; OSC-2 title tracking so the shell/byobu can't rename the buffer.
  (ghostel-set-title-function nil)
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
  (ghostel-keymap-exceptions '("C-c" "C-x" "C-u" "C-h" "M-x" "M-:" "C-\\" "C-t"))
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
  (define-key ghostel-mode-map [C-right] (ignore-error-wrapper 'windmove-right)))

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
         . enable-paredit-mode))

;; Dim parens to a low-contrast gray (the `parenthesis' face) so the symbols
;; read cleanly, instead of coloring each nesting level.  All Lisps + SLY REPL.
(use-package paren-face
  :hook ((emacs-lisp-mode lisp-mode lisp-data-mode lisp-interaction-mode
          sly-mrepl-mode)
         . paren-face-mode))

(use-package markdown-mode)

(use-package magit
  :commands (magit-status magit-dispatch)
  :config
  ;; Terminal `git commit' / `git rebase -i' run with $GIT_EDITOR=emacsclient
  ;; (see ~/.bashrc).  emacsclient opens the COMMIT_EDITMSG / git-rebase-todo
  ;; buffer in this Emacs as a server buffer; loading these libraries now
  ;; installs the hooks/auto-mode so it gets `git-commit-mode' / `git-rebase-mode'
  ;; with the with-editor finish (C-c C-c) / cancel (C-c C-k) keys — giving the
  ;; "perfect rebase mode" from any ghostel/byobu shell.
  (require 'git-commit)
  (require 'git-rebase))

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
