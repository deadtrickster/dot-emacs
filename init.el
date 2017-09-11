









;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-insert-mode t)
 '(auto-revert-interval 1)
 '(auto-revert-use-notify t)
 '(display-line-numbers t)
 '(display-line-numbers-width 3)
 '(display-time-24hr-format t)
 '(display-time-default-load-average 0)
 '(display-time-mode t)
 '(doc-view-continuous t)
 '(erlang-argument-indent 2)
 '(erlang-icr-indent nil)
 '(flycheck-disabled-checkers (quote (emacs-lisp-checkdoc)))
 '(flycheck-elixir-credo-strict t)
 '(git-messenger:show-detail t)
 '(git-messenger:use-magit-popup nil)
 '(hscroll-margin 1)
 '(hscroll-step 1)
 '(inhibit-startup-echo-area-message "dead")
 '(inhibit-startup-screen t)
 '(initial-buffer-choice nil)
 '(initial-scratch-message nil)
 '(package-selected-packages
   (quote
    (package-utils fill-column-indicator dashboard flycheck-color-mode-line pdf-tools makefile-executor git-messenger xterm-color magithub copy-as-format git-timemachine git-link scroll-restore counsel ivy company-erlang counsel-projectile projectile projectile-variable yatemplate ivy-erlang-complete dockerfile-mode ag company-nixos-options nix-buffer nix-mode nix-sandbox nixos-options flycheck-elixir flycheck-credo magit markdown-mode markdown-mode+ markdown-preview-mode markdown-toc yaml-mode elixir-yasnippets lfe-mode alchemist auctex protobuf-mode ac-alchemist iedit ac-php ac-js2 powerline diff-hl json-mode flycheck-mix less-css-mode sass-mode scss-mode php-mode iedit alchemist web-mode rainbow-mode erlang ac-slime js2-refactor paredit paren-face auto-complete go-autocomplete go-eldoc yasnippet flycheck go-mode highlight-numbers hl-todo)))
 '(pdf-tools-handle-upgrades nil)
 '(powerline-default-separator (quote wave))
 '(projectile-mode t nil (projectile))
 '(send-mail-function (quote smtpmail-send-it))
 '(temporary-file-directory "/tmp")
 '(tool-bar-mode nil)
 '(truncate-lines t)
 '(yas-global-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#181a26" :foreground "gray80" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 114 :width normal :foundry "pyrs" :family "Roboto Mono"))))
 '(highlight ((t (:underline t))))
 '(js2-object-property ((t (:inherit default :foreground "goldenrod"))))
 '(line-number ((t (:inherit (shadow default) :foreground "gray34"))))
 '(line-number-current-line ((t (:inherit line-number :foreground "gray60"))))
 '(link ((t (:slant italic))))
 '(mode-line ((t (:background "dim gray" :foreground "black" :box (:line-width 1 :style released-button)))))
 '(parenthesis ((t (:inherit default :foreground "dim gray"))))
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
