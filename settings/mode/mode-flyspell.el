

(setf flyspell-auto-correct-binding "c")
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)
;; More
(provide 'mode-flyspell)
