(require 'company)
(company-tng-configure-default)
(global-company-mode)

(with-eval-after-load 'company
  (setf company-backends '(company-capf company-files (company-dabbrev-code company-gtags company-etags company-keywords) company-dabbrev)
        )
  (define-key company-active-map (kbd "<return>") #'company-complete-selection)
  (define-key company-active-map (kbd "RET") #'company-complete-selection))

(defun company-preview-if-not-tng-frontend (command)
  "`company-preview-frontend', but not when tng is active."
  (unless (and (eq command 'post-command)
               company-selection-changed
               (memq 'company-tng-frontend company-frontends))
    (company-preview-frontend command)))


(setq company-frontends
      '(company-tng-frontend
        company-pseudo-tooltip-unless-just-one-frontend
        company-preview-if-not-tng-frontend
        company-echo-metadata-frontend))

(push (apply-partially #'cl-remove-if
                       (lambda (c)
                         (or
                          (string-match-p "^[[:digit:]-#]+" c))))
      company-transformers)

;;(require 'company-statistics)
;;(company-statistics-mode)

(provide 'mode-company)
