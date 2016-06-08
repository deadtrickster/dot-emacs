 
(define-common-lisp-style "my-indent-style"
  "My custom indent style."
  (:inherit "sbcl")
  (:variables
    (lisp-loop-indent-subclauses t))
  (:indentation
    (with-gensyms ((&whole 4 &rest 1) &body))
    (once-only (as with-gensyms))))

(setq common-lisp-style-default "my-indent-style")

(provide 'lang-cl)
