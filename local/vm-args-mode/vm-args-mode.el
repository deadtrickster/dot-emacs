(defalias 'vm-args-parent-mode
  'prog-mode)

(defvar vm-args-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?# "<" table)
    (modify-syntax-entry ?\n ">" table)
    (modify-syntax-entry ?' "\"" table)
    (modify-syntax-entry ?= "." table)
    table)
  "Syntax table for `vm-args-mode'.")

(defface vm-args-font-lock-flags-face
  '((default (:inherit font-lock-keyword-face)))
  "Face used for highlighting flags."
  :group 'vm-args)

(defvar vm-args-font-lock-flags-face
  'vm-args-font-lock-flags-face)

(defvar vm-args-font-lock
  `(,(cons "\\(\\(-\\|\\+\\)\\w*\\)"
           vm-args-font-lock-flags-face))
  "Default font-lock-keywords for `vm-args mode'.")

(setf vm-args-font-lock
  `(,(cons "\\(\\(-\\|\\+\\)\\(\\w\\|_\\)*\\)"
           vm-args-font-lock-flags-face)

    ,(cons (eval-when-compile
             (regexp-opt '("true"
                           "false")
                         'words))
           font-lock-constant-face)))

(define-abbrev-table 'vm-args-mode-abbrev-table nil
  "Abbrev table used while in `vm-args-mode'.")

;;;###autoload
(define-derived-mode vm-args-mode vm-args-parent-mode "vm.args"
  "A major mode to edit BEAM vm.args file.
\\{vm-args-mode-map}
"
  (setq local-abbrev-table (or vm-args-mode-abbrev-table
                               (define-abbrev-table 'vm-args-mode-abbrev-table ())))
  (set-syntax-table vm-args-mode-syntax-table)
  (set (make-local-variable 'require-final-newline) mode-require-final-newline)
  (set (make-local-variable 'comment-start) "#")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'comment-start-skip) "#+ *")
  (set (make-local-variable 'parse-sexp-ignore-comments) t)
  (set (make-local-variable 'font-lock-defaults) '(vm-args-font-lock nil t)))

;;;###autoload
(add-to-list 'auto-mode-alist '("vm.args" . vm-args-mode))

(provide 'vm-args-mode)
