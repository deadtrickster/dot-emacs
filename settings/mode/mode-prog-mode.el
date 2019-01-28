(require 'align)
;; Highlight and allow to open http link at point in programming buffers
;; goto-address-prog-mode only highlights links in strings and comments
;(add-hook 'prog-mode-hook 'goto-address-prog-mode)
;; Highlight and follow bug references in comments and strings
;(add-hook 'prog-mode-hook 'bug-reference-prog-mode)
;
;(setf prog-mode-hook nil)
(add-hook 'prog-mode-hook '(lambda ()
                             (display-line-numbers-mode 1)
                             (highlight-numbers-mode 1)
                             (flycheck-mode 1)
                             (hl-todo-mode 1)
                             (auto-composition-mode 1)
                             (auto-revert-mode 1)
                             (auto-insert-mode 1)
                             (company-mode 1)
                             (delete-selection-mode 1)
                             (diff-auto-refine-mode 1)
                             (diff-hl-mode 1)
                             (diff-hl-flydiff-mode 1)
                             (electric-indent-local-mode 1)
                             (hl-todo-mode 1)
                             (file-name-shadow-mode 1)
                             (yas-minor-mode 1)
                             ;;(enable-paredit-mode)
                             (paren-face-mode 1)
                             (show-paren-mode 1)
                             (turn-on-eldoc-mode)
                             
                             (local-set-key (kbd "RET") (key-binding (kbd "M-j")))))

(provide 'mode-prog-mode)
