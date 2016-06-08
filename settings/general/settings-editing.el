(delete-selection-mode 1)

(add-hook 'prog-mode-hook 'highlight-numbers-mode)
(add-hook 'prog-mode-hook 'hl-todo-mode)

(yas-global-mode 1)

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
