;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;; Runs before the GUI is initialized and before Emacs activates packages, so
;; this file is the ONLY place a few of these can be set at all.  Keep it small:
;; anything that could live in init.el as a `use-package' block belongs there.

;; Register MELPA before Emacs activates packages.  package-initialize itself
;; runs automatically after this file, so calling it here is unnecessary.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; GC: give the whole startup one huge nursery.  gcmh (see init.el) manages the
;; threshold beautifully, but only from `after-init-hook' onward -- so without
;; this, the expensive part (loading ~19 heavy packages) runs at the stock 800k
;; threshold and collects dozens of times on the way.  Measured on this Emacs,
;; warm cache: 0.23-0.29s -> 0.19s.
;;
;; Caveat for future-you: if this Emacs is ever rebuilt --with-mps (igc, the
;; incremental collector), `gc-cons-threshold' becomes meaningless and gcmh turns
;; into dead weight -- drop both.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 1.0)

;; Fail-safe.  Leaving the threshold at infinity for the whole session is how a
;; config ends up with multi-second stalls and a gigabyte of heap, so if gcmh ever
;; fails to load we must not be left in that state.
;;
;; most-positive-fixnum works as the "nobody took over" sentinel precisely because
;; gcmh does not use it: its `gcmh-high-cons-threshold' is #x40000000 (1GB).  So a
;; threshold still equal to most-positive-fixnum here means gcmh genuinely never
;; ran, and we are not stomping on a live gcmh.
(add-hook 'emacs-startup-hook
          (lambda ()
            (when (= (default-value 'gc-cons-threshold) most-positive-fixnum)
              (setq-default gc-cons-threshold (* 16 1024 1024)
                            gc-cons-percentage 0.1)))
          101)

;; Must precede the load of use-package, so it cannot live in init.el: teaches
;; every `use-package' block to register itself with imenu.  `consult-imenu' then
;; gives a jump-to-package index over all ~74 blocks -- which is the real answer
;; to "init.el is one 2200-line file".
(setq use-package-enable-imenu-support t)

;; auto-mode-alist is matched case-sensitively first, then a second time
;; case-insensitively -- a DOS-era fallback (FOO.C) that just doubles the work on
;; every file visit.
(setq auto-mode-case-fold nil)

;; Don't let font / menu-bar / tool-bar changes during startup each trigger a
;; resize round-trip with the window manager.
(setq frame-inhibit-implied-resize t)

;; Emacs 31+: cache each load-path directory's file list instead of stat-ing the
;; whole path on every `load'.  Guarded -- it does not exist in older Emacsen.
(when (boundp 'load-path-filter-function)
  (setq load-path-filter-function #'load-path-filter-cache-directory-files))
