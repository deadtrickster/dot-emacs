
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

;; (defun vterm--rename-buffer-as-title (title)
;;   (let ((dir (concat (nth 1 (split-string title ":")) "/")))
;;     (cd dir))
;;   (rename-buffer (format "term %s" title)))
;;

(define-key vterm-mode-map [?\C-c] nil)
(define-key vterm-mode-map [?\C-c ?\C-c] 'vterm--self-insert)
(define-key vterm-mode-map [delete] #'vterm--self-insert)

(make-local-variable 'vterm-is-for-project)
(setq-default vterm-is-for-project nil)

(defun vterm--rename-buffer-as-title (title)
  (let ((dir (concat (nth 1 (split-string title ":")) "/")))
    (cd dir)
    (rename-buffer (if vterm-is-for-project
                       (vterm--project-buffer-title)
                     (vterm--buffer-title)))))

(add-hook 'vterm-set-title-functions 'vterm--rename-buffer-as-title)

(defun vterm--buffer-title ()
  (format "term %s@%s:%s" user-login-name (system-name) default-directory))

(defun vterm--project-buffer-title ()
  (format "term %s" (projectile-project-name)))

(defun vt ()
  "Create a new vterm."
  (interactive)
  (let* ((buffer-title (vterm--buffer-title))
         (existing-buffer (get-buffer buffer-title)))
    (if existing-buffer
        (switch-to-buffer existing-buffer)
      (let ((buffer (generate-new-buffer buffer-title)))
        (with-current-buffer buffer
          (vterm-mode))
        (switch-to-buffer buffer)))))

(defun vtp ()
  "Create a new vterm."
  (interactive)
  (let* ((buffer-title (vterm--project-buffer-title))
         (existing-buffer (get-buffer buffer-title)))
    (if existing-buffer
        (switch-to-buffer existing-buffer)
      (let ((buffer (generate-new-buffer buffer-title)))
        (with-current-buffer buffer
          (cd (projectile-project-root))
          (vterm-mode)
          (setq-local vterm-is-for-project t))
        (switch-to-buffer buffer)))))

(define-key global-map [?\C-t] 'vtp)

(provide 'mode-vterm)
