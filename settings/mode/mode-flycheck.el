(global-flycheck-mode)

(define-fringe-bitmap 'flycheck-fringe-bitmap-block
    (vector #b00000000
            #b00000000
            #b11111111
            #b11111111
            #b11111111
            #b11111111
            #b11111111
            #b11111111
            #b11111111
            #b11111111
            #b11111111
            #b11111111
            #b11111111
            #b11111111
            #b11111111
            #b00000000
            #b00000000))

(flycheck-define-error-level 'error
  :severity 100
  :compilation-level 2
  :overlay-category 'flycheck-error-overlay
  :fringe-bitmap 'flycheck-fringe-bitmap-block
  :fringe-face 'flycheck-fringe-error
  :error-list-face 'flycheck-error-list-error)

(flycheck-define-error-level 'warning
  :severity 10
  :compilation-level 1
  :overlay-category 'flycheck-warning-overlay
  :fringe-bitmap 'flycheck-fringe-bitmap-block
  :fringe-face 'flycheck-fringe-warning
  :error-list-face 'flycheck-error-list-warning)

(provide 'mode-flycheck)
