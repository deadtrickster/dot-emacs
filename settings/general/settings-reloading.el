;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.

(global-auto-revert-mode t)
;;   (defun my-auto-revert (&optional ignore-auto noconfirm)
;;     (interactive)
;;     (if (buffer-modified-p)
;; 	(setq header-line-format
;;             (format "%s."
;;                     (propertize "This file has changed on disk"
;;                                 'face '(:foreground "#f00"))))
;;       (let ((revert-buffer-function nil))
;; 	(revert-buffer ignore-auto noconfirm))))
;; (setq revert-buffer-function 'my-auto-revert)

;; (defun my-buffer-stale-function (&optional _noconfirm)
;;   "Default function to use for `buffer-stale-function'.
;; This function ignores its argument.
;; This returns non-nil if the current buffer is visiting a readable file
;; whose modification time does not match that of the buffer.

;; This function only handles buffers that are visiting files.
;; Non-file buffers need a custom function"
;;   (and buffer-file-name
;;        (file-readable-p buffer-file-name)
;;        (not (buffer-modified-p (current-buffer)))
;;        (not (verify-visited-file-modtime (current-buffer)))))


;; (setq buffer-stale-function 'my-buffer-stale-function)

;; Ignore modification-time-only changes in files, i.e. ones that
;; don't really change the contents.  This happens often with
;; switching between different VC buffers.

(defun update-buffer-modtime-if-byte-identical ()
  (let* ((size      (buffer-size))
         (byte-size (position-bytes size))
         (filename  buffer-file-name))
    (when (and byte-size (<= size 1000000))
      (let* ((attributes (file-attributes filename))
             (file-size  (nth 7 attributes)))
        (when (and file-size
                   (= file-size byte-size)
                   (string= (buffer-substring-no-properties 1 (1+ size))
                            (with-temp-buffer
                              (insert-file-contents filename)
                              (buffer-string))))
          (set-visited-file-modtime (nth 5 attributes))
          t)))))

(defun verify-visited-file-modtime--ignore-byte-identical (original &optional buffer)
  (or (funcall original buffer)
      (with-current-buffer buffer
        (update-buffer-modtime-if-byte-identical))))
(advice-add 'verify-visited-file-modtime :around #'verify-visited-file-modtime--ignore-byte-identical)

(defun ask-user-about-supersession-threat--ignore-byte-identical (original &rest arguments)
  (unless (update-buffer-modtime-if-byte-identical)
    (apply original arguments)))
(advice-add 'ask-user-about-supersession-threat :around #'ask-user-about-supersession-threat--ignore-byte-identical)

(provide 'settings-reloading)
