
(setf iedit-mode t)

(define-key global-map (kbd "C-;") 'iedit-mode)
(define-key isearch-mode-map (kbd "C-;") 'iedit-mode-from-isearch)
(define-key esc-map (kbd "C-;") 'iedit-execute-last-modification)
(define-key help-map (kbd "C-;") 'iedit-mode-toggle-on-function)

(provide 'mode-iedit)
