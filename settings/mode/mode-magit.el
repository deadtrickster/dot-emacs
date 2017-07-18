

(defun magit-turn-on-auto-revert-mode-if-desired (&optional file)
  (if file
      (--when-let (find-buffer-visiting file)
        (with-current-buffer it
          (magit-turn-on-auto-revert-mode-if-desired)))
    (when (and buffer-file-name
               (file-readable-p buffer-file-name)
               (magit-toplevel)
               (or (not magit-auto-revert-tracked-only)
                   (magit-file-tracked-p buffer-file-name)))
      (unless (or auto-revert-mode global-auto-revert-mode)
        (auto-revert-mode)))))

(provide 'mode-magit)
