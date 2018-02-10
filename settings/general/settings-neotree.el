;; stolen from https://github.com/hlissner/doom-emacs, MIT
(use-package neotree
  :commands (neotree-show
             neotree-hide
             neotree-toggle
             neotree-dir
             neotree-find
             neo-global--with-buffer
             neo-global--window-exists-p)
  :config
  (setq neo-create-file-auto-open nil
        neo-auto-indent-point nil
        neo-autorefresh t
        neo-mode-line-type 'none
        neo-window-width 25
        neo-show-updir-line nil
        neo-theme 'nerd ; fallback
        neo-banner-message nil
        neo-confirm-create-file #'off-p
        neo-confirm-create-directory #'off-p
        neo-show-hidden-files nil
        neo-keymap-style 'concise
        neo-hidden-regexp-list
        '(;; vcs folders
          "^\\.\\(git\\|hg\\|svn\\)$"
          ;; compiled files
          "\\.\\(pyc\\|o\\|elc\\|lock\\|css.map\\)$"
          ;; generated files, caches or local pkgs
          "^\\(node_modules\\|vendor\\|.\\(project\\|cask\\|yardoc\\|sass-cache\\)\\)$"
          ;; org-mode folders
          "^\\.\\(sync\\|export\\|attach\\)$"
          "~$"
          "^#.*#$"))

  (when (bound-and-true-p winner-mode)
    (push neo-buffer-name winner-boring-buffers)))


(defun neotree/toggle ()
  "Toggle the neotree window."
  (interactive)
  (let ((path buffer-file-name)
        (project-root (projectile-project-root)))
    (require 'neotree)
    (cond ((and (neo-global--window-exists-p)
                (get-buffer-window neo-buffer-name t))
           (neotree-find path project-root)
           (neotree-refresh))
          ((not (and (neo-global--window-exists-p)
                     (equal (file-truename (neo-global--with-buffer neo-buffer--start-node))
                            (file-truename project-root))))
           (neotree-dir project-root)
           (neotree-find path project-root))
          (t
           (neotree-find path project-root)))))

(setq projectile-switch-project-action 'neotree-projectile-action)

(provide 'settings-neotree)
