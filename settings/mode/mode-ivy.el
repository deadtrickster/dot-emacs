(use-package ivy
  :diminish ivy-mode
  :config
  (setf ivy-wrap t)
  (define-key ivy-minibuffer-map (kbd "<down>") 'ivy-next-line)
  (define-key ivy-minibuffer-map (kbd "<up>") 'ivy-previous-line))

(provide 'mode-ivy)
