(require 'autorevert)

(setq font-lock-mode -1
      )

(define-derived-mode log-mode fundamental-mode "Log"
  "Major mode for log files."
  (setq-local auto-revert-interval 1)
  (setq-local auto-revert-verbose nil)
  (setq-local truncate-lines nil)
  (setq-local auto-revert-set-timer nil)
  (read-only-mode 1)
  (font-lock-mode 0)
  (show-paren-mode 0)
  (auto-composition-mode 0)
  (diff-auto-refine-mode 0)
  (diff-hl-flydiff-mode 0)
  (electric-indent-mode 0)
  (auto-complete-mode 0)
  (company-mode 0)
  (eldoc-mode 0)
  (flycheck-mode 0)
  (paren-face-mode 0)
  (when (fboundp 'show-smartparens-mode)
    (show-smartparens-mode 0))
  (auto-revert-tail-mode 1)
  (goto-char (point-max))
  (run-mode-hooks))

(add-to-list 'auto-mode-alist '("\\.log\\'" . log-mode))

;; ;; inspired by https://emacs.stackexchange.com/a/13010
;; ;; TODO: replace with custom mode
;; (defun my-log-tail-handler ()

;; (add-hook 'auto-revert-tail-mode-hook 'my-log-tail-handler)

(provide 'mode-log)
