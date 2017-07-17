(defun my-erlang-mode-hook ()
  "Hooks for Web mode."
  (erlang-font-lock-level-4))

(add-hook 'erlang-mode-hook 'my-erlang-mode-hook)

(provide 'mode-erlang)
