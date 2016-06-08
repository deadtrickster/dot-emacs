;;; ui --- Generic ui stuff: theming, scrolling, etc

;;; Commentary:

;;; Code:

(load-theme 'deeper-blue)

(require 'smooth-scroll)
(setf smooth-scroll-mode t)
(powerline-default-theme)

(provide 'settings-ui)

;;; settings-ui.el ends here
