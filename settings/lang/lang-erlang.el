(setq erlang-mode-hook
      (function (lambda ()
                  (setq indent-tabs-mode nil)
		  (local-set-key (kbd "RET") 'newline-and-indent))))

(setq  erlang-indent-level 2)

(provide 'lang-erlang)
