(setq
 make-backup-files nil
 backup-by-copying t      ; don't clobber symlinks
 backup-directory-alist
 `(("." . ,temporary-file-directory))    ; don't litter my fs tree
 auto-save-file-name-transforms
  `((".*" ,temporary-file-directory t))
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)       ; use versioned backups



(provide 'settings-backups)
