(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(setf package-selected-packages
      '(iedit alchemist web-mode rainbow-mode erlang ac-slime js2-refactor js2-mode paredit paren-face auto-complete go-autocomplete go-eldoc yasnippet flycheck go-mode highlight-numbers hl-todo))

(let ((packages-fetched))
  (dolist (package package-selected-packages)
    (unless (package-installed-p package)
      (unless packages-fetched
	(package-refresh-contents)
	(setf packages-fetched t))
      (package-install package))))

(package-initialize)

(provide 'settings-packages)
