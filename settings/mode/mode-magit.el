
(require 'use-package)

(require 'magit)


(use-package magit
  :init
  (add-hook 'magit-mode-hook
	    (lambda ()
	      (defun magit-turn-on-auto-revert-mode-if-desired (&optional file)
	        (if file
		    (--when-let (find-buffer-visiting file)
		      (with-current-buffer it
		        (magit-turn-on-auto-revert-mode-if-desired)))
		  (when (and buffer-file-name
			     (file-readable-p buffer-file-name)
			     (magit-toplevel)
			     (or (not magit-auto-revert-tracked-only)
				 (magit-file-tracked-p buffer-file-name)))
		    (unless (or auto-revert-mode global-auto-revert-mode)
		      (auto-revert-mode)))))))
  ;:config
  ;(define-key magit-file-mode-map (kbd "<f10>") 'magit-diff-master)
  )



  (defun magit-diff-master ()
    (interactive)
    (magit-diff-range "master.." nil (list (buffer-file-name (current-buffer)))))

(provide 'mode-magit)
