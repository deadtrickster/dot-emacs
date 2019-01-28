
(add-to-list 'load-path "/home/dead/Projects/emacs-libvterm")

(require 'vterm)

;; (add-hook 'vterm-mode-hook (lambda ()
;;                              (setq-local auto-revert-interval 1)
;;                              (setq-local auto-revert-verbose nil)
;;                              (setq-local truncate-lines nil)
;;                              (setq-local auto-revert-set-timer nil)
;;                              (auto-complete-mode 0)
;;                              (auto-composition-mode 0)
;;                              (auto-insert-mode 0)
;;                              (auto-revert-mode 0)
;;                              (company-mode 0)
;;                              (diff-auto-refine-mode 0)
;;                              (diff-hl-mode 0)
;;                              (diff-hl-flydiff-mode 0)
;;                              (eldoc-mode 0)
;;                              (electric-indent-local-mode 0)
;;                              (hl-todo-mode nil)
;;                              (file-name-shadow-mode 0)
;;                              (yas-minor-mode 0)
;;                              (paren-face-mode 0)
;;                              (setq-local show-paren-mode nil)))

(add-hook 'vterm-mode-hook (lambda ()
                             (setf truncate-lines nil)
                             (setq-local show-paren-mode nil)
                             (yas-minor-mode -1)
                             (flycheck-mode -1)))

(defun vterm--rename-buffer-as-title (title)
  (let ((dir (concat (nth 1 (split-string title ":")) "/")))
    (cd dir))
  (rename-buffer (format "term %s" title)))

(add-hook 'vterm-set-title-functions 'vterm--rename-buffer-as-title)

(define-key vterm-mode-map [?\C-c] nil)
(define-key vterm-mode-map [?\C-c ?\C-c] 'vterm--self-insert)

(provide 'mode-vterm)
