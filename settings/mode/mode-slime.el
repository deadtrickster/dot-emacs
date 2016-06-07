
(load (expand-file-name "~/quicklisp/slime-helper.el"))

(add-hook 'slime-mode-hook
          (lambda ()
            (unless (slime-connected-p)
              (save-excursion (slime)))))
(setq inferior-lisp-program "sbcl --control-stack-size 2048 --dynamic-space-size 2048")
(require 'slime)
;;(require 'slime-repl-ansi-color)
(slime-setup '(slime-fancy
               slime-indentation
               slime-repl ;;slime-repl-ansi-color
	       ))

(require 'ac-slime)
(add-hook 'slime-mode-hook 'set-up-slime-ac)
(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)
(eval-after-load "auto-complete"
  '(add-to-list 'ac-modes 'slime-repl-mode))

(provide 'mode-slime)
