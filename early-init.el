;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;; Register MELPA before Emacs activates packages.  package-initialize itself
;; runs automatically after this file, so calling it here is unnecessary.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
