(eval-after-load 'flycheck
  '(flycheck-credo-setup))

(require 'settings-packages)
(require 'settings-ui)
(require 'settings-modes)
(require 'settings-backups)
(require 'settings-indent)
(require 'settings-keys)
(require 'settings-yatemplate)

(require 'settings-langs)

(require 'settings-reloading)
(require 'settings-editing)
(require 'settings-ansi-color)
(provide 'settings)
