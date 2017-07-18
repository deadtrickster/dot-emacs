
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
 '(doc-view-continuous t)
 '(erlang-argument-indent 2)
 '(erlang-icr-indent nil)
 '(git-messenger:show-detail t)
 '(git-messenger:use-magit-popup nil)
 '(hscroll-margin 1)
 '(hscroll-step 1)
 '(inhibit-startup-echo-area-message "dead")
 '(inhibit-startup-screen t)
 '(package-selected-packages
   (quote
    (git-messenger xterm-color magithub copy-as-format git-timemachine git-link scroll-restore counsel ivy company-erlang counsel-projectile projectile projectile-variable yatemplate ivy-erlang-complete dockerfile-mode ag company-nixos-options nix-buffer nix-mode nix-sandbox nixos-options flycheck-elixir flycheck-credo fill-column-indicator magit markdown-mode markdown-mode+ markdown-preview-mode markdown-toc yaml-mode elixir-yasnippets lfe-mode alchemist auctex flycheck-protobuf protobuf-mode ac-alchemist iedit ac-php ac-js2 powerline diff-hl json-mode flycheck-mix less-css-mode sass-mode scss-mode php-mode iedit alchemist web-mode rainbow-mode erlang ac-slime js2-refactor paredit paren-face auto-complete go-autocomplete go-eldoc yasnippet flycheck go-mode highlight-numbers hl-todo)))
 '(powerline-default-separator (quote wave))
 '(projectile-mode t nil (projectile))
 '(send-mail-function (quote smtpmail-send-it))
 '(temporary-file-directory "/mnt/ramdisk")
 '(tool-bar-mode nil)
 '(truncate-lines t)
 '(yas-global-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#181a26" :foreground "gray80" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight bold :height 114 :width normal :foundry "pyrs" :family "Roboto Mono"))))
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

(require 'settings)

;; Highlight and allow to open http link at point in programming buffers
;; goto-address-prog-mode only highlights links in strings and comments
(add-hook 'prog-mode-hook 'goto-address-prog-mode)
;; Highlight and follow bug references in comments and strings
(add-hook 'prog-mode-hook 'bug-reference-prog-mode)

(defun find-user-init-file ()
  "Edit the `user-init-file', in another window.
http://emacsredux.com/blog/2013/05/18/instant-access-to-init-dot-el/"
  (interactive)
  (find-file-other-window user-init-file))
