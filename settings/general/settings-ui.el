;;; ui --- Generic ui stuff: theming, scrolling, etc

;;; Commentary:

;;; Code:

(load-theme 'deeper-blue)

;; (require 'smooth-scroll)
;; (setf smooth-scroll-mode t)

(defun figure-out-file-name ()
  (if (equal major-mode 'dired-mode)
      default-directory
    (buffer-file-name)))

(defun copy-file-name ()
  "Put the current file name on the clipboard"
  (interactive)
  (let ((filename (figure-out-file-name)))
    (when filename
      (let ((select-enable-clipboard t))
        (kill-new filename))
      (message filename))))

(defun browse-file-directory ()
  "Open the current file's directory however the OS would."
  (interactive)
  (if default-directory
      (browse-url-of-file (expand-file-name default-directory))
    (error "No `default-directory' to open")))

(defun my-powerline-buffer-id (&optional face pad)
  (let ((filename (figure-out-file-name)))
    (powerline-raw
     (format-mode-line
      (concat (propertize
               "%b"
               'face face
               'mouse-face 'mode-line-highlight
               'help-echo (concat filename "\n\ mouse-1: Copy filename\n\ mouse-3: Open directory")
               'local-map (let ((map (make-sparse-keymap)))
                            (define-key map [mode-line mouse-1] 'copy-file-name)
                            (define-key map [mode-line mouse-3] 'browse-file-directory)
                            map))))
     face pad)))

(defpowerline my-powerline-vc
  (when (and (buffer-file-name (current-buffer)) vc-mode)
    (if (and window-system (not powerline-gui-use-vcs-glyph))
	(format-mode-line '(vc-mode vc-mode))
      (format "_%s%s"
	      (char-to-string #xe0a0)
	      (format-mode-line '(vc-mode vc-mode))))))

(defun powerline-my-theme ()
  "Setup the default mode-line."
  (interactive)
  (setq-default mode-line-format
                '("%e"
                  (:eval
                   (let* ((active (powerline-selected-window-active))
                          (mode-line-buffer-id (if active 'mode-line-buffer-id 'mode-line-buffer-id-inactive))
                          (face1 (if active 'powerline-active1 'powerline-inactive1))
                          (face2 (if active 'powerline-active2 'powerline-inactive2))
                          (separator-left (intern (format "powerline-%s-%s"
                                                          (powerline-current-separator)
                                                          (car powerline-default-separator-dir))))
                          (separator-right (intern (format "powerline-%s-%s"
                                                           (powerline-current-separator)
                                                           (cdr powerline-default-separator-dir))))
                          (lhs
                           (list (powerline-raw mode-line-modified face2 'l)
                                 (powerline-raw "%4l" face2 'l)
                                 (powerline-raw ": " face2 'l)
                                 (powerline-raw "%3c" face2 'r)
                                 (powerline-raw " " face2)
                                 (powerline-raw " " face2)))
                          (center
                           (list (funcall separator-right face2 face1)
                                 (my-powerline-buffer-id mode-line-buffer-id 'l)
                                 (powerline-major-mode face1 'l)
                                 (powerline-process face1)
                                 (powerline-minor-modes face1 'l)
                                 (my-powerline-vc face1 'l)
                                 (powerline-narrow face1 'l)
                                 (powerline-raw " " face1)
                                 (funcall separator-left face1 face2)))
                          (rhs
                           (list ;; (powerline-raw "%p" face2 'l)
                                 (powerline-raw "   " face2))))
                     (concat (powerline-render lhs)
                             (powerline-fill-center face2 (/ (powerline-width center) 2.0))
                             (powerline-render center)
                             (powerline-fill face2 (powerline-width rhs))
                             (powerline-render rhs)))))))

(powerline-my-theme)

(setq frame-title-format
      '(buffer-file-name "%f"
                         (dired-directory dired-directory "%b")))


(show-paren-mode)

(setq show-paren-mode nil)

;; (add-hook 'minibuffer-setup-hook (lambda ()
;;                                    (setq-local show-paren-mode nil)))

(provide 'settings-ui)

;;; settings-ui.el ends here
;; (defvar my-mode-line-map (assq 'alchemist-mode minor-mode-map-alist))
;;   (let ((map (make-sparse-keymap)))
;;     (define-key map [mode-line down-mouse-1]
;;       ;; (make-sparse-keymap)
;;       (assq 'alchemist-mode minor-mode-map-alist))
;;     map))

;; (setq global-mode-string
;;   (append global-mode-string
;;     (list
;;       (propertize "Qwestring-name"
;;         'local-map my-mode-line-map
;;         'mouse-face 'mode-line-highlight))))

;; (define-key my-mode-line-map
;;    (vconcat [mode-line down-mouse-1]
;;      (list "123some_generated_id_for_future_use"))
;;    (cons "qwe" (lambda () (print "qwe"))))

;; (define-key my-mode-line-map
;;    (vconcat [mode-line down-mouse-1]
;;      (list "Alchemist"))
;;    (cons "Alchemist" (assq 'alchemist-mode minor-mode-map-alist)))

;; ;; minor-mode-alist

;; ;; (mapcar #'car minor-mode-alist)

;; ;; (describe-mode)

;; (defun which-active-modes ()
;;   "Give a message of which minor modes are enabled in the current buffer."
;;   (interactive)
;;   (let ((active-modes))
;;     (mapc (lambda (mode) (condition-case nil
;;                              (if (and (symbolp mode) (symbol-value mode))
;;                                  (add-to-list 'active-modes mode))
;;                            ((error "message" format-args) nil) ))
;;           minor-mode-list)
;;     (message "Active modes are %s" active-modes)))

;; (assq 'alchemist-mode minor-mode-map-alist)

;; (defpowerline powerline-minor-modes1
;;   (mapconcat (lambda (mm)
;;                (propertize mm
;;                            'mouse-face 'mode-line-highlight
;;                            'help-echo "Minor mode\n mouse-1: Display minor mode menu\n mouse-2: Show help for minor mode\n mouse-3: Toggle minor modes"
;;                            'local-map (let ((map (make-sparse-keymap)))
;;                                         (define-key map
;;                                           [mode-line down-mouse-1]
;;                                           (powerline-mouse 'minor 'menu mm))
;;                                         (define-key map
;;                                           [mode-line mouse-2]
;;                                           (powerline-mouse 'minor 'help mm))
;;                                         (define-key map
;;                                           [mode-line down-mouse-3]
;;                                           (powerline-mouse 'minor 'menu mm))
;;                                         (define-key map
;;                                           [header-line down-mouse-3]
;;                                           (powerline-mouse 'minor 'menu mm))
;;                                         map)))
;;              (split-string (format-mode-line minor-mode-alist))
;;              (propertize " " 'face face)))
