(require 'company)
(require 'company-erlang)
(require 'company-keywords)
(require 'projectile)

(add-hook 'erlang-mode-hook
          (function (lambda ()
                      (setq indent-tabs-mode nil)
                      ;; (local-set-key (kbd "RET") 'newline-and-indent)
                      (company-mode)
                      (setq-local ivy-erlang-complete-project-root (projectile-project-root))
                      (setq-local company-backends '((company-erlang company-keywords company-dabbrev-code) company-files company-capf company-dabbrev)))))

(setq  erlang-indent-level 2)

(require 'ivy-erlang-complete)
(add-hook 'erlang-mode-hook (lambda () (ignore-errors (ivy-erlang-complete-init))))
;; automatic update completion data after save
(add-hook 'after-save-hook #'ivy-erlang-complete-reparse)

;; (add-to-list 'load-path
;;           "/usr/local/lib/erlang/lib/wrangler-1.2.0/elisp")
;; (require 'wrangler)

(add-to-list 'auto-mode-alist '("rebar.config" . erlang-mode))
(add-to-list 'auto-mode-alist '("sys.config" . erlang-mode))
(add-to-list 'auto-mode-alist '("elvis.config" . erlang-mode))

(add-to-list 'company-keywords-alist
             '(erlang-mode "after" "and" "andalso" "band" "begin" "bnot"
                           "bor" "bsl" "bsr" "bxor" "case"
                           "catch" "cond" "div" "end" "fun"
                           "if" "let" "not" "of" "or"
                           "orelse" "query" "receive" "rem" "try" "when"
                           "xor"))

(require 'flycheck-rebar3)
(flycheck-rebar3-setup)

(with-eval-after-load 'erlang-mode
  (bind-key [f12] (lambda ()
                    (interactive)
                    (delete-trailing-whitespace)
                    (erlang-format))
            erlang-mode-map))

(require 'erlang-format)

(setq erlfmt-erlang-ls "/home/dead/Projects/erlang/sourcer/_build/default/bin/erlang_ls")

(add-hook 'erlang-format-hook '(lambda ()
                                 (if (projectile-project-p)
                                     (let ((sourcer-config-filename (concat (projectile-project-root) "/.sourcer.config")))
                                       (when (file-exists-p sourcer-config-filename)
                                         (setq erlfmt-args (list "--config" sourcer-config-filename))))
                                   (setq erlfmt-args nil))))

(provide 'lang-erlang)
