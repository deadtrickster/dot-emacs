;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(setq load-prefer-newer t)
(package-initialize)
(require 'auto-compile)
(auto-compile-on-load-mode)
(auto-compile-on-save-mode)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["dim gray" "red4" "green4" "yellow4" "deep sky blue" "magenta4" "cyan4" "white"])
 '(auto-compression-mode t)
 '(auto-insert-mode t)
 '(auto-revert-interval 1)
 '(auto-revert-use-notify t)
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
 '(display-line-numbers-grow-only t)
 '(display-line-numbers-width 3)
 '(display-line-numbers-width-start t)
 '(display-time-24hr-format t)
 '(display-time-default-load-average 0)
 '(display-time-mode t)
 '(doc-view-continuous t)
 '(erlang-argument-indent 2)
 '(erlang-icr-indent nil)
 '(flycheck-clang-args "-std=gnu++11")
 '(flycheck-clang-language-standard "gnu++11")
 '(flycheck-disabled-checkers '(emacs-lisp-checkdoc))
 '(flycheck-elixir-credo-strict t)
 '(flycheck-mode-line-prefix "Syntax")
 '(git-messenger:show-detail t)
 '(git-messenger:use-magit-popup nil)
 '(global-hl-todo-mode t)
 '(hscroll-margin 1)
 '(hscroll-step 1)
 '(inhibit-startup-echo-area-message "dead")
 '(inhibit-startup-screen t)
 '(initial-buffer-choice nil)
 '(initial-scratch-message nil)
 '(ivy-wrap t)
 '(package-selected-packages
   '(neotree magit magithub delight company-c-headers company-erlang auto-compile company-statistics use-package bind-key fill-column-indicator package-utils dashboard flycheck-color-mode-line makefile-executor git-messenger xterm-color copy-as-format git-timemachine git-link scroll-restore counsel ivy counsel-projectile projectile projectile-variable yatemplate dockerfile-mode ag company-nixos-options nix-buffer nix-mode nix-sandbox nixos-options flycheck-elixir flycheck-credo markdown-mode markdown-mode+ markdown-preview-mode markdown-toc yaml-mode elixir-yasnippets lfe-mode alchemist auctex protobuf-mode ac-alchemist iedit ac-php ac-js2 powerline diff-hl json-mode flycheck-mix sass-mode scss-mode php-mode iedit alchemist web-mode rainbow-mode erlang ac-slime js2-refactor paredit paren-face auto-complete go-autocomplete go-eldoc yasnippet flycheck go-mode highlight-numbers hl-todo))
 '(powerline-default-separator 'wave)
 '(projectile-mode t nil (projectile))
 '(projectile-mode-line '(:eval (format " [%s]" (projectile-project-name))))
 '(safe-local-variable-values '((company-clang-arguments "-std=gnu++11")))
 '(savehist-file "~/.emacs.d/.history")
 '(savehist-mode t)
 '(search-upper-case nil)
 '(send-mail-function 'smtpmail-send-it)
 '(show-paren-mode t)
 '(temporary-file-directory "/tmp")
 '(tool-bar-mode nil)
 '(tramp-syntax 'default nil (tramp))
 '(truncate-lines t)
 '(yas-buffer-local-condition '(looking-at "\\>"))
 '(yas-global-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#181a26" :foreground "gray80" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 114 :width normal :foundry "pyrs" :family "Roboto Mono"))))
 '(company-preview ((t (:foreground "darkgray" :underline t))))
 '(company-preview-common ((t (:inherit company-preview))))
 '(company-scrollbar-bg ((t (:background "dark gray"))))
 '(company-scrollbar-fg ((t (:background "gray25"))))
 '(company-tooltip ((t (:background "lightgray" :foreground "black"))))
 '(company-tooltip-common ((((type x)) (:inherit company-tooltip :weight bold)) (t (:inherit company-tooltip))))
 '(company-tooltip-common-selection ((((type x)) (:inherit company-tooltip-selection :weight bold)) (t (:inherit company-tooltip-selection))))
 '(company-tooltip-selection ((t (:background "steelblue" :foreground "white"))))
 '(highlight ((t (:underline t))))
 '(js2-object-property ((t (:inherit default :foreground "goldenrod"))))
 '(line-number ((t (:inherit (shadow default) :foreground "gray34"))))
 '(line-number-current-line ((t (:inherit line-number :foreground "gray60"))))
 '(link ((t (:slant italic))))
 '(mode-line ((t (:background "dim gray" :foreground "black" :box (:line-width 1 :style released-button)))))
 '(parenthesis ((t (:inherit default :foreground "dim gray"))))
 '(powerline-active1 ((t (:inherit mode-line :background "grey17" :foreground "gray"))))
 '(powerline-active2 ((t (:inherit mode-line :background "grey40" :foreground "gray"))))
 '(powerline-inactive1 ((t (:inherit mode-line-inactive :background "grey11" :foreground "#666666"))))
 '(show-paren-match ((t (:background "#2f334b")))))

(package-install-selected-packages)

(load "~/.emacs.d/paths.el")

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
