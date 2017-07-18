(delete-selection-mode 1)

(add-hook 'prog-mode-hook 'highlight-numbers-mode)
(add-hook 'prog-mode-hook 'hl-todo-mode)

(defun my-turn-off-some-parens ()
  "Turn on brackets and braces as paren characters."
  (interactive)
  (modify-syntax-entry ?\[ "(")
  (modify-syntax-entry ?\] ")")
  (modify-syntax-entry ?\{ "(")
  (modify-syntax-entry ?\} ")"))
(add-hook 'lisp-mode-hook 'my-turn-off-some-parens)
(add-hook 'common-lisp-mode-hook 'my-turn-off-some-parens)

(add-hook 'after-make-frame-functions
          (lambda (frame)
	    (with-selected-frame frame
              (keyboard-translate ?\( ?\[)
              (keyboard-translate ?\[ ?\()
              (keyboard-translate ?\) ?\])
              (keyboard-translate ?\] ?\)))))

(setq default-input-method "cyrillic-jcuken")

(provide 'settings-editing)
