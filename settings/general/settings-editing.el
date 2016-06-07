(delete-selection-mode 1)

(add-hook 'prog-mode-hook 'highlight-numbers-mode)
(add-hook 'prog-mode-hook 'hl-todo-mode)

(global-flycheck-mode)

(yas-global-mode 1)

(require 'paren-face)
(global-paren-face-mode)

(eval-after-load 'paredit
  '(progn
     (define-key paredit-mode-map (kbd "<C-right>") nil)
     (define-key paredit-mode-map (kbd "<C-left>") nil)
     (define-key paredit-mode-map (kbd "<C-)>") nil)
     (define-key paredit-mode-map (kbd "<C-(>") nil)
     (define-key paredit-mode-map (kbd "<C-]>") 'paredit-forward-slurp-sexp)
     (define-key paredit-mode-map (kbd "<C-[>") 'paredit-backward-slurp-sexp)))

(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)
(put 'paredit-forward-delete 'delete-selection 'supersede)
(put 'paredit-backward-delete 'delete-selection 'supersede)
(put 'paredit-newline 'delete-selection t)

(show-paren-mode 1)

(require 'iedit)
(setf iedit-mode t)

(defun my-turn-off-some-parens ()
  "Turn on brackets and braces as paren characters."
  (interactive)
  (modify-syntax-entry ?\[ "(")
  (modify-syntax-entry ?\] ")")
  (modify-syntax-entry ?\{ "(")
  (modify-syntax-entry ?\} ")"))
(add-hook 'lisp-mode-hook 'my-turn-off-some-parens)
(add-hook 'common-lisp-mode-hook 'my-turn-off-some-parens)


(keyboard-translate ?\( ?\[)
(keyboard-translate ?\[ ?\()
(keyboard-translate ?\) ?\])
(keyboard-translate ?\] ?\))

(provide 'settings-editing)
