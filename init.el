;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

(setq load-prefer-newer t)
(require 'auto-compile)
(auto-compile-on-load-mode)
(auto-compile-on-save-mode)

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
 '(delete-selection-mode t)
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
 '(global-flycheck-mode nil)
 '(hscroll-margin 1)
 '(hscroll-step 1)
 '(ido-case-fold t)
 '(ido-enable-flex-matching t)
 '(ido-max-window-height 1)
 '(indent-tabs-mode nil)
 '(inhibit-startup-echo-area-message "dead")
 '(inhibit-startup-screen t)
 '(initial-buffer-choice nil)
 '(initial-scratch-message nil)
 '(ivy-mode nil)
 '(ivy-posframe-border-width 2)
 '(ivy-posframe-parameters '((left-fringe . 10) (right-fringe . 10)))
 '(ivy-wrap t)
 '(lsp-clients-elixir-server-executable "/home/dead/bin/elixirls/language_server.sh")
 '(make-backup-files t)
 '(menu-bar-mode nil)
 '(mouse-1-click-follows-link -150)
 '(mouse-1-click-in-non-selected-windows t)
 '(mouse-wheel-progressive-speed nil)
 '(mwheel-tilt-scroll-p t)
 '(next-error-find-buffer-function 'next-error-buffer-on-selected-frame)
 '(package-selected-packages
   '(thrift uuidgen magit-popup all-the-icons-ivy treemacs treemacs-icons-dired treemacs-magit treemacs-projectile hydra plantuml-mode flycheck-inline company-posframe smex ivy-posframe yequake quelpa quelpa-use-package company-irony company-irony-c-headers flycheck-irony irony lsp-ui cquery lsp-css lsp-sh lsp-clangd org-jira ialign neotree ivy-erlang-complete git-commit fontawesome cmake-mode dumb-jump webkit-color-picker company-c-headers flycheck-dialyxir delight pos-tip auto-compile company-erlang company-statistics use-package bind-key fill-column-indicator package-utils dashboard flycheck-color-mode-line git-messenger xterm-color magithub copy-as-format git-timemachine git-link scroll-restore counsel ivy counsel-projectile projectile projectile-variable yatemplate dockerfile-mode ag flycheck-elixir flycheck-credo magit markdown-mode markdown-mode+ markdown-preview-mode markdown-toc yaml-mode elixir-yasnippets alchemist protobuf-mode ac-alchemist iedit ac-php ac-js2 powerline json-mode flycheck-mix sass-mode scss-mode php-mode iedit alchemist web-mode rainbow-mode erlang ac-slime js2-refactor paredit paren-face auto-complete go-autocomplete go-eldoc yasnippet flycheck go-mode highlight-numbers hl-todo))
 '(plantuml-jar-path
   "/home/dead/bin/plantuml/target/plantuml-1.2019.1-SNAPSHOT.jar")
 '(powerline-default-separator 'wave)
 '(powerline-gui-use-vcs-glyph nil)
 '(projectile-mode t nil (projectile))
 '(projectile-mode-line '(:eval (format " [%s]" (projectile-project-name))))
 '(quelpa-checkout-melpa-p nil)
 '(safe-local-variable-values
   '((projectile-project-run-cmd . "mkdir -p build; cd build; cmake ..; make run")
     (projectile-project-compilation-cmd . "mkdir -p build; cd build; cmake ..; make")
     (company-clang-arguments "-std=gnu++11")))
 '(savehist-file "~/.emacs.d/.history")
 '(savehist-mode t)
 '(search-upper-case nil)
 '(send-mail-function 'smtpmail-send-it)
 '(shell-file-name "bash")
 '(show-paren-style 'expression)
 '(temporary-file-directory "/tmp")
 '(tool-bar-mode nil)
 '(tooltip-delay 0.2)
 '(tramp-syntax 'default nil (tramp))
 '(treemacs-collapse-dirs 3)
 '(truncate-lines t)
 '(vterm-keymap-exceptions
   '("C-y" "C-x" "C-u" "C-g" "C-h" "M-x" "M-o" "M-w" "<C-left>" "<C-right>" "<S-left>" "<S-right>" "<S-up>" "<S-down>"))
 '(x-gtk-use-system-tooltips nil)
 '(yas-buffer-local-condition '(looking-at "\\>")))
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
 '(hl-line ((t (:background "#2b2d36"))))
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
 '(term-color-yellow ((t (:background "#FCE94F" :foreground "#C4A000"))))
 '(treemacs-directory-collapsed-face ((t (:inherit (variable-pitch default)))))
 '(treemacs-directory-face ((t (:inherit (variable-pitch default)))))
 '(treemacs-file-face ((t (:inherit variable-pitch :foreground "#8a8c99"))))
 '(treemacs-fringe-indicator-face ((t (:foreground "#181a26"))))
 '(treemacs-root-face ((t (:foreground "#739FCF" :weight bold))))
 '(vterm-color-black ((t (:inherit term-color-black))))
 '(vterm-color-black-bg ((t (:background "#555753"))))
 '(vterm-color-blue ((t (:inherit term-color-blue))))
 '(vterm-color-blue-bg ((t (:background "#739FCF"))))
 '(vterm-color-blue-fg ((t (:foreground "#3465A4"))))
 '(vterm-color-cyan ((t (:inherit term-color-cyan))))
 '(vterm-color-cyan-bg ((t (:background "#34E2E2"))))
 '(vterm-color-cyan-fg ((t (:foreground "#06989A"))))
 '(vterm-color-default-bg ((t (:background "#181a26"))))
 '(vterm-color-default-fg ((t (:foreground "gray80"))))
 '(vterm-color-green ((t (:inherit term-color-green))))
 '(vterm-color-green-bg ((t (:background "#8AE234"))))
 '(vterm-color-green-fg ((t (:foreground "#4E9A06"))))
 '(vterm-color-magenta ((t (:inherit term-color-magenta))))
 '(vterm-color-magenta-bg ((t (:foreground "#AD7FA8"))))
 '(vterm-color-magenta-fg ((t (:foreground "#75507B"))))
 '(vterm-color-red ((t (:inherit term-color-red))))
 '(vterm-color-red-bg ((t (:background "#EF2929"))))
 '(vterm-color-red-fg ((t (:foreground "#CC0000"))))
 '(vterm-color-white ((t (:inherit term-color-white))))
 '(vterm-color-white-bg ((t (:background "#EEEEEC"))))
 '(vterm-color-white-fg ((t (:foreground "#D3D7CF"))))
 '(vterm-color-yellow ((t (:inherit term-color-yellow))))
 '(vterm-color-yellow-bg ((t (:background "#FCE94F"))))
 '(vterm-color-yellow-fg ((t (:foreground "#C4A000")))))

