(require 'json-mode)

(add-hook 'json-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

(with-eval-after-load 'json-mode
  (bind-key [f12] 'json-pretty-print-buffer json-mode-map))

(provide 'mode-json)
