;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

(setq load-prefer-newer t)
(require 'auto-compile)
(auto-compile-on-load-mode)
(auto-compile-on-save-mode)

(add-to-list 'load-path "/home/dead/Projects/emacs-libvterm")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ag-reuse-buffers t)
 '(ag-reuse-window nil)
 '(alchemist-test-status-modeline nil)
 '(ansi-color-names-vector
   [("black" . "#555753")
    ("#CC0000" . "#EF2929")
    ("#4E9A06" . "#8AE234")
    ("#C4A000" . "#FCE94F")
    ("#3465A4" . "#739FCF")
    ("#75507B" . "#AD7FA8")
    ("#06989A" . "#34E2E2")
    ("#D3D7CF" . "#EEEEEC")])
 '(auto-compile-check-parens nil)
 '(auto-compile-ding nil)
 '(auto-compile-use-mode-line nil)
 '(auto-compression-mode t)
 '(auto-insert-mode t)
 '(auto-revert-interval 1)
 '(auto-revert-use-notify t)
 '(auto-save-default nil)
 '(auto-save-visited-mode nil)
 '(backup-by-copying t)
 '(c-basic-offset 4)
 '(c-default-style
   '((c++-mode . "bsd")
     (java-mode . "java")
     (awk-mode . "awk")
     (other . "gnu")))
 '(company-dabbrev-other-buffers t)
 '(company-idle-delay 0.5)
 '(company-minimum-prefix-length 3)
 '(company-statistics-file "~/.emacs.d/.company-statistics-cache.el")
 '(company-tooltip-maximum-width 60)
 '(company-tooltip-minimum-width 60)
 '(counsel-ag-base-command "ag --nocolor --nogroup %s")
 '(create-lockfiles nil)
 '(display-line-numbers-grow-only t)
 '(display-line-numbers-width-start t)
 '(doc-view-continuous t)
 '(erlang-argument-indent 2)
 '(erlang-icr-indent nil)
 '(exec-path
   '("/usr/local/sbin" "/usr/local/bin" "/usr/sbin" "/usr/bin" "/sbin" "/bin" "/usr/games" "/usr/local/games" "/snap/bin" "/usr/local/libexec/emacs/27.0.50/x86_64-pc-linux-gnu" "/home/dead/bin"))
 '(flycheck-check-syntax-automatically '(idle-change mode-enabled))
 '(flycheck-clang-args "-std=gnu++11")
 '(flycheck-clang-language-standard "gnu++11")
 '(flycheck-disabled-checkers '(emacs-lisp-checkdoc))
 '(flycheck-elixir-credo-strict t)
 '(flycheck-indication-mode 'right-fringe)
 '(flycheck-mode-line-prefix "Syntax")
 '(fringe-mode '(11) nil (fringe))
 '(gc-cons-threshold 1600000)
 '(git-messenger:show-detail t)
 '(git-messenger:use-magit-popup nil)
 '(global-hl-todo-mode t)
 '(hscroll-margin 1)
 '(hscroll-step 1)
 '(indent-tabs-mode nil)
 '(inhibit-startup-echo-area-message "dead")
 '(inhibit-startup-screen t)
 '(initial-buffer-choice nil)
 '(initial-scratch-message nil)
 '(ivy-mode t)
 '(ivy-posframe-border-width 2)
 '(ivy-posframe-parameters '((left-fringe . 10) (right-fringe . 10)))
 '(ivy-wrap t)
 '(make-backup-files t)
 '(menu-bar-mode nil)
 '(mouse-1-click-follows-link -150)
 '(mouse-1-click-in-non-selected-windows t)
 '(mouse-wheel-progressive-speed nil)
 '(mwheel-tilt-scroll-p t)
 '(next-error-find-buffer-function 'next-error-buffer-on-selected-frame)
 '(package-selected-packages
   '(doom-themes doom-modeline company-posframe smex ivy-posframe yequake quelpa quelpa-use-package company-irony company-irony-c-headers flycheck-irony irony lsp-ui cquery lsp-css lsp-sh lsp-clangd org-jira ialign neotree ivy-erlang-complete git-commit fontawesome cmake-mode dumb-jump webkit-color-picker company-c-headers flycheck-dialyxir delight pos-tip auto-compile company-erlang company-statistics use-package bind-key fill-column-indicator package-utils dashboard flycheck-color-mode-line makefile-executor git-messenger xterm-color magithub copy-as-format git-timemachine git-link scroll-restore counsel ivy counsel-projectile projectile projectile-variable yatemplate dockerfile-mode ag flycheck-elixir flycheck-credo magit markdown-mode markdown-mode+ markdown-preview-mode markdown-toc yaml-mode elixir-yasnippets alchemist protobuf-mode ac-alchemist iedit ac-php ac-js2 powerline json-mode flycheck-mix sass-mode scss-mode php-mode iedit alchemist web-mode rainbow-mode erlang ac-slime js2-refactor paredit paren-face auto-complete go-autocomplete go-eldoc yasnippet flycheck go-mode highlight-numbers hl-todo))
 '(powerline-default-separator 'wave)
 '(powerline-gui-use-vcs-glyph nil)
 '(projectile-mode t nil (projectile))
 '(projectile-mode-line '(:eval (format " [%s]" (projectile-project-name))))
 '(safe-local-variable-values
   '((projectile-project-run-cmd . "mkdir -p build; cd build; cmake ..; make run")
     (projectile-project-compilation-cmd . "mkdir -p build; cd build; cmake ..; make")
     (company-clang-arguments "-std=gnu++11")))
 '(savehist-file "~/.emacs.d/.history")
 '(savehist-mode t)
 '(search-upper-case nil)
 '(send-mail-function 'smtpmail-send-it)
 '(shell-file-name "bash")
 '(show-paren-mode t)
 '(temporary-file-directory "/tmp")
 '(tool-bar-mode nil)
 '(tooltip-delay 0.2)
 '(tramp-syntax 'default nil (tramp))
 '(truncate-lines t)
 '(vterm-keymap-exceptions
   '("C-y" "C-x" "C-u" "C-g" "C-h" "M-x" "M-o" "M-w" "<C-left>" "<C-right>" "<S-left>" "<S-right>" "<S-up>" "<S-down>"))
 '(x-gtk-use-system-tooltips nil)
 '(yas-buffer-local-condition '(looking-at "\\>"))
 '(yas-global-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#181a26" :foreground "gray80" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 116 :width normal :foundry "PfEd" :family "Roboto Mono"))))
 '(company-preview ((t (:foreground "darkgray" :underline t))))
 '(company-preview-common ((t (:inherit company-preview))))
 '(company-scrollbar-bg ((t (:background "dark gray"))))
 '(company-scrollbar-fg ((t (:background "gray25"))))
 '(company-tooltip ((t (:background "lightgray" :foreground "black"))))
 '(company-tooltip-common ((((type x)) (:inherit company-tooltip :weight bold)) (t (:inherit company-tooltip))))
 '(company-tooltip-common-selection ((((type x)) (:inherit company-tooltip-selection :weight bold)) (t (:inherit company-tooltip-selection))))
 '(company-tooltip-selection ((t (:background "steelblue" :foreground "white"))))
 '(diff-hl-change ((t (:background "#333355" :foreground "DeepSkyBlue1"))))
 '(diff-hl-delete ((t (:inherit diff-removed :foreground "red1"))))
 '(diff-hl-insert ((t (:inherit diff-added :foreground "green1"))))
 '(flycheck-error ((t (:background "#553333" :underline (:color "Red1" :style wave)))))
 '(fringe ((t (:background "#181a26"))))
 '(highlight ((t (:underline t))))
 '(internal-border ((t (:background "dark gray"))))
 '(ivy-posframe ((t (:inherit default :foreground "#dcdccc"))))
 '(js2-object-property ((t (:inherit default :foreground "goldenrod"))))
 '(line-number ((t (:inherit (shadow default) :foreground "gray34"))))
 '(line-number-current-line ((t (:inherit line-number :foreground "gray60"))))
 '(link ((t (:slant italic))))
 '(mode-line ((t (:background "dim gray" :foreground "black" :box (:line-width 1 :color "gray40")))))
 '(mode-line-buffer-id ((t (:inherit powerline-active1 :foreground "gray" :weight bold))))
 '(mode-line-buffer-id-inactive ((t (:inherit powerline-inactive1 :foreground "#888888" :weight bold))))
 '(mode-line-inactive ((t (:foreground "black" :box (:line-width 1 :color "gray40")))))
 '(parenthesis ((t (:inherit default :foreground "dim gray"))))
 '(powerline-active1 ((t (:inherit mode-line :background "grey17" :foreground "#777777"))))
 '(powerline-active2 ((t (:inherit mode-line :background "grey40" :foreground "black"))))
 '(powerline-inactive1 ((t (:inherit mode-line-inactive :background "grey11" :foreground "#666666"))))
 '(show-paren-match ((t (:background "#2f334b"))))
 '(term-color-black ((t (:background "#555753" :foreground "black"))))
 '(term-color-blue ((t (:background "#739FCF" :foreground "#3465A4"))))
 '(term-color-cyan ((t (:background "#34E2E2" :foreground "#06989A"))))
 '(term-color-green ((t (:background "#8AE234" :foreground "#4E9A06"))))
 '(term-color-magenta ((t (:background "#AD7FA8" :foreground "#75507B"))))
 '(term-color-red ((t (:background "#EF2929" :foreground "#CC0000"))))
 '(term-color-white ((t (:background "#EEEEEC" :foreground "#D3D7CF"))))
 '(term-color-yellow ((t (:background "#FCE94F" :foreground "#C4A000")))))

