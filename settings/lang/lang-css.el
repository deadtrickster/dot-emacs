(require 'css-mode)

(add-hook 'css-mode-hook
	  (lambda ()
            (setq indent-tabs-mode nil)
	    (company-mode)
	    ;; (local-set-key (kbd "RET") 'newline-and-indent)
	    (setq-local company-backends '(company-css company-capf company-files (company-dabbrev-code company-gtags company-etags company-keywords) company-dabbrev))))

(setq css-indent-offset 2)

(provide 'lang-css)
