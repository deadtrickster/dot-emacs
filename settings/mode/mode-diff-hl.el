
(defun enable-diff-hl-mode ()
  (diff-hl-mode)
  (diff-hl-flydiff-mode))

(add-hook 'text-mode-hook 'enable-diff-hl-mode)
(add-hook 'prog-mode-hook 'enable-diff-hl-mode)

(provide 'mode-diff-hl)