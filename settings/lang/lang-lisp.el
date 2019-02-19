(add-hook 'emacs-lisp-mode-hook (lambda ()
                            (paren-face-mode)))

(add-hook 'lisp-mode-hook (lambda ()
                            (paren-face-mode)))

(provide 'lang-lisp)
