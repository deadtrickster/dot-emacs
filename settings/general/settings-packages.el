(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(let ((packages-fetched))
  (dolist (package package-selected-packages)
    (unless (package-installed-p package)
      (unless packages-fetched
	(package-refresh-contents)
	(setf packages-fetched t))
      (package-install package))))

(provide 'settings-packages)
