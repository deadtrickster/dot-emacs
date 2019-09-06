
(add-to-list 'load-path "/home/dead/Projects/emacs-libvterm")

(require 'vterm)

(define-key vterm-mode-map [?\C-c] nil)

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

(make-local-variable 'vterm-is-for-project)
(setq-default vterm-is-for-project nil)

(make-local-variable 'vterm-called-from)
(setq-default vterm-called-from nil)

(defun vterm--rename-buffer-as-title (title)
  (let ((dir (string-trim-left (concat (nth 1 (split-string title ":")) "/"))))
    (when (ignore-errors (file-directory-p dir))
      (cd-absolute dir))
    (if (and vterm-is-for-project (not (projectile-project-p)))
        ;; we left project directory
        (setq-local vterm-is-for-project nil))
    (unless vterm-is-for-project
      (rename-buffer (vterm--buffer-title) t))))

(add-hook 'vterm-set-title-functions 'vterm--rename-buffer-as-title)

(defun vterm--buffer-title ()
  (format "term %s@%s:%s" user-login-name (system-name) default-directory))

(defun vterm--project-buffer-title ()
  (format "term %s" (projectile-project-name)))

(defun vt ()
  "Create a new vterm."
  (interactive)
  (let* ((buffer-title (vterm--buffer-title))
         (buffer (or (get-buffer buffer-title)
                     (let ((buffer (generate-new-buffer buffer-title)))
                       (with-current-buffer buffer
                         (vterm-mode))
                       buffer))))
    (switch-to-buffer buffer)))

(defun vtp ()
  "Create a new vterm."
  (interactive)
  (let* ((buffer-title (vterm--project-buffer-title))
         (buffer (or (get-buffer buffer-title)
                     (let ((buffer (generate-new-buffer buffer-title)))
                       (with-current-buffer buffer
                         (cd (projectile-project-root))
                         (vterm-mode)
                         (setq-local vterm-is-for-project t))
                       buffer)))
         (cb (current-buffer)))
    (with-current-buffer buffer
      (setq-local vterm-called-from cb))
    (switch-to-buffer buffer)))

(define-key global-map [?\C-t] 'vtp)

(define-key vterm-mode-map [?\C-c] nil)
(define-key vterm-mode-map [?\C-c ?\C-c] 'vterm--self-insert)
(define-key vterm-mode-map [delete] #'vterm--self-insert)

(defun maybe-go-back-to-caller-buffer ()
  "Switch back to caller buffer."
  (interactive)
  (when vterm-called-from
    (switch-to-buffer vterm-called-from)))

(define-key vterm-mode-map [?\C-t] 'maybe-go-back-to-caller-buffer)

(define-key vterm-mode-map [kp-0] "0")
(define-key vterm-mode-map [kp-1] "1")
(define-key vterm-mode-map [kp-2] "2")
(define-key vterm-mode-map [kp-3] "3")
(define-key vterm-mode-map [kp-4] "4")
(define-key vterm-mode-map [kp-5] "5")
(define-key vterm-mode-map [kp-6] "6")
(define-key vterm-mode-map [kp-7] "7")
(define-key vterm-mode-map [kp-8] "8")
(define-key vterm-mode-map [kp-9] "9")
(define-key vterm-mode-map [kp-enter] [return])
(define-key vterm-mode-map [kp-home] [home])
(define-key vterm-mode-map [kp-end] [end])
(define-key vterm-mode-map [kp-left] [left])
(define-key vterm-mode-map [kp-right] [right])
(define-key vterm-mode-map [kp-down] [down])
(define-key vterm-mode-map [kp-up] [up])
(define-key vterm-mode-map [kp-divide] "/")
(define-key vterm-mode-map [kp-multiply] "*")
(define-key vterm-mode-map [kp-subtract] "-")
(define-key vterm-mode-map [kp-add] "+")
(define-key vterm-mode-map [kp-decimal] ".")
(define-key vterm-mode-map [insert] #'vterm-yank)

(provide 'mode-vterm)
