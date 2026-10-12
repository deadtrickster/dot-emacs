;;; letibot-gray-theme.el --- the Ghostty `LetibotGray' palette, as an Emacs theme -*- lexical-binding: t; -*-

;; The GUI frame and the terminal it sits next to should be the same surface, so
;; this theme is not a colour scheme anyone invented for Emacs: it is the palette
;; Ghostty already resolves for this machine, with every face written as a SLOT
;; reference rather than a hex literal.
;;
;;   $ ghostty +show-config | grep -E 'theme|background|palette'
;;   theme = LetibotGray
;;   background = #23282c      foreground = #d3d7d9
;;   palette = 0=#2f363b  1=#e0726e  2=#a8d26a  3=#e0b040
;;             4=#5aa7ff  5=#b896c8  6=#6fbcbf  7=#c4c9cc
;;             8=#7d868b  9=#f08f8a 10=#9be6b0 11=#e8c890
;;            12=#7cc4ff 13=#d4b0e4 14=#a6eef2 15=#eef1f2
;;   selection-background = #34424e   selection-foreground = #eef1f2
;;
;; Read those values off the TOOL, never off a screenshot: a screenshot gives you
;; anti-aliased text over a background, i.e. a range of near-colours, while the
;; config gives the exact 18 values the terminal itself uses.
;;
;; The mapping principle is rano's, which is the same program's other half: in
;; rano "(t)heme" is a table of ROLES overridden by name, and by default those
;; roles live "in the terminal's own sixteen slots, so the terminal's theme is the
;; theme".  Hence, here:
;;
;;   * a role that the terminal has a slot for uses THAT SLOT -- comments are slot
;;     8 (`faint'), strings/added are slot 2, constants are slot 3, functions are
;;     slot 4, types are slot 6, keywords are slot 5 -- so `M-x list-colors-display'
;;     in Emacs and the colours `ls --color' prints in Ghostty cannot drift apart;
;;   * surfaces the terminal has no slot for are DERIVED from the palette rather
;;     than picked: a raised surface is slot 0 over the background (the same value
;;     rano's example uses for `user_block = "bg:#2f363b"'), and the diff tints are
;;     the background nudged 12% toward the relevant slot (25% for the refine
;;     faces) -- comment says which, so any of them can be recomputed;
;;   * the cursor, the region and the modeline take Ghostty's selection colours.
;;
;; The families and sizes are NOT here: the `default' face keeps the config's own
;; `:height 95' (9.5pt, the Linux size) and init.el raises it on darwin, where
;; Ghostty is Hack at 13pt -- see the darwin block next to the faces it adjusts.

(deftheme letibot-gray
  "Ghostty's `LetibotGray' terminal palette, used as an Emacs theme.")

