
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
 '(inhibit-startup-echo-area-message "dead")
 '(inhibit-startup-screen t)
 '(package-selected-packages
   (quote
    (smart-mode-line smart-mode-line-powerline-theme diff-hl json-mode flycheck-elixir flycheck-mix less-css-mode sass-mode scss-mode php-mode iedit alchemist web-mode rainbow-mode erlang ac-slime js2-refactor js2-mode paredit paren-face auto-complete go-autocomplete go-eldoc yasnippet flycheck go-mode highlight-numbers hl-todo)))
 '(powerline-default-separator (quote wave))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Roboto Mono" :foundry "unknown" :slant normal :weight normal :height 113 :width normal))))
 '(js2-object-property ((t (:inherit default :foreground "goldenrod"))))
 '(mode-line ((t (:background "dim gray" :foreground "black" :box (:line-width 1 :style released-button)))))
 '(parenthesis ((t (:inherit default :foreground "dim gray"))))
 '(show-paren-match ((t (:background "#2f334b")))))

(load "~/.emacs.d/paths.el")

(require 'settings)
(server-start)

