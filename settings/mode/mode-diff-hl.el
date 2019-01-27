
(require 'diff-hl)

(require 'diff-hl-flydiff)

(defun enable-diff-hl-mode ()
  (diff-hl-mode)
  (diff-hl-flydiff-mode))

(add-hook 'text-mode-hook 'enable-diff-hl-mode)
(add-hook 'prog-mode-hook 'enable-diff-hl-mode)

(require 'pos-tip)

(global-set-key (kbd "<left-fringe> <mouse-1>")
                (lambda (ev)
                  (interactive "e")
                  (let* ((pos (posn-point (event-start ev)))
                         (overlay (car (overlays-at pos))))
                    (when overlay
                      (let* ((diff-type (overlay-get overlay 'diff-type))
                             (diff-content (overlay-get overlay 'diff-content)))
                        (when (and diff-content
                                   (or (eq diff-type 'change)
                                       (eq diff-type 'delete)))
                          (let ((lines (split-string diff-content "[\n\r]+" )))
                            (pos-tip-show-no-propertize
                             (mapconcat (lambda (line)
                                          (if (> (length line) 1)
                                              (cond
                                               ((= (aref line 0) ?+) (propertize (concat line "\n") 'face 'diff-added))
                                               ((= (aref line 0) ?-) (propertize  (concat line "\n") 'face 'diff-removed))))) (seq-drop lines 1) "")
                             'diff-added pos))))))))

(global-set-key (kbd "<left-fringe> <mouse-3>")
                (lambda (ev)
                  (interactive "e")
                  (let* ((pos (posn-point (event-start ev)))
                         (overlay (car (overlays-at pos))))
                    (when overlay
                      (let* ((diff-type (overlay-get overlay 'diff-type))
                             (diff-content (overlay-get overlay 'diff-content)))
                        (when (and diff-content
                                   (or (eq diff-type 'change)
                                       (eq diff-type 'delete)))
                          (let ((use-dialog-box nil)) (diff-hl-revert-hunk ))))))))

(provide 'mode-diff-hl)
