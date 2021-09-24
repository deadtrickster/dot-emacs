(require 'json-mode)

(require 'bind-key)

(add-hook 'json-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

(eval-after-load 'json-mode
  '(progn
     (bind-key [f12] 'json-pretty-print-buffer json-mode-map)))

(provide 'mode-json)
