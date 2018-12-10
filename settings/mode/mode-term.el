
(require 'term)

(add-hook 'term-mode-hook
	  (lambda ()
	    (setf truncate-lines nil)))


(define-key term-mode-map [C-left] 'previous-buffer)
(define-key term-mode-map [C-right] 'next-buffer)
(define-key term-raw-map [C-left] 'previous-buffer)
(define-key term-raw-map [C-right] 'next-buffer)
(define-key term-mode-map [M-x] (lookup-key (current-global-map) [M-x]))
(define-key term-raw-map [M-x] (lookup-key (current-global-map) [M-x]))
(define-key term-mode-map [C-y] 'yank)
(define-key term-raw-map [C-y] 'yank)
(define-key term-mode-map [C-w] (lookup-key (current-global-map) [C-w]))
(define-key term-raw-map [C-w] (lookup-key (current-global-map) [C-w]))

(provide 'mode-term)
