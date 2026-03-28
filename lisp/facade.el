(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-message t)
(global-hl-line-mode 1)
(global-display-line-numbers-mode 1)
(setq-default display-line-numbers-width-start t)
(setq display-line-numbers-type 'relative)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'markdown-mode-hook #'visual-line-mode)
(global-goto-address-mode 1)
(keymap-global-set "C-c z" #'toggle-truncate-lines)
(setq scroll-margin 1
      scroll-step 1
      hscroll-margin 2
      hscroll-step 1
      auto-window-vscroll nil
      scroll-preserve-screen-position t)
(set-fringe-mode '(16 . 8))

(set-frame-font (font-spec :family "Iosevka" :size 28))
(set-fontset-font t 'unicode (font-spec :family "Noto Color Emoji" :size 28))
(set-fontset-font t 'han (font-spec :family "LXGW WenKai Mono" :size 28))
(set-fontset-font t 'kana (font-spec :family "Sarasa" :size 28))

;; (use-package catppuccin-theme
;;   :ensure t
;;   :config
;;   (catppuccin-set-color 'base "#000000")
;;   (catppuccin-set-color 'yellow "#ffdd33" 'mocha)
;;   (catppuccin-set-color 'green "#66bb33" 'mocha)
;;   (catppuccin-set-color 'sky "#59ddb9" 'mocha)
;;   (catppuccin-set-color 'sapphire "#66aadd" 'mocha)
;;   (setq catppuccin-flavor 'mocha)
;;   (load-theme 'catppuccin :no-confirm)
;;   
;;   (set-face-background 'hl-line "#242730")
;;   (set-face-background 'cursor "#c2ad98")
;;   (set-face-foreground 'font-lock-comment-face "#6272a4")
;;   (set-face-italic 'font-lock-comment-face t)
;;   (set-face-attribute 'font-lock-comment-delimiter-face nil :foreground 'unspecified :inherit 'font-lock-comment-face)
;;   (set-face-attribute 'region nil :background "#5c3d4a" :foreground 'unspecified :weight 'bold)
;;   (set-face-attribute 'font-lock-keyword-face nil :weight 'bold))

(use-package gruber-darker-theme
  :ensure t
  :config
  (load-theme 'gruber-darker :no-confirm))

(with-eval-after-load 'vertico
  (set-face-attribute 'vertico-current nil
                      :background 'unspecified
                      :foreground 'unspecified
                      :weight 'bold))

(use-package enlight
  :ensure t
  :custom
  (enlight-content
   (concat
    (propertize "Emacs" 'face '(:family "Dancing Script" :height 3.0 :weight 'bold))

    "\n\n\n"

    (enlight-menu
     '(("~"
        ("~" (dired "~") "~")
        ("Downloads" (dired "~/Downloads") "D")
        ("Reservation" (dired "~/reservation") "r"))
       ("Reservation"
        ("DS" (dired "~/reservation/DS") "d")
        ("pages" (dired "~/reservation/pages") "b")
        ("programming" (dired "~/reservation/programming") "p"))
       ("Config"
        ("System Config" (dired "~/.config") "s")
        ("Emacs Config" (dired "~/.emacs.d") "e"))
       ("Agenda"
	    ("TODO" (org-agenda nil "t") "t")
        ("Agenda" (org-agenda nil "a") "a")
        ("View In File" (dired (car org-agenda-files)) "A"))))))
  
  :config
  (add-hook 'enlight-mode-hook (lambda ()
                                 (display-line-numbers-mode -1)
                                 (setq-local global-hl-line-mode nil)
                                 (hl-line-mode -1)))
  (setopt initial-buffer-choice #'enlight))

(use-package rainbow-delimiters
 :ensure t
 :hook (prog-mode . rainbow-delimiters-mode))

;; Customization of the original modeline
(column-number-mode 1)
(size-indication-mode 1)
(display-battery-mode 1)

(setq dired-listing-switches "-alh")

(provide 'facade)
