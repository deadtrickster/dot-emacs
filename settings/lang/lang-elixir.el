(setq elixir-mode-hook
      (function (lambda ()
                  (setq indent-tabs-mode nil)
		  (alchemist-mode)
		  (company-mode)
		  (local-set-key (kbd "RET") 'newline-and-indent))))

(require 'flycheck-credo)
(flycheck-credo-setup)

(provide 'lang-elixir)
