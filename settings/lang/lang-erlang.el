(add-hook ' erlang-mode-hook
      (function (lambda ()
                  (setq indent-tabs-mode nil)
		  (local-set-key (kbd "RET") 'newline-and-indent))))

(setq  erlang-indent-level 2)

(require 'ivy-erlang-complete)
(add-hook 'erlang-mode-hook #'ivy-erlang-complete-init)
;; automatic update completion data after save
(add-hook 'after-save-hook #'ivy-erlang-complete-reparse)

;; (add-to-list 'load-path
;; 	     "/usr/local/lib/erlang/lib/wrangler-1.2.0/elisp")
;; (require 'wrangler)

(add-to-list 'auto-mode-alist '("rebar.config" . erlang-mode))
(add-to-list 'auto-mode-alist '("sys.config" . erlang-mode))
(add-to-list 'auto-mode-alist '("elvis.config" . erlang-mode))
(provide 'lang-erlang)
