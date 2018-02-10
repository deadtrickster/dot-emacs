(defun find-user-init-file ()
  "Edit the `user-init-file', in another window.
http://emacsredux.com/blog/2013/05/18/instant-access-to-init-dot-el/"
  (interactive)
  (find-file-other-window user-init-file))

(require 'settings-reloading)
(require 'settings-editing)
(require 'settings-ansi-color)
(require 'settings-dashboard)
(require 'settings-delight)
(require 'settings-neotree)

(provide 'settings-general)
