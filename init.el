;;; -*- lexical-binding: t; -*-

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   [("black" . "#555753")
    ("#CC0000" . "#EF2929")
    ("#4E9A06" . "#8AE234")
    ("#C4A000" . "#FCE94F")
    ("#3465A4" . "#739FCF")
    ("#75507B" . "#AD7FA8")
    ("#06989A" . "#34E2E2")
    ("#D3D7CF" . "#EEEEEC")])
 '(blink-cursor-mode nil)
 '(custom-enabled-themes '(deeper-blue))
 '(dashboard-items
   '((recents . 10)
     (bookmarks . 5)
     (projects . 5)
     (registers . 5)))
 '(delete-selection-mode t)
 '(diff-hl-global-modes '(not image-mode))
 '(diff-hl-show-hunk-function 'diff-hl-show-hunk-posframe)
 '(display-line-numbers-grow-only t)
 '(display-line-numbers-widen t)
 '(display-line-numbers-width 2)
 '(display-line-numbers-width-start t)
 '(flymake-fringe-indicator-position 'right-fringe)
 '(global-diff-hl-mode t)
 '(global-diff-hl-show-hunk-mouse-mode t)
 '(lsp-auto-guess-root t)
 '(lsp-elixir-local-server-command
   "/Users/ikhaprov/Projects/elixir-ls/release/language_server.sh")
 '(lsp-elixir-server-command
   '("/Users/ikhaprov/Projects/elixir-ls/release/language_server.sh"))
 '(lsp-enable-symbol-highlighting nil)
 '(lsp-headerline-breadcrumb-enable nil)
 '(max-mini-window-height 1)
 '(native-comp-async-report-warnings-errors 'silent)
 '(ns-command-modifier 'control)
 '(package-selected-packages
   '(centaur-tabs eldoc-box mini-frame origami :origami dired-collapse dired-subtree all-the-icons-dired grip-mode envrc magit evil company-quickhelp company-posframe company go-mode go-projectile delight doom-themes doom-modeline caddyfile-mode yaml-mode yaml gitignore-mode swiper ivy ivy-xref dumb-jump diminish web-mode elixir-mode iedit bazel diff-hl treemacs treemacs-projectile rg exec-path-from-shell vterm dashboard lsp-mode undo-fu use-package projectile erlang good-scroll))
 '(show-paren-mode t)
 '(show-paren-priority -50)
 '(show-paren-style 'expression)
 '(tool-bar-mode nil)
 '(truncate-lines t)
 '(warning-suppress-types '((lsp-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#181a26" :foreground "gray80" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 136 :width normal :foundry "PfEd" :family "Roboto Mono"))))
 '(compilation-error ((t (:foreground "#D9786B"))))
 '(compilation-info ((t (:foreground "#A3A9CE" :weight normal))))
 '(compilation-warning ((t (:inherit warning :foreground "#FDB262"))))
 '(custom-button ((t (:background "#606163" :foreground "#e8e9e9" :box (:line-width (2 . 2) :style flat-button)))))
 '(diff-hl-change ((t (:background "#333355" :foreground "DeepSkyBlue1"))))
 '(diff-hl-delete ((t (:inherit diff-removed :foreground "red1"))))
 '(diff-hl-insert ((t (:inherit diff-added :foreground "green1"))))
 '(flycheck-error ((t (:background "#553333" :underline (:color "Red1" :style wave)))))
 '(fringe ((t (:background "#181a26"))))
 '(highlight ((t (:underline t))))
 '(hl-line ((t (:background "#2b2d36"))))
 '(line-number ((t (:inherit (shadow default) :foreground "gray34"))))
 '(line-number-current-line ((t (:inherit line-number :foreground "gray60"))))
 '(link ((t (:slant italic))))
 '(mode-line ((t (:background "#282b35" :foreground "#737475" :box (:line-width (1 . 1) :style flat-button)))))
 '(mode-line-buffer-id ((t (:distant-foreground "#969696" :foreground "gray75" :weight bold))))
 '(mode-line-inactive ((t (:background "#282b35" :foreground "#737475" :box (:line-width (1 . 1) :color "#121214" :style flat-button)))))
 '(parenthesis ((t (:inherit default :foreground "dim gray"))))
 '(show-paren-match ((t (:background "#2f334b"))))
 '(term-color-black ((t (:background "#555753" :foreground "black"))))
 '(term-color-blue ((t (:background "#739FCF" :foreground "#3465A4"))))
 '(term-color-cyan ((t (:background "#34E2E2" :foreground "#06989A"))))
 '(term-color-green ((t (:background "#8AE234" :foreground "#4E9A06"))))
 '(term-color-magenta ((t (:background "#AD7FA8" :foreground "#75507B"))))
 '(term-color-red ((t (:background "#EF2929" :foreground "#CC0000"))))
 '(term-color-white ((t (:background "#EEEEEC" :foreground "#D3D7CF"))))
 '(term-color-yellow ((t (:background "#FCE94F" :foreground "#C4A000"))))
 '(tooltip ((t (:inherit default :height 1.0))))
 '(vterm-color-black ((t (:inherit term-color-black))))
 '(vterm-color-blue ((t (:inherit term-color-blue))))
 '(vterm-color-cyan ((t (:inherit term-color-cyan))))
 '(vterm-color-green ((t (:inherit term-color-green))))
 '(vterm-color-magenta ((t (:inherit term-color-magenta))))
 '(vterm-color-red ((t (:inherit term-color-red))))
 '(vterm-color-white ((t (:inherit term-color-white))))
 '(vterm-color-yellow ((t (:inherit term-color-yellow))))
 '(widget-field ((t (:extend t :background "#171A27" :box (:line-width (1 . 3) :color "#737687" :style flat-button) :weight bold :height 1.0)))))

(require 'good-scroll)
(good-scroll-mode 1)
;; (global-set-key [next] #'good-scroll-up-full-screen)
;; (global-set-key [prior] #'good-scroll-down-full-screen)
(toggle-truncate-lines)

(require 'projectile)
;; Recommended keymap prefix on macOS
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
;; Recommended keymap prefix on -Windows/Linux
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(projectile-mode +1)


(use-package undo-fu
  :config
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z")   'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo))


(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

(require 'windmove)
(defun ignore-error-wrapper (fn)
  "Funtion return new function that ignore errors.
   The function wraps a function with `ignore-errors' macro."
  (let ((fn fn))
    (lambda ()
      (interactive)
      (ignore-errors
        (funcall fn)))))
(global-set-key [C-left] (ignore-error-wrapper 'windmove-left))
(global-set-key [C-right] (ignore-error-wrapper 'windmove-right))
(global-set-key [C-up] (ignore-error-wrapper 'windmove-up))
(global-set-key [C-down] (ignore-error-wrapper 'windmove-down))

(use-package lsp-mode
  :commands lsp
  :ensure t
  :diminish lsp-mode
  :hook
  (elixir-mode . lsp)
  (erlang-mode . lsp)
  (go-mode . lsp-deferred)
  (sh-mode . lsp)
  :init
  (add-to-list 'exec-path "/Users/ikhaprov/Projects/elixir-ls/release"))

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)


(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(setq projectile-mode-line-function '(lambda () (format " Π[%s]" (projectile-project-name))))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))

(setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))

(setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
                        (projects . 5)
                        (registers . 5)))

(advice-add 'view-echo-area-messages
            :filter-return (lambda (win) (select-window win :mark-for-redisplay)))

(require 'diff-hl-flydiff)

(diff-hl-flydiff-mode 1)

(require 'iedit)

(setf iedit-mode t)

(define-key global-map (kbd "C-;") 'iedit-mode)
(define-key isearch-mode-map (kbd "C-;") 'iedit-mode-from-isearch)
(define-key esc-map (kbd "C-;") 'iedit-execute-last-modification)
(define-key help-map (kbd "C-;") 'iedit-mode-toggle-on-function)

(defadvice vc-mode-line (after strip-backend () activate)
  (when (stringp vc-mode)
    (let ((gitlogo (replace-regexp-in-string "^ Git." "Γ:" vc-mode)))
      (setq vc-mode gitlogo))))

(setq mode-line-percent-position nil)

(defun flymake--mode-line-title ()
  `(:propertize
    "Φ"
    mouse-face mode-line-highlight
    help-echo
    ,(lambda (&rest _)
       (concat
        (format "%s known backends\n" (hash-table-count flymake--state))
        (format "%s running\n" (length (flymake-running-backends)))
        (format "%s disabled\n" (length (flymake-disabled-backends)))
        "mouse-1: Display minor mode menu\n"
        "mouse-2: Show help for minor mode"))
    keymap
    ,(let ((map (make-sparse-keymap)))
       (define-key map [mode-line down-mouse-1]
         flymake-menu)
       (define-key map [mode-line down-mouse-3]
         flymake-menu)
       (define-key map [mode-line mouse-2]
         (lambda ()
           (interactive)
           (describe-function 'flymake-mode)))
       map)))

(setq mode-line-modes (let ((recursive-edit-help-echo
                             "Recursive edit, type M-C-c to get out"))
                        (list (propertize "%[" 'help-echo recursive-edit-help-echo)

                              `(:propertize ("" mode-name)
                                            help-echo "Major mode\n\
mouse-1: Display major mode menu\n\
mouse-2: Show help for major mode\n\
mouse-3: Toggle minor modes"
                                            mouse-face mode-line-highlight
                                            local-map ,mode-line-major-mode-keymap)
                              ","
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

(setf active-buffer-id '(#("%12b" 0 4
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

(setf inactive-buffer-id '(#("%12b" 0 4
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

(add-hook 'window-selection-change-functions 'powerline-set-selected-window)

(setq-default mode-line-buffer-identification '(:eval (if (powerline-selected-window-active)
                                                          active-buffer-id
                                                        inactive-buffer-id)))

(use-package diminish
  :diminish abbrev-mode
  :diminish org-indent-mode
  :diminish apheleia-mode
  :diminish auto-revert-mode
  :diminish hungry-delete-mode
  :diminish hungry-delete
  :diminish lisp-interaction-mode
  :diminish visual-line-mode
  :diminish subword-mode
  :diminish auto-fill-function)

(defun apply-my-delight-list ()
  (delight '((company-mode nil company)
             (abbrev-mode nil abbrev)
             (eldoc-mode nil eldoc)
             (flyspell-mode nil flyspell)
             (paredit-mode nil paredit)
             (rainbow-mode nil rainbow-mode)
             (yas-minor-mode nil yasnippet)
             (page-break-lines-mode nil page-break-lines)
             (auto-revert-mode nil auto-revert)
             ;; (projectile-mode nil projectile)
             )))

(apply-my-delight-list)

(defun indent-whole-buffer ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

(defun er-switch-to-previous-buffer ()
  "Switch to previously open buffer.
Repeated invocations toggle between the two most recently open buffers."
  (interactive)
  (switch-to-prev-buffer (selected-window) 1))

(global-set-key (kbd "<home>") 'beginning-of-line)
(global-set-key (kbd "<end>") 'end-of-line)
(global-set-key "\C-cc" 'comment-or-uncomment-region)
(global-set-key [f12] 'indent-whole-buffer)
(global-set-key [f11] 'delete-trailing-whitespace)
(global-set-key "\C-d" 'dired-jump)
(require 'vterm)
(define-key vterm-mode-map [?\C-t] 'er-switch-to-previous-buffer)
(define-key vterm-mode-map [?\C-d] #'vterm--self-insert)
(define-key vterm-mode-map [deletechar] #'vterm-send-delete)
(define-key vterm-mode-map [C-up] (ignore-error-wrapper 'windmove-up))
(define-key vterm-mode-map [C-down] (ignore-error-wrapper 'windmove-down))
(define-key vterm-mode-map [C-left] (ignore-error-wrapper 'windmove-left))
(define-key vterm-mode-map [C-right] (ignore-error-wrapper 'windmove-right))

(defun my-projectile-run-vterm (&optional arg)
  "
CHANGE: set PROJECTILE_PROJECT_NAME env var, so shells can use it somehow.
For example, to name byobu sessions.

Invoke `vterm' in the project's root.

Switch to the project specific term buffer if it already exists.

Use a prefix argument ARG to indicate creation of a new process instead."
  (interactive "P")
  (let* ((project (projectile-acquire-root))
         (buffer (projectile-generate-process-name "vterm" arg project))
         (vterm-environment (append `(,(concat "PROJECTILE_PROJECT_NAME="
                                               (projectile-project-name project)))
                                    vterm-environment)))
    (unless (buffer-live-p (get-buffer buffer))
      (unless (require 'vterm nil 'noerror)
        (error "Package 'vterm' is not available"))
      (projectile-with-default-dir project
        (vterm buffer)))
    (switch-to-buffer buffer)))

(define-key global-map [?\C-t] 'my-projectile-run-vterm)

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

(add-hook 'prog-mode-hook 'company-mode)

(add-to-list 'auto-mode-alist '("\\(/\\|\\`\\)[Mm]akefile" . makefile-gmake-mode))

;;; from doom

;; Don't generate backups or lockfiles. While auto-save maintains a copy so long
;; as a buffer is unsaved, backups create copies once, when the file is first
;; written, and never again until it is killed and reopened. This is better
;; suited to version control, and I don't want world-readable copies of
;; potentially sensitive material floating around our filesystem.
(setq create-lockfiles nil
      make-backup-files nil
      ;; But in case the user does enable it, some sensible defaults:
      version-control t     ; number each backup file
      backup-by-copying t   ; instead of renaming current file (clobbers links)
      delete-old-versions t ; clean up after itself
      kept-old-versions 5
      kept-new-versions 5
      backup-directory-alist (list (cons "." "/Users/ikhaprov/.emacs.d/backups/"))
      tramp-backup-directory-alist backup-directory-alist)

;; But turn on auto-save, so we have a fallback in case of crashes or lost data.
;; Use `recover-file' or `recover-session' to recover them.
(setq auto-save-default t
      ;; Don't auto-disable auto-save after deleting big chunks. This defeats
      ;; the purpose of a failsafe. This adds the risk of losing the data we
      ;; just deleted, but I believe that's VCS's jurisdiction, not ours.
      auto-save-include-big-deletions t
      auto-save-list-file-prefix "/Users/ikhaprov/.emacs.d/autosave/"
      tramp-auto-save-directory  "/Users/ikhaprov/.emacs.d/tramp-autosave/"
      auto-save-file-name-transforms
      (list (list "\\`/[^/]*:\\([^/]*/\\)*\\([^/]*\\)\\'"
                  ;; Prefix tramp autosaves to prevent conflicts with local ones
                  (concat auto-save-list-file-prefix "tramp-\\2") t)
            (list ".*" auto-save-list-file-prefix t)))

(use-package grip-mode
  :ensure t
  :bind (:map markdown-mode-command-map
              ("g" . grip-mode)))

(use-package dired-subtree
  :ensure t
  :after dired
  :config
  (define-key dired-mode-map (kbd "<tab>") 'dired-subtree-toggle))



(use-package origami
  :ensure t)

(global-set-key [C-tab] 'origami-toggle-node)

(require 'lsp)
(add-to-list 'lsp-file-watch-ignored-directories "[/\\]\_build")
(add-to-list 'lsp-file-watch-ignored-directories "[/\\]vendor")
(add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]vendor\\'")


(setq max-mini-window-height 2)

(mini-frame-mode)

(defun insert-newline-before-line ()
  (interactive)
  (let ((current-line
         (line-number-at-pos (point))))
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

(global-set-key [C-return] 'insert-newline-before-line)
