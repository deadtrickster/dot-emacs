(setq elixir-mode-hook
      (function (lambda ()
                  (setq indent-tabs-mode nil)
		  (alchemist-mode)
		  (company-mode)
		  (flycheck-credo-setup)
		  (local-set-key (kbd "RET") 'newline-and-indent))))

(provide 'lang-elixir)