(package-install-selected-packages)

(load "~/.emacs.d/paths.el")

(require 'vterm)

(if (file-exists-p "secrets.el")
    (load "secrets.el"))

(require 'settings)

;;;; $ cat ~/.config/systemd/user/default.target.wants/emacs.service
;; [Unit]
;; Description=Emacs text editor
;; Documentation=info:emacs man:emacs(1) https://gnu.org/software/emacs/
;;
;; [Service]
;; Type=simple
;; ExecStart=/usr/local/bin/emacs --fg-daemon
;; ExecStop=/usr/local/bin/emacsclient --eval "(kill-emacs)"
;; Environment=SSH_AUTH_SOCK=%t/keyring/ssh
;; Restart=on-failure
;;
;; [Install]
;; WantedBy=default.target
;;;;


;;;; $ cat /usr/bin/emacs-client.sh
;; #!/bin/bash
;;
;; emacsclient -n -e "(if (> (length (frame-list)) 1) 't)" | grep t
;; if [ "$?" = "1" ]; then
;;     emacsclient -c -n -a "" "$@"
;; else
;;     emacsclient -n -a "" "$@"
;; fi
;;;;

;;;; Ramdisk for /tmp
;; tmpfs    /tmp            tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=512M  0 0
;;;;
(defun turn-on-fci-mode ())
(defun recompile-everything ()
  (interactive)
  (byte-recompile-directory "~/.emacs.d" 0 'force))

(defalias 'yes-or-no-p 'y-or-n-p)

(require 'pos-tip)

(global-set-key (kbd "<left-fringe> <mouse-1>")
                (lambda (ev)
                  (interactive "e")
                  (let* ((pos (posn-point (event-start ev)))
                         (overlay (car (overlays-at pos))))
                    (when overlay
                      (let* ((diff-type (overlay-get overlay 'diff-type))
                             (diff-content (overlay-get overlay 'diff-content)))
                        (when (and diff-content
                                   (or (eq diff-type 'change)
                                       (eq diff-type 'delete)))
                          (let ((lines (split-string diff-content "[\n\r]+" )))
                            (pos-tip-show-no-propertize
                             (mapconcat (lambda (line)
                                          (if (> (length line) 1)
                                              (cond
                                               ((= (aref line 0) ?+) (propertize (concat line "\n") 'face 'diff-added))
                                               ((= (aref line 0) ?-) (propertize  (concat line "\n") 'face 'diff-removed))))) (seq-drop lines 1) "")
                             'diff-added pos))))))))

(setq-default bidi-display-reordering nil)

(defun my-command-error-function (data context caller)
  "Ignore the buffer-read-only, beginning-of-buffer,
end-of-buffer signals; pass the rest to the default handler."
  (when (not (memq (car data) '(beginning-of-buffer
                                end-of-buffer)))
    (command-error-default-function data context caller)))

(setq command-error-function #'my-command-error-function)

;; (setq shell-command-switch "-ic")

(defalias 'agp 'ag-project)
(put 'dired-find-alternate-file 'disabled nil)


(define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
(define-key dired-mode-map (kbd "^") (lambda () (interactive) (find-alternate-file "..")))

(require 'windmove)

(defun swap-buffer-window (direction)
  "Put the buffer from the selected window in next window, and vice versa"
  (interactive)
  (let* ((this (selected-window))
         (other (windmove-find-other-window direction nil this))
         (this-buffer (window-buffer this))
         (that-buffer (window-buffer other)))
    (set-window-buffer other this-buffer)
    (set-window-buffer this that-buffer)
    ;;(tabbar-close-tab) ;;close current tab
    (select-window other) ;;swap cursor to new buffer
    ))
(global-set-key (kbd "<C-S-left>") (lambda () (interactive)
                                     (swap-buffer-window 'left)))
(global-set-key (kbd "<C-S-right>") (lambda () (interactive)
                                      (swap-buffer-window 'right)))
(global-set-key (kbd "<C-S-up>") (lambda () (interactive)
                                   (swap-buffer-window 'up)))
(global-set-key (kbd "<C-S-down>") (lambda () (interactive)
                                     (swap-buffer-window 'down)))


;;; https://www.reddit.com/r/emacs/comments/a8l741/message_in_minibuffer_overwrites_prompt/
(define-advice message (:around (f &rest args) dont-disturb-in-mini)
  (let ((inhibit-message (or inhibit-message
                             (> (minibuffer-depth) 0))))
    (apply f args)))

(require 'quelpa)
(require 'quelpa-use-package)
(require 'posframe)

(use-package yequake
  :quelpa (yequake :fetcher github :repo "alphapapa/yequake"))

(setq yequake-frames
      '(("__scratch" .
         ((name . "__scratch")
          (width . 0.3)
          (height . 0.5)
          (alpha . 0.95)
          (buffer-fns . ("*scratch*"))
          (frame-parameters . (;(undecorated . t)
                               (sticky . t)
                               (unsplittable . t)
                               (no-other-frame . t)
                               (minibuffer . nil)
                               (skip-taskbar . t)
                               (desktop-dont-save . t)
                               (window-system . x)))))))

;; (require 'ivy-posframe)

;; (with-eval-after-load 'ivy
;;   (setq ivy-initial-inputs-alist nil))

;; (setq ivy-display-function nil)
;; (push '(counsel-M-x . ivy-posframe-display-at-frame-center) ivy-display-functions-alist)
;; (push '(ido-find-file . ivy-posframe-display-at-window-center) ivy-display-functions-alist)
;; (push '(counsel-find-file . ivy-posframe-display-at-window-center) ivy-display-functions-alist)
;; (push '(complete-symbol . ivy-posframe-display-at-point) ivy-display-functions-alist)
;; (push '(counsel-describe-variable . ivy-posframe-display-at-point) ivy-display-functions-alist)
;; (push '(describe-variable . ivy-posframe-display-at-point) ivy-display-functions-alist)
;; (push '(ivy-switch-buffer . ivy-posframe-display-at-window-center) ivy-display-functions-alist)
;; (push '(t . ivy-posframe-display) ivy-display-functions-alist)


;; (global-set-key (kbd "M-x") 'counsel-M-x)
;; (global-set-key (kbd "C-x b") 'ivy-switch-buffer)
;; ;; (global-set-key (kbd "C-x C-f") 'counsel-find-file)
;; ;;
;; ;;
;; (ivy-posframe-enable)

;; (defun ivy-posframe--display (str &optional poshandler)
;;   "Show STR in ivy's posframe."
;;   (print poshandler)
;;   (if (not (ivy-posframe-workable-p))
;;       (ivy-display-function-fallback str)
;;     (with-selected-window (ivy--get-window ivy-last)
;;       ;(ignore-errors (kill-buffer ivy-posframe-buffer))
;;       (with-current-buffer ivy-posframe-buffer
;;         (goto-char (point-min)))
;;       (posframe-show
;;        ivy-posframe-buffer
;;        :font ivy-posframe-font
;;        :string
;;        (with-current-buffer (get-buffer-create " *Minibuf-1*")
;;          (let ((point (point))
;;                (string (if ivy-posframe--ignore-prompt
;;                            str
;;                          (concat (buffer-string) "  " str))))
;;            (add-text-properties (- point 1) point '(face ivy-posframe-cursor) string)
;;            string))
;;        :position (point)
;;        :poshandler poshandler
;;        :background-color (face-attribute 'ivy-posframe :background)
;;        :foreground-color (face-attribute 'ivy-posframe :foreground)
;;        :height (or ivy-posframe-height ivy-height)
;;        :width (if (eq poshandler 'osframe-poshandler-window-bottom-left-corner)
;;                   (window-width)
;;                 (or ivy-posframe-width (/ (window-width) 2)))
;;        :min-height (or ivy-posframe-min-height 10)
;;        :min-width (or ivy-posframe-min-width 50)
;;        :internal-border-width ivy-posframe-border-width
;;        :override-parameters ivy-posframe-parameters))))

;; (use-package company-posframe
;;   :quelpa (company-posframe :fetcher github :repo "tumashu/company-posframe"))
;; (require 'company-posframe)
;; (company-posframe-mode 1)
