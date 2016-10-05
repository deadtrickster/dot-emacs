
(require 'iedit)

(setf iedit-mode t)

(define-key global-map (kbd "C-;") 'iedit-mode)
(define-key isearch-mode-map (kbd "C-;") 'iedit-mode-from-isearch)
(define-key esc-map (kbd "C-;") 'iedit-execute-last-modification)
(define-key help-map (kbd "C-;") 'iedit-mode-toggle-on-function)


(define-key iedit-lib-keymap (kbd "TAB") 'indent-for-tab-command)
(define-key iedit-lib-keymap (kbd "<tab>") 'indent-for-tab-command)

(provide 'mode-iedit)
