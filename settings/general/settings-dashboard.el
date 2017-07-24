(require 'dashboard)
(setq dashboard-items '((recents  . 10)
			(projects . 10)))

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
