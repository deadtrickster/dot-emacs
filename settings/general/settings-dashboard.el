
(require 'use-package-bind-key)
(require 'use-package)
(require 'bind-key)

(defun dashboard-insert-workspaces-list (list-display-name list)
  "Render LIST-DISPLAY-NAME title and project items of LIST."
  (when (car list)
    (dashboard-insert-heading list-display-name)
    (mapc (lambda (w)
            (insert "\n    ")
            (widget-create 'push-button
                           :action `(lambda (&rest ignore)
                                      (treemacs)
				      (setf (treemacs-current-workspace) ,w))
                           :mouse-face 'highlight
                           :follow-link "\C-m"
                           :button-prefix ""
                           :button-suffix ""
                           :format "%[%t%]"
                           (abbreviate-file-name (treemacs-workspace->name w))))
          list)))

(defun dashboard-insert-workspaces (list-size)
  "Add the list of LIST-SIZE items of workspaces."
  ;; For some reason, projectile has to be loaded here
  ;; before trying to load projects list
  (require 'treemacs)
  (if (bound-and-true-p projectile-mode)
      (progn
	(when (dashboard-insert-workspaces-list
	       "Workspaces:"
	       (dashboard-subseq (treemacs-workspaces)
				 0 list-size))
	  (dashboard-insert-shortcut "p" "Workspaces:")))
    (message "Failed to load workspaces list")))

(use-package dashboard
  :bind (:map dashboard-mode-map
	      ("<down-mouse-1>" . (lambda () (interactive)))
	      ("<drag-mouse-1>" . (lambda () (interactive)))
	      ("<mouse-1>" . widget-button-click)
	      ("<mouse-2>" . widget-button-click))
  :config

  (setq dashboard-item-generators  '((recents    . dashboard-insert-recents)
                                     (bookmarks  . dashboard-insert-bookmarks)
                                     (projects   . dashboard-insert-projects)
                                     (workspaces . dashboard-insert-workspaces)
                                     (agenda     . dashboard-insert-agenda)
                                     (registers  . dashboard-insert-registers)))
  (setq dashboard-startup-banner 'official)
  (setq dashboard-items '((recents  . 20)
			  (workspaces . 20)
			  (bookmarks . 20)))
  (dashboard-setup-startup-hook))

(defun dashboard-insert-image-banner (banner)
  "Display an image BANNER."
  (when (file-exists-p banner)
    (let* ((title dashboard-banner-logo-title)
           (spec (create-image banner))
           (size (image-size spec))
           (width (car size))
           (left-margin (max 0 (floor (- dashboard-banner-length width) 2))))
      (goto-char (point-min))
      (insert "\n")
      (insert (make-string left-margin ?\ ))
      (insert-image spec)
      (insert "\n\n"))))

(dashboard-setup-startup-hook)

;; (add-hook 'dashboard-mode-hook
;; 		      (lambda ()
;; 			(setf display-line-numbers nil)))

(add-hook 'after-make-frame-functions
	  (lambda (frame)
            (when (= (length (frame-list)) 0)
	      (dashboard-refresh-buffer)
              (with-selected-frame frame
                (switch-to-buffer (get-buffer dashboard-buffer-name))
                ;; (bind-key "<down-mouse-1>" nil dashboard-mode-map)
                ;; (bind-key "<drag-mouse-1>" nil dashboard-mode-map)
                ;;(goto-char (point-min))
	        ;;(redisplay)
                ))))

(add-hook
   'emacs-startup-hook
   (lambda ()
     (setq initial-buffer-choice
	   (lambda ()
	     (get-buffer dashboard-buffer-name)))))

(add-to-list 'recentf-exclude "\\.emacs\\.d/elpa")
(add-to-list 'recentf-exclude "\\.emacs\\.d/bookmarks")
(add-to-list 'recentf-exclude "\\.emacs\\.d/recentf")
(add-to-list 'recentf-exclude "\\.emacs\\.d/ido.last")
(add-to-list 'recentf-exclude "\\.emacs\\.d/\\.cache/treemacs-persist")

(run-at-time nil (* 5 60) 'recentf-save-list)

(provide 'settings-dashboard)
