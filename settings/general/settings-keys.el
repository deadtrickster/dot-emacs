
(require 'windmove)

(global-set-key (kbd "C-z") 'undo)
(global-set-key "\C-cc" 'comment-or-uncomment-region)
(global-set-key "\C-cd" 'delete-window)
(global-set-key [S-right] 'windmove-right)
(global-set-key [S-down] 'windmove-down)
(global-set-key [S-left] 'windmove-left)
(global-set-key [S-up] 'windmove-up)

(defun swap-buffer-window (direction)
  "Put the buffer from the selected window in next window, and vice versa"
  (interactive)
  (let* ((this (selected-window))
         (other (windmove-find-other-window direction nil this))
         (this-buffer (window-buffer this))
         (that-buffer (window-buffer other)))
    (set-window-buffer other this-buffer)
    (set-window-buffer this that-buffer)
    ;;(tabbar-close-tab) ;;close current tab
    (select-window other) ;;swap cursor to new buffer
    ))
(global-set-key (kbd "<C-S-left>") (lambda () (interactive)
                                     (swap-buffer-window 'left)))
(global-set-key (kbd "<C-S-right>") (lambda () (interactive)
                                      (swap-buffer-window 'right)))
(global-set-key (kbd "<C-S-up>") (lambda () (interactive)
                                   (swap-buffer-window 'up)))
(global-set-key (kbd "<C-S-down>") (lambda () (interactive)
                                     (swap-buffer-window 'down)))
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
(global-set-key [f11] 'delete-trailing-whitespace)
(global-set-key [C-tab] 'company-complete)

(defun swiper-with-selection ()
  (interactive)
  (if (and transient-mark-mode mark-active (not (eq (mark) (point))))
      (let ((selection (buffer-substring-no-properties (mark) (point))))
        (deactivate-mark)
        (swiper selection))
    (swiper)))

(global-set-key "\C-s" 'swiper-with-selection)

(defun insert-newline-before-line ()
  (interactive)
  (let ((current-line
         (line-number-at-pos (point))))
    (if (eql current-line 1)
        (progn
          (beginning-of-line)
          (newline-and-indent)
          (goto-line 1)
          (indent-according-to-mode))
      (progn
        (goto-line (1- current-line))
        (end-of-line)
        (newline-and-indent)))))
(global-set-key [C-return] 'insert-newline-before-line)


(global-set-key (kbd "C-x v p") 'git-messenger:popup-message)

(defun delete-current-line ()
  "Delete (not kill) the current line."
  (interactive)
  (save-excursion
    (delete-region
     (progn (forward-visible-line 0) (point))
     (progn (forward-visible-line 1) (point))))
  (insert-newline-before-line))

(global-set-key (kbd "C-d") 'delete-current-line)

(provide 'settings-keys)
