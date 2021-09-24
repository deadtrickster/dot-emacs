;;; https://www.reddit.com/r/emacs/comments/a8l741/message_in_minibuffer_overwrites_prompt/
(define-advice message (:around (f &rest args) dont-disturb-in-mini)
  (let ((inhibit-message (or inhibit-message
                             (> (minibuffer-depth) 0))))
    (apply f args)))

(define-advice print (:around (f &rest args) dont-disturb-in-mini)
  (unless (or inhibit-message
              (> (minibuffer-depth) 0))
    (apply f args)))

(require 'cl-extra)

(defcustom message-filter-regexp-list '("^Starting new Ispell process \\[.+\\] \\.\\.\\.$"
                                        "^Ispell process killed$"
                                        "^Wrote ")
  "filter formatted message string to remove noisy messages"
  :type '(list string)
  :group 'general)

(defadvice message (around message-filter-by-regexp activate)
  (if (not (ad-get-arg 0))
      ad-do-it
    (let ((formatted-string (apply 'format (ad-get-args 0))))
      (if (and (stringp formatted-string)
               (cl-some (lambda (re) (string-match re formatted-string)) message-filter-regexp-list))
          (let ((inhibit-read-only t))
            (with-current-buffer "*Messages*"
              (goto-char (point-max))
              (insert formatted-string "\n")))
        (progn
          (ad-set-args 0 `("%s" ,formatted-string))
          ad-do-it)))))

(defadvice print (around print-filter-by-regexp activate)
  (let ((string (ad-get-args 0)))
    (if (and (stringp string)
             (cl-some (lambda (re) (string-match re string)) message-filter-regexp-list))
        (let ((inhibit-read-only t))
          (with-current-buffer "*Messages*"
            (goto-char (point-max))
            (insert string "\n")))
      (progn
        ad-do-it))))

(setf save-silently t)

(provide 'settings-messages)
