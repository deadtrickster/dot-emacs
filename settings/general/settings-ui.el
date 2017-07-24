;;; ui --- Generic ui stuff: theming, scrolling, etc

;;; Commentary:

;;; Code:

(load-theme 'deeper-blue)

(require 'smooth-scroll)
(setf smooth-scroll-mode t)

(defun powerline-my-theme ()
  "Setup the default mode-line."
  (interactive)
  (setq-default mode-line-format
                '("%e"
                  (:eval
                   (let* ((active (powerline-selected-window-active))
                          (mode-line-buffer-id (if active 'mode-line-buffer-id 'mode-line-buffer-id-inactive))
                          (mode-line (if active 'mode-line 'mode-line-inactive))
                          (face1 (if active 'powerline-active1 'powerline-inactive1))
                          (face2 (if active 'powerline-active2 'powerline-inactive2))
                          (separator-left (intern (format "powerline-%s-%s"
                                                          (powerline-current-separator)
                                                          (car powerline-default-separator-dir))))
                          (separator-right (intern (format "powerline-%s-%s"
                                                           (powerline-current-separator)
                                                           (cdr powerline-default-separator-dir))))
                          (lhs
                           (list (powerline-raw mode-line-modified mode-line 'l)
				 (powerline-raw "%4l" mode-line 'l)
                                 (powerline-raw ": " mode-line 'l)
                                 (powerline-raw "%3c" mode-line 'r)
                                 (powerline-raw " " mode-line)
                                 ;; (powerline-raw "%6p" mode-line 'r)
                                 (powerline-buffer-id mode-line-buffer-id 'l)
                                 (when (and (boundp 'which-func-mode) which-func-mode)
                                   (powerline-raw which-func-format nil 'l))
                                 (powerline-raw " ")
                                 (funcall separator-left mode-line face1)
                                 (when (and (boundp 'erc-track-minor-mode) erc-track-minor-mode)
                                   (powerline-raw erc-modified-channels-object face1 'l))
                                 (powerline-major-mode face1 'l)
                                 (powerline-process face1)
                                 ;; (powerline-minor-modes face1 'l)
                                 (powerline-narrow face1 'l)
                                 (powerline-raw " " face1)
                                 (funcall separator-left face1 face2)
                                 (powerline-vc face2 'r)
                                 (when (bound-and-true-p nyan-mode)
                                   (powerline-raw (list (nyan-create)) face2 'l))))
                          (rhs
                           (list (powerline-raw global-mode-string face2 'r)
                                 (funcall separator-right face2 face1)
                                 (unless window-system
                                   (powerline-raw (char-to-string #xe0a1) face1 'l))
                                 (powerline-buffer-size face1 'l)
                                 (powerline-raw " " face1)
                                 (funcall separator-right face1 mode-line)
                                 (when powerline-display-hud
                                   (powerline-hud face2 face1)))))
                     (concat (powerline-render lhs)
                             (powerline-fill face2 (powerline-width rhs))
                             (powerline-render rhs)))))))

(powerline-my-theme)

(setq frame-title-format
      '(buffer-file-name "%f"
			 (dired-directory dired-directory "%b")))

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
