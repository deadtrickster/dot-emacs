(require 'delight)

;; (add-hook 'after-make-frame-functions
;;           (lambda (_)
;;             (diminish 'flyspell-mode)
;;             (diminish 'paredit-mode)
;;             (diminish 'rainbow-mode)
;;             (diminish 'eldoc-mode)
;;             (diminish 'company-mode)
;;             (diminish 'yas-minor-mode)))

(defun apply-my-delight-list ()
  (delight '(
             (company-mode nil company)
             (eldoc-mode nil eldoc)
             (flyspell-mode nil flyspell)
             (paredit-mode nil paredit)
             (rainbow-mode nil rainbow-mode)
             (yas-minor-mode nil yasnippet)
             (page-break-lines-mode nil page-break-lines)
             )))

(apply-my-delight-list)

(provide 'settings-delight)
