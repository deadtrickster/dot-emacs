(require 'company)
(require 'company-clang)

(setq company-clang--version (company-clang-version))

(add-hook 'c++-mode-hook
	  (lambda ()
            (setq indent-tabs-mode nil)
	    (company-mode)
            (flymake-mode 0)
	    (setf company-clang-arguments '("-std=gnu++11")
		  auto-complete-mode -1)
	    ;; (local-set-key (kbd "RET") 'newline-and-indent)
	    (setq-local company-backends '(company-c-headers (company-keywords company-dabbrev-code) company-files company-capf company-dabbrev))))

(add-hook 'c-mode-hook
	  (lambda ()
            (setq indent-tabs-mode nil)
	    (company-mode)
            (flymake-mode 0)
	    (setf company-clang-arguments '("-std=gnu++11")
		  auto-complete-mode -1)
	    ;; (local-set-key (kbd "RET") 'newline-and-indent)
	    (setq-local company-backends '(company-c-headers (company-keywords company-dabbrev-code) company-files company-capf company-dabbrev))))

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(provide 'lang-cpp)
