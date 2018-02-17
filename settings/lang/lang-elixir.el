(require 'company)

(add-hook 'elixir-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (local-set-key (kbd "RET") 'newline-and-indent)
            (alchemist-mode)
            (company-mode)
            (setq-local company-backends '((alchemist-company :with company-yasnippet) (company-keywords company-dabbrev-code) company-files company-capf company-dabbrev))))

(eval-after-load 'flycheck
  '(flycheck-credo-setup))

(eval-after-load 'flycheck
  '(flycheck-dialyxir-setup))

(eval-after-load 'flycheck-credo
  '(setq flycheck-elixir-credo-strict t))

(with-eval-after-load 'elixir-mode
  (bind-key [f12] 'mix-format elixir-mode-map))

(require 'mix-format)

(setq mixfmt-mix "/usr/local/bin/mix")

(provide 'lang-elixir)
