;; https://github.com/hlissner/emacs-doom-themes/blob/master/doom-themes-treemacs.el

;; (defgroup doom-treemacs nil
;;   "Options for doom's treemacs theme"
;;   :group 'doom-themes)

;; (defcustom doom-treemacs-enable-variable-pitch t
;;   "If non-nil, the labels for files, folders and projects are displayed with the
;; variable-pitch face."
;;   :type 'boolean
;;   :group 'doom-treemacs)

;; (defcustom doom-treemacs-line-spacing 1
;;   "Line-spacing for treemacs buffer."
;;   :type 'symbol
;;   :group 'doom-treemacs)

;; (defcustom doom-treemacs-use-generic-icons t
;;   "Use the generic icons for items displayed in the treemacs buffer."
;;   :type 'boolean
;;   :group 'doom-treemacs)

;; (defun doom--treemacs-no-fringes ()
;;   "Remove fringes in treemacs. They get reset each time you select the neotree
;; pane and are highlighted incorrectly when used with `solaire-mode'."
;;   (when (display-graphic-p)
;;     (set-window-fringes nil 0 0)))

;; (defun doom--treemacs-setup (&rest _)
;;   (setq line-spacing doom-treemacs-line-spacing
;;         tab-width 1))

;; (defun doom--treemacs-variable-pitch-labels (&rest _)
;;   (when doom-treemacs-enable-variable-pitch
;;     (dolist (face '(treemacs-root-face
;;                     treemacs-git-unmodified-face
;;                     treemacs-git-modified-face
;;                     treemacs-git-renamed-face
;;                     treemacs-git-ignored-face
;;                     treemacs-git-untracked-face
;;                     treemacs-git-added-face
;;                     treemacs-git-conflict-face
;;                     treemacs-directory-face
;;                     treemacs-directory-collapsed-face
;;                     treemacs-file-face))
;;       (let ((faces (face-attribute face :inherit nil)))
;;         (set-face-attribute
;;          face nil :inherit
;;          `(variable-pitch ,@(delq 'unspecified (if (listp faces) faces (list faces)))))))))

;; (defvar all-the-icons-default-adjust)
;; (eval-after-load 'treemacs
;;   (lambda ()
;;     (unless (require 'all-the-icons nil t)
;;       (error "all-the-icons isn't installed"))
    
;;     (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action)

;;     (add-hook 'treemacs-mode-hook #'doom--treemacs-setup)

;;     (treemacs-git-mode 'extended)

;;     ;; no fringes in treemacs window
;;     (add-hook 'treemacs-mode-hook #'doom--treemacs-no-fringes)
;;     (advice-add #'treemacs-select-window :after #'doom--treemacs-no-fringes)

;;     ;; variable-pitch labels for files/folders
;;     (doom--treemacs-variable-pitch-labels)
;;     (advice-add #'load-theme :after #'doom--treemacs-variable-pitch-labels)

;;     ;; minimalistic atom-inspired icon theme
;;     (when doom-treemacs-use-generic-icons
;;       ;; Silence plistp error with all-the-icons
;;       (advice-add #'treemacs--pulse-png-advice :override #'ignore)

;;       (let ((all-the-icons-default-adjust 0))
;;         (setq treemacs-icon-root-png
;;               (concat " " (all-the-icons-octicon "repo" :v-adjust -0.1 :height 1.6
;;                                                  :face 'font-lock-string-face)
;;                       " ")

;;               treemacs-icon-tag-open-png
;;               (all-the-icons-octicon "chevron-down" :v-adjust 0.1)
;;               treemacs-icon-tag-closed-png
;;               (all-the-icons-octicon "chevron-right" :v-adjust 0.1)

;;               treemacs-indentation-string "  "
;;               treemacs-indentation 1

;;               treemacs-icon-open-png
;;               (concat (all-the-icons-octicon "file-directory" :v-adjust 0)
;;                       " ")
;;               treemacs-icon-closed-png
;;               (concat (all-the-icons-octicon "file-directory" :v-adjust 0 :face 'font-lock-doc-face)
;;                       " ")

;;               treemacs-icon-tag-node-open-png
;;               (concat (all-the-icons-octicon "chevron-down"  :height 0.75 :face 'font-lock-keyword-face)
;;                       "\t")
;;               treemacs-icon-tag-node-closed-png
;;               (concat (all-the-icons-octicon "chevron-right" :height 0.9  :face 'font-lock-keyword-face)
;;                       "\t")
;;               treemacs-icon-tag-leaf-png "- ")

;;         ;; File type icons
;;         (setq treemacs-icons-hash (make-hash-table :size 200 :test #'equal)
;;               treemacs-icon-fallback (concat (all-the-icons-octicon "file-code" :v-adjust 0) " ")
;;               treemacs-icon-text     treemacs-icon-fallback)

;;         (treemacs-define-custom-icon (all-the-icons-octicon "file-media")
;;                                      "png" "jpg" "jpeg" "gif" "ico" "tif" "tiff" "svg" "bmp"
;;                                      "psd" "ai" "eps" "indd" "mov" "avi" "mp4" "webm" "mkv"
;;                                      "wav" "mp3" "ogg" "midi")

;;         (treemacs-define-custom-icon (all-the-icons-octicon "file-text")
;;                                      "md" "markdown" "rst" "log" "org" "txt"
;;                                      "CONTRIBUTE" "LICENSE" "README" "CHANGELOG")

;;         (treemacs-define-custom-icon (all-the-icons-octicon "file-code")
;;                                      "yaml" "yml" "json" "xml" "toml" "cson" "ini"
;;                                      "tpl" "erb" "mustache" "twig" "ejs" "mk" "haml" "pug" "jade" "erl" "ex" "exs")))))


(require 'treemacs)


 '(treemacs-collapse-dirs 3)

 '(treemacs-directory-collapsed-face ((t (:inherit (variable-pitch default)))))
 '(treemacs-directory-face ((t (:inherit (variable-pitch default)))))
 '(treemacs-file-face ((t (:inherit variable-pitch :foreground "#8a8c99"))))
 '(treemacs-fringe-indicator-face ((t (:foreground "#181a26"))))
 '(treemacs-root-face ((t (:foreground "#739FCF" :weight bold))))

;; (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action)

(treemacs-git-mode 'extended)
(provide 'settings-treemacs)
;;; doom-themes-treemacs.el ends here
