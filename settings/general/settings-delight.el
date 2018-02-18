(require 'delight)

(defun apply-my-delight-list ()
  (delight '((company-mode nil company)
             (eldoc-mode nil eldoc)
             (flyspell-mode nil flyspell)
             (paredit-mode nil paredit)
             (rainbow-mode nil rainbow-mode)
             (yas-minor-mode nil yasnippet)
             (page-break-lines-mode nil page-break-lines)
             (projectile-mode nil projectile))))

(apply-my-delight-list)

(provide 'settings-delight)