(package-install-selected-packages)

(load "~/.emacs.d/paths.el")

(if (file-exists-p "secrets.el")
    (load "secrets.el"))

(require 'settings)
(defun turn-on-fci-mode ())
(defun recompile-everything ()
  (interactive)
  (byte-recompile-directory "~/.emacs.d" 0 'force))

(setq-default bidi-display-reordering nil)

(defun my-command-error-function (data context caller)
  "Ignore the buffer-read-only, beginning-of-buffer,
end-of-buffer signals; pass the rest to the default handler."
  (when (not (memq (car data) '(beginning-of-buffer
                                end-of-buffer)))
    (command-error-default-function data context caller)))

(setq command-error-function #'my-command-error-function)


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

;; (setq shell-command-switch "-ic")


;; (require 'quelpa)
;; (require 'quelpa-use-package)
;; (require 'posframe)

;; (use-package yequake
;;   :quelpa (yequake :fetcher github :repo "alphapapa/yequake"))

;; (setq yequake-frames
;;       '(("__scratch" .
;;          ((name . "__scratch")
;;           (width . 0.3)
;;           (height . 0.5)
;;           (alpha . 0.95)
;;           (buffer-fns . ("*scratch*"))
;;           (frame-parameters . (;(undecorated . t)
;;                                (sticky . t)
;;                                (unsplittable . t)
;;                                (no-other-frame . t)
;;                                (minibuffer . nil)
;;                                (skip-taskbar . t)
;;                                (desktop-dont-save . t)
;;                                (window-system . x)))))))

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
