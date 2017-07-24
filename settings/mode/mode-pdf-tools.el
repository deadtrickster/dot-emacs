(require 'pdf-tools)

(pdf-tools-install)
(add-hook 'pdf-tools-enabled-hook
	  (lambda ()
	    (setq display-line-numbers nil)))

(provide 'mode-pdf-tools)
