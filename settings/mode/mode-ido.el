(require 'ido)

(ido-mode t)
(ido-everywhere 1)

(defvar ido-directory-too-big nil)

;; (defun ido-name (item)
;;   ;; Return file name for current item, whether in a normal list
;;   ;; or a merged work directory list.
;;   (concat (if (consp item) (car item) item)))

(global-set-key
 "\M-x"
 (lambda ()
   (interactive)
   (call-interactively
    (intern
     (ido-completing-read
      "M-x " 
      (all-completions "" obarray 'commandp))))))

(defadvice ido-find-file (after find-file-sudo activate)
  "Find file as root if necessary."
  (when (and buffer-file-name
             (file-exists-p buffer-file-name)
             (not (file-writable-p buffer-file-name)))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defvar ido-dont-ignore-buffer-names '("*scratch*" "*dashboard*" "*Messages*"))

(defun ido-ignore-most-star-buffers (name)
  (and
   (string-match-p "^\\*.*\\*" name)
   (not (member name ido-dont-ignore-buffer-names))))

(setq ido-ignore-buffers (list "\\^ .*"  #'ido-ignore-most-star-buffers))


;; (add-hook 'find-file-hook
;;        (lambda ()
;;          "Find file as root if necessary."
;;          (unless (and buffer-file-name
;;                       (file-writable-p buffer-file-name))
;;            (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name)))))
;;
 (rx (or (and "\*" (*? anything) "*/") (and "//" (*? anything) eol)))

(provide 'mode-ido)

;;; mode-ido ends here
