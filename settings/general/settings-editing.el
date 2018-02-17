
(delete-selection-mode 1)

(defun my-turn-off-some-parens ()
  "Turn on brackets and braces as paren characters."
  (interactive)
  (modify-syntax-entry ?\[ "(")
  (modify-syntax-entry ?\] ")")
  (modify-syntax-entry ?\{ "(")
  (modify-syntax-entry ?\} ")"))
(add-hook 'lisp-mode-hook 'my-turn-off-some-parens)
(add-hook 'common-lisp-mode-hook 'my-turn-off-some-parens)

(add-hook 'after-make-frame-functions
          (lambda (frame)
            (with-selected-frame frame
              (keyboard-translate ?\( ?\[)
              (keyboard-translate ?\[ ?\()
              (keyboard-translate ?\) ?\])
              (keyboard-translate ?\] ?\)))))

(keyboard-translate ?\( ?\[)
(keyboard-translate ?\[ ?\()
(keyboard-translate ?\) ?\])
(keyboard-translate ?\] ?\))

(defun rename-file-and-buffer ()
  "Rename the current buffer and file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer is not visiting a file!")
      (let ((new-name (read-file-name "New name: " filename)))
        (cond
         ((vc-backend filename) (vc-rename-file filename new-name))
         (t
          (rename-file filename new-name t)
          (set-visited-file-name new-name t t)))))))

(setq default-input-method "cyrillic-jcuken")

(provide 'settings-editing)
