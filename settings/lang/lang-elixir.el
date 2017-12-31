(require 'company)

(add-hook 'elixir-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (local-set-key (kbd "RET") 'newline-and-indent)
            (alchemist-mode)
            (company-mode)
            (setq-local company-backends '((alchemist-company :with company-yasnippet) (company-keywords company-dabbrev-code) company-files company-capf company-dabbrev))))

(require 'flycheck-credo)
(flycheck-credo-setup)

(provide 'lang-elixir)
