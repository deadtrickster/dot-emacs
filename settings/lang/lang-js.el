(require 'js2-refactor)
(add-hook 'js2-mode-hook #'js2-refactor-mode)
(add-hook 'js2-mode-hook 'ac-js2-mode)
(setq js-indent-level 2)

(define-key js2-mode-map [(mouse-1)] #'mouse-set-point)

(provide 'lang-js)
