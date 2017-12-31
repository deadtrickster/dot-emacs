(global-set-key (kbd "C-z") 'undo)
(global-set-key "\C-cc" 'comment-or-uncomment-region)
(global-set-key "\C-cd" 'delete-window)
(global-set-key [S-right] 'windmove-right)
(global-set-key [S-down] 'windmove-down)
(global-set-key [S-left] 'windmove-left)
(global-set-key [S-up] 'windmove-up)
(global-set-key [next]
                (lambda () (interactive)
                  (condition-case nil (scroll-up)
                    (end-of-buffer (goto-char (point-max))))))
(global-set-key [prior]
                (lambda () (interactive)
                  (condition-case nil (scroll-down)
                    (beginning-of-buffer (goto-char (point-min))))))

(global-set-key "\C-b" (lambda ()
                         (interactive)
                         (switch-to-buffer "*Ibuffer*")))

(global-set-key [C-left] 'previous-buffer)
(global-set-key [C-right] 'next-buffer)


(define-key global-map [(insert)] nil)
(define-key global-map [(control insert)] 'overwrite-mode)

(global-set-key [f12] 'indent-whole-buffer)
(global-set-key [C-tab] 'company-complete)

(defun insert-newline-before-line ()
  (interactive)
  (let ((current-line
         (line-number-at-pos (point))))
    (if (eql current-line 1)
        (progn
          (beginning-of-line )1
          (newline-and-indent)
          (goto-line 1)
          (indent-according-to-mode))
      (progn
        (goto-line (1- current-line))
        (end-of-line)
        (newline-and-indent)))))
(global-set-key [C-return] 'insert-newline-before-line)


(global-set-key (kbd "C-x v p") 'git-messenger:popup-message)

(provide 'settings-keys)