(let ((bg       "#23282c")   ; -- background
      (fg       "#d3d7d9")   ; -- foreground
      (sel-bg   "#34424e")   ; -- selection-background
      (sel-fg   "#eef1f2")   ; -- selection-foreground
      ;; palette 0-15, in slot order; the names are the roles, not the colours.
      (raised   "#2f363b")   ; 0  black   -- also the raised surface (rano's user_block)
      (red      "#e0726e")   ; 1
      (green    "#a8d26a")   ; 2
      (yellow   "#e0b040")   ; 3
      (blue     "#5aa7ff")   ; 4
      (magenta  "#b896c8")   ; 5
      (cyan     "#6fbcbf")   ; 6
      (white    "#c4c9cc")   ; 7
      (faint    "#7d868b")   ; 8  bright black -- comments, line numbers, punctuation
      (hi-red   "#f08f8a")   ; 9
      (hi-green "#9be6b0")   ; 10
      (hi-yellow "#e8c890")  ; 11
      (hi-blue  "#7cc4ff")   ; 12
      (hi-magenta "#d4b0e4") ; 13
      (hi-cyan  "#a6eef2")   ; 14
      (bright   "#eef1f2")   ; 15
      ;; derived: the background nudged toward a slot (see the header)
      (dim-bg   "#24292d")   ; bg + 10% of slot 0 -- the inactive modeline
      (warn-tint "#3f3336")  ; bg + 15% of slot 1
      (add-bg   "#333c33")   ; bg + 12% of slot 2
      (del-bg   "#3a3134")   ; bg + 12% of slot 1
      (chg-bg   "#3a382e")   ; bg + 12% of slot 3
      (add-bg2  "#44523b")   ; bg + 25% of slot 2 (refine)
      (del-bg2  "#523a3c")   ; bg + 25% of slot 1 (refine)
      (chg-bg2  "#524a31")   ; bg + 25% of slot 3 (refine)
      (hl-tint  "#484330"))  ; bg + 20% of slot 3 (a highlighted symbol)

  (custom-theme-set-faces
   'letibot-gray
   ;; --- the surface ---------------------------------------------------------
   ;; No `:foundry': "GOOG" was Roboto Mono's (a Google font).  Hack has none, and
   ;; naming one anyway only invites an inexact match.
   `(default ((t (:background ,bg :foreground ,fg
                              :family "Hack" :height 95
                              :width normal
                              :slant normal :weight regular))))
   `(cursor ((t (:background ,fg))))
   `(region ((t (:background ,sel-bg :foreground ,sel-fg))))
   `(secondary-selection ((t (:background ,raised))))
   `(hl-line ((t (:background ,raised))))          ; rano's raised surface
   `(highlight ((t (:underline (:color ,blue)))))
   `(fringe ((t (:background ,bg :foreground ,faint))))
   `(vertical-border ((t (:foreground ,raised))))
   `(window-divider ((t (:foreground ,raised))))
   `(window-divider-first-pixel ((t (:foreground ,raised))))
   `(window-divider-last-pixel ((t (:foreground ,raised))))
   `(shadow ((t (:foreground ,faint))))
   `(link ((t (:foreground ,blue :underline t))))
   `(link-visited ((t (:foreground ,magenta :underline t))))
   `(tooltip ((t (:inherit default :background ,raised :height 1.0))))
   ;; Lucid-toolkit scrollbar takes its colour from this face; unspecified, it
   ;; renders bright. Match the background, muted thumb (readable on KDE).
   `(scroll-bar ((t (:background ,bg :foreground ,sel-bg))))
   `(custom-button ((t (:background ,raised :foreground ,bright
                                    :box (:line-width (2 . 2) :style flat-button)))))
   `(custom-button-mouse ((t (:background ,sel-bg :foreground ,bright
                                         :box (:line-width (2 . 2) :style flat-button)))))
   `(widget-field ((t (:background ,raised :foreground ,fg
                                   :box (:line-width (1 . 3) :color ,faint
                                         :style flat-button) :weight bold :height 1.0))))
   ;; The terminal's own prompt marker is the palette's GREEN -- the TUI draws
   ;; `›' in it -- so the Emacs prompt is that slot rather than a blue the
   ;; terminal only uses for other things.
   `(minibuffer-prompt ((t (:foreground ,green :weight bold))))
   `(trailing-whitespace ((t (:background ,warn-tint))))
   `(escape-glyph ((t (:foreground ,faint))))
   `(nobreak-space ((t (:foreground ,faint :underline t))))

   ;; --- mode line -----------------------------------------------------------
   ;; Ghostty's slot 0 as the bar, the way the byobu status line sits on the
   ;; terminal: the frame's chrome is one surface, greys only, no colour.
   `(mode-line ((t (:background ,raised :foreground ,white
                                :box (:line-width (1 . 1) :style flat-button)))))
   ;; Emacs 29+ paints the SELECTED window's bar with `mode-line-active', not with
   ;; `mode-line' -- so it has to be named here even though it would normally
   ;; inherit.  It bit once: the config used to set it by hand (`set-face-attribute'
   ;; to a slate blue, to calm deeper-blue's bar), and an attribute set by hand
   ;; outlives the theme's parent face, so the one bar you are actually looking at
   ;; stayed blue while every other surface followed the palette.
   `(mode-line-active ((t (:inherit mode-line))))
   `(mode-line-inactive ((t (:background ,dim-bg :foreground ,faint
                                         :box (:line-width (1 . 1) :color ,bg
                                               :style flat-button)))))
   `(mode-line-buffer-id ((t (:foreground ,bright :weight bold))))
   `(mode-line-emphasis ((t (:foreground ,blue))))
   `(mode-line-highlight ((t (:foreground ,bright :box nil))))
   `(header-line ((t (:background ,raised :foreground ,white))))
   `(tab-bar ((t (:background ,raised :foreground ,faint))))
   `(tab-bar-tab ((t (:background ,bg :foreground ,white))))
   `(tab-bar-tab-inactive ((t (:background ,raised :foreground ,faint))))

   ;; --- the terminals inside Emacs -----------------------------------------
   ;; Emacs's ANSI faces ARE the terminal's palette, so a `git log --color' rendered
   ;; in a ghostel buffer, in a compilation buffer or by rg is the same green as the
   ;; same command in Ghostty.
   `(ansi-color-black ((t (:background ,raised :foreground ,bg))))
   `(ansi-color-red ((t (:background ,red :foreground ,bg))))
   `(ansi-color-green ((t (:background ,green :foreground ,bg))))
   `(ansi-color-yellow ((t (:background ,yellow :foreground ,bg))))
   `(ansi-color-blue ((t (:background ,blue :foreground ,bg))))
   `(ansi-color-magenta ((t (:background ,magenta :foreground ,bg))))
   `(ansi-color-cyan ((t (:background ,cyan :foreground ,bg))))
   `(ansi-color-white ((t (:background ,white :foreground ,bg))))
   `(ansi-color-bright-black ((t (:background ,faint :foreground ,bg))))
   `(ansi-color-bright-red ((t (:background ,hi-red :foreground ,bg))))
   `(ansi-color-bright-green ((t (:background ,hi-green :foreground ,bg))))
   `(ansi-color-bright-yellow ((t (:background ,hi-yellow :foreground ,bg))))
   `(ansi-color-bright-blue ((t (:background ,hi-blue :foreground ,bg))))
   `(ansi-color-bright-magenta ((t (:background ,hi-magenta :foreground ,bg))))
   `(ansi-color-bright-cyan ((t (:background ,hi-cyan :foreground ,bg))))
   `(ansi-color-bright-white ((t (:background ,bright :foreground ,bg))))
   `(term-color-black ((t (:background ,raised :foreground ,raised))))
   `(term-color-red ((t (:background ,red :foreground ,red))))
   `(term-color-green ((t (:background ,green :foreground ,green))))
   `(term-color-yellow ((t (:background ,yellow :foreground ,yellow))))
   `(term-color-blue ((t (:background ,blue :foreground ,blue))))
   `(term-color-magenta ((t (:background ,magenta :foreground ,magenta))))
   `(term-color-cyan ((t (:background ,cyan :foreground ,cyan))))
   `(term-color-white ((t (:background ,white :foreground ,white))))

   ;; --- code: the roles rano names, on the slots it names them on -----------
   `(font-lock-comment-face ((t (:foreground ,faint :slant italic))))
   `(font-lock-comment-delimiter-face ((t (:inherit font-lock-comment-face))))
   `(font-lock-doc-face ((t (:foreground ,hi-green))))
   `(font-lock-string-face ((t (:foreground ,green))))
   `(font-lock-keyword-face ((t (:foreground ,magenta))))
   `(font-lock-builtin-face ((t (:foreground ,hi-blue))))
   `(font-lock-function-name-face ((t (:foreground ,blue))))
   `(font-lock-function-call-face ((t (:inherit font-lock-function-name-face))))
   `(font-lock-variable-name-face ((t (:foreground ,fg))))
   `(font-lock-variable-use-face ((t (:foreground ,fg))))
   `(font-lock-type-face ((t (:foreground ,cyan))))
   `(font-lock-constant-face ((t (:foreground ,yellow))))
   `(font-lock-number-face ((t (:foreground ,yellow))))
   `(font-lock-preprocessor-face ((t (:foreground ,hi-magenta))))
   `(font-lock-negation-char-face ((t (:foreground ,hi-red))))
   `(font-lock-warning-face ((t (:foreground ,hi-red :weight bold))))
   `(font-lock-regexp-grouping-backslash ((t (:foreground ,hi-magenta))))
   `(font-lock-regexp-grouping-construct ((t (:foreground ,hi-magenta))))
   `(font-lock-bracket-face ((t (:foreground ,faint))))
   `(font-lock-delimiter-face ((t (:foreground ,faint))))
   `(font-lock-escape-face ((t (:foreground ,hi-magenta))))
   `(font-lock-misc-punctuation-face ((t (:foreground ,faint))))
   `(font-lock-operator-face ((t (:foreground ,white))))
   `(font-lock-property-name-face ((t (:foreground ,cyan))))
   `(font-lock-property-use-face ((t (:foreground ,cyan))))
   `(parenthesis ((t (:inherit default :foreground ,faint))))
   `(show-paren-match ((t (:background ,sel-bg))))
   `(show-paren-mismatch ((t (:background ,red :foreground ,bg))))
   `(eldoc-highlight-function-argument ((t (:foreground ,hi-yellow :weight bold))))

   ;; --- line numbers, structure ---------------------------------------------
   `(line-number ((t (:inherit (shadow default) :foreground ,faint :height 95))))
   `(line-number-current-line ((t (:inherit line-number :foreground ,white))))
   `(diff-hl-insert ((t (:foreground ,green :background ,bg))))
   `(diff-hl-delete ((t (:foreground ,red :background ,bg))))
   `(diff-hl-change ((t (:foreground ,yellow :background ,bg))))

   ;; --- search --------------------------------------------------------------
   ;; A terminal-style reverse: the selection colour of the palette, not a hue
   ;; invented for searching.
   `(isearch ((t (:background ,yellow :foreground ,bg :weight bold))))
   `(isearch-fail ((t (:background ,red :foreground ,bg))))
   `(lazy-highlight ((t (:background ,sel-bg :foreground ,sel-fg))))
   `(match ((t (:background ,yellow :foreground ,bg))))
   `(iedit-occurrence ((t (:background ,sel-bg :foreground ,sel-fg))))
   `(completions-common-part ((t (:foreground ,blue))))
   `(completions-first-difference ((t (:foreground ,yellow))))
   `(vertico-current ((t (:background ,sel-bg))))

   ;; --- diagnostics, build output -------------------------------------------
   `(success ((t (:foreground ,green))))
   `(warning ((t (:foreground ,yellow))))
   `(error ((t (:foreground ,red))))
   `(compilation-error ((t (:foreground ,red))))
   `(compilation-warning ((t (:inherit warning :foreground ,hi-yellow))))
   `(compilation-info ((t (:foreground ,blue :weight normal))))
   `(compilation-line-number ((t (:foreground ,faint))))
   `(compilation-column-number ((t (:foreground ,faint))))
   `(flymake-error ((t (:underline (:color ,red :style wave)))))
   `(flymake-warning ((t (:underline (:color ,yellow :style wave)))))
   `(flymake-note ((t (:underline (:color ,cyan :style wave)))))
   `(flycheck-error ((t (:background ,del-bg :underline (:color ,red :style wave)))))
   `(eglot-highlight-symbol-face ((t (:background ,hl-tint :foreground ,hi-yellow
                                                  :weight bold))))
   `(eglot-diagnostic-tag-unnecessary-face ((t (:foreground ,faint))))
   `(eglot-inlay-hint-face ((t (:foreground ,faint :slant italic))))
   `(eglot-mode-line ((t (:foreground ,cyan))))
   ;; envrc reports in the mode line; its "none" state inherits `warning' -- a
   ;; bright yellow, i.e. a status colour for a state that is not one.
   `(envrc-mode-line-none-face ((t (:inherit nil :foreground ,faint :weight normal))))
   `(envrc-mode-line-on-face ((t (:inherit nil :foreground ,green))))
   `(envrc-mode-line-error-face ((t (:inherit nil :foreground ,red))))

   ;; --- completion popups ---------------------------------------------------
   `(company-tooltip ((t (:background ,raised :foreground ,fg))))
   `(company-tooltip-selection ((t (:background ,sel-bg :foreground ,sel-fg))))
   `(company-tooltip-common ((t (:foreground ,blue))))
   `(company-tooltip-annotation ((t (:foreground ,faint))))
   `(company-tooltip-scrollbar-thumb ((t (:background ,faint))))
   `(company-tooltip-scrollbar-track ((t (:background ,raised))))

   ;; --- diffs and git -------------------------------------------------------
   `(diff-added ((t (:foreground ,hi-green :background ,add-bg))))
   `(diff-removed ((t (:foreground ,hi-red :background ,del-bg))))
   `(diff-changed ((t (:foreground ,hi-yellow :background ,chg-bg))))
   `(diff-refine-added ((t (:foreground ,bright :background ,add-bg2))))
   `(diff-refine-removed ((t (:foreground ,bright :background ,del-bg2))))
   `(diff-refine-changed ((t (:foreground ,bright :background ,chg-bg2))))
   `(diff-header ((t (:background ,raised :foreground ,white))))
   `(diff-file-header ((t (:background ,raised :foreground ,bright :weight bold))))
   `(diff-hunk-header ((t (:foreground ,cyan))))
   `(diff-indicator-added ((t (:foreground ,hi-green))))
   `(diff-indicator-removed ((t (:foreground ,hi-red))))
   `(diff-indicator-changed ((t (:foreground ,hi-yellow))))
   `(smerge-upper ((t (:background ,del-bg))))
   `(smerge-lower ((t (:background ,add-bg))))
   `(smerge-refined-added ((t (:background ,add-bg2))))
   `(smerge-refined-removed ((t (:background ,del-bg2))))
   `(magit-section-highlight ((t (:background ,raised))))
   `(magit-section-heading ((t (:foreground ,blue :weight bold))))
   `(magit-section-secondary-heading ((t (:foreground ,magenta :weight bold))))
   `(magit-branch-local ((t (:foreground ,hi-green))))
   `(magit-branch-remote ((t (:foreground ,green))))
   `(magit-tag ((t (:foreground ,yellow))))
   `(magit-hash ((t (:foreground ,faint))))
   `(magit-log-author ((t (:foreground ,cyan))))
   `(magit-log-date ((t (:foreground ,faint))))
   `(magit-cherry-equivalent ((t (:foreground ,magenta))))
   `(magit-process-ok ((t (:foreground ,green :weight bold))))
   `(magit-process-ng ((t (:foreground ,red :weight bold))))
   `(git-commit-summary ((t (:foreground ,blue))))
   `(git-commit-comment-heading ((t (:foreground ,magenta :weight bold))))
   `(git-commit-comment-file ((t (:foreground ,cyan))))
   `(git-commit-comment-action ((t (:foreground ,hi-red))))

   ;; --- ediff (ediff-review runs through it) --------------------------------
   `(ediff-current-diff-A ((t (:background ,del-bg))))
   `(ediff-current-diff-B ((t (:background ,add-bg))))
   `(ediff-current-diff-C ((t (:background ,chg-bg))))
   `(ediff-fine-diff-A ((t (:background ,del-bg2))))
   `(ediff-fine-diff-B ((t (:background ,add-bg2))))
   `(ediff-fine-diff-C ((t (:background ,chg-bg2))))
   `(ediff-even-diff-A ((t (:background ,dim-bg))))
   `(ediff-even-diff-B ((t (:background ,dim-bg))))
   `(ediff-even-diff-C ((t (:background ,dim-bg))))
   `(ediff-odd-diff-A ((t (:background ,dim-bg))))
   `(ediff-odd-diff-B ((t (:background ,dim-bg))))
   `(ediff-odd-diff-C ((t (:background ,dim-bg))))

   ;; --- dired ---------------------------------------------------------------
   `(dired-directory ((t (:foreground ,blue :weight bold))))
   `(dired-header ((t (:foreground ,cyan :weight bold))))
   `(dired-marked ((t (:foreground ,yellow))))
   `(dired-flagged ((t (:foreground ,red))))
   `(dired-ignored ((t (:foreground ,faint))))
   `(dired-symlink ((t (:foreground ,cyan :slant italic))))
   `(dired-perm-write ((t (:foreground ,yellow))))

   ;; --- org / markdown: rano's `heading' and `code' roles -------------------
   `(org-document-title ((t (:foreground ,bright :weight bold))))
   `(org-level-1 ((t (:foreground ,blue :weight bold))))
   `(org-level-2 ((t (:foreground ,cyan :weight bold))))
   `(org-level-3 ((t (:foreground ,magenta :weight bold))))
   `(org-level-4 ((t (:foreground ,green))))
   `(org-level-5 ((t (:foreground ,hi-blue))))
   `(org-level-6 ((t (:foreground ,hi-magenta))))
   `(org-level-7 ((t (:foreground ,hi-cyan))))
   `(org-level-8 ((t (:foreground ,hi-green))))
   `(org-code ((t (:foreground ,cyan))))
   `(org-verbatim ((t (:foreground ,cyan))))
   `(org-block ((t (:background ,raised))))          ; the raised surface again
   `(org-block-begin-line ((t (:background ,raised :foreground ,faint))))
   `(org-block-end-line ((t (:background ,raised :foreground ,faint))))
   `(org-quote ((t (:foreground ,faint :slant italic))))
   `(org-table ((t (:foreground ,blue))))
   `(org-todo ((t (:foreground ,red :weight bold))))
   `(org-done ((t (:foreground ,green :weight bold))))
   `(org-date ((t (:foreground ,hi-magenta :underline t))))
   `(org-tag ((t (:foreground ,yellow))))
   `(markdown-header-face-1 ((t (:inherit org-level-1))))
   `(markdown-header-face-2 ((t (:inherit org-level-2))))
   `(markdown-header-face-3 ((t (:inherit org-level-3))))
   `(markdown-header-face-4 ((t (:inherit org-level-4))))
   `(markdown-header-face-5 ((t (:inherit org-level-5))))
   `(markdown-header-face-6 ((t (:inherit org-level-6))))
   `(markdown-code-face ((t (:background ,raised))))
   `(markdown-inline-code-face ((t (:foreground ,cyan))))
   `(markdown-link-face ((t (:foreground ,blue))))
   `(markdown-url-face ((t (:foreground ,faint))))
   `(markdown-list-face ((t (:foreground ,yellow))))
   `(markdown-blockquote-face ((t (:foreground ,faint :slant italic))))
   `(markdown-bold-face ((t (:foreground ,bright :weight bold))))
   `(markdown-italic-face ((t (:foreground ,bright :slant italic))))
   `(markdown-pre-face ((t (:foreground ,cyan))))

   ;; --- the dashboard (all-the-icons glyphs take the palette too) -----------
   `(dashboard-banner-logo-title ((t (:foreground ,cyan :weight bold))))
   `(dashboard-heading ((t (:foreground ,blue :weight bold))))
   `(dashboard-items-face ((t (:foreground ,fg))))
   `(dashboard-no-items-face ((t (:foreground ,faint))))
   `(dashboard-key-items-face ((t (:foreground ,cyan))))
   `(dashboard-footer-face ((t (:foreground ,faint))))))

;;;###autoload
(when (and (boundp 'custom-theme-load-path) load-file-name)
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'letibot-gray)
;;; letibot-gray-theme.el ends here
