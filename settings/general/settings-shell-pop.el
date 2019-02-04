 (use-package shell-pop
  :bind (("C-t" . shell-pop))
  :config
  (setq shell-pop-shell-type (quote ("term-term" "*ansi-term*" (lambda nil (ansi-term shell-pop-term-shell)))))
  (setq shell-pop-term-shell "/bin/bash")
  ;; need to do this manually or not picked up by `shell-pop'
  (setq shell-pop-universal-key "C-t")
;  (shell-pop--set-shell-type 'shell-pop-shell-type shell-pop-shell-type)
  )

(provide 'settings-shell-pop)
