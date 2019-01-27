(require 'align)
;; Highlight and allow to open http link at point in programming buffers
;; goto-address-prog-mode only highlights links in strings and comments
;(add-hook 'prog-mode-hook 'goto-address-prog-mode)
;; Highlight and follow bug references in comments and strings
;(add-hook 'prog-mode-hook 'bug-reference-prog-mode)
(add-hook 'prog-mode-hook (lambda ()
                            (display-line-numbers-mode)
                            (highlight-numbers-mode)
                            (hl-todo-mode)
                            (yas-minor-mode-on)
                            (setq-local show-paren-mode t)))

(add-hook 'prog-mode-hook (lambda ()
                            (local-set-key (kbd "RET") (key-binding (kbd "M-j")))))

(provide 'mode-prog-mode)
