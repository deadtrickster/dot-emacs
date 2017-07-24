(require 'dashboard)

(setq dashboard-items '((recents  . 20)))

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

(add-hook 'dashboard-mode-hook
		      (lambda ()
			(setf display-line-numbers nil)))

(add-hook 'after-make-frame-functions
	  (lambda (_)
	    (dashboard-refresh-buffer)))

(add-hook
   'emacs-startup-hook
   (lambda ()
     (setq initial-buffer-choice
	   (lambda ()
	     (get-buffer dashboard-buffer-name)))))

(provide 'setting-dashboard)
