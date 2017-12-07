(add-to-list 'auto-mode-alist '("\\.log\\'" . auto-revert-tail-mode))

(make-variable-buffer-local 'auto-revert-interval)
(make-variable-buffer-local 'auto-revert-verbose)

;; inspired by https://emacs.stackexchange.com/a/13010
;; TODO: replace with custom mode
(defun my-log-tail-handler ()
  (setf auto-revert-interval 1
        auto-revert-verbose nil
	truncate-lines nil)
  (auto-revert-set-timer)
  (read-only-mode t)
  (font-lock-mode 0)
  (show-paren-mode 0)
  (auto-composition-mode 0)
  (diff-auto-refine-mode 0)
  (diff-hl-flydiff-mode 0)
  (electric-indent-mode 0)
  (auto-complete-mode 0)
  (eldoc-mode 0)
  (flycheck-mode 0)
  (font-lock-mode 0)
  (paren-face-mode 0)
  (when (fboundp 'show-smartparens-mode)
    (show-smartparens-mode 0))
  (goto-char (point-max)))

(add-hook 'auto-revert-tail-mode-hook 'my-log-tail-handler)

(provide 'mode-log)
