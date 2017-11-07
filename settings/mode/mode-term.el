
(add-hook 'term-mode-hook
	  (lambda ()
	    (setf truncate-lines nil)))

(provide 'mode-term)
