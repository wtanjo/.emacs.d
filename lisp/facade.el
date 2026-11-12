;;; -*- lexical-binding: t -*-

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
(add-hook 'dired-mode-hook (lambda () (setq truncate-lines t)))
(add-hook 'text-mode-hook #'visual-line-mode)
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

(require 'gruber-darker-scheme)

;; (require 'zenburn-scheme)

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
        ("Documents" (dired "~/Documents") "D")
        ("opt" (dired "~/opt") "o")
        ("reservation" (dired "~/reservation") "r")
        ("tmp" (dired "~/tmp") "t"))
       
       ("Reservation"
        ("DS" (dired "~/reservation/DS") "d")
        ("languages" (dired "~/reservation/languages") "l")
        ("programming" (dired "~/reservation/programming") "p")
        ("writing" (dired "~/reservation/wtanjo/U盘/汇贤——格致——复旦（渡边掸尘）/tanjo/写作") "w"))
       
       ("Config"
        ("System Config" (dired "~/.config") "s")
        ("Emacs Config" (dired "~/.emacs.d") "e"))))))
  
  :config
  (add-hook 'enlight-mode-hook (lambda ()
                                 (display-line-numbers-mode -1)
                                 (setq-local global-hl-line-mode nil)
                                 (hl-line-mode -1)))
  (setopt initial-buffer-choice #'enlight))

(use-package rainbow-delimiters
 :ensure t
 :hook (prog-mode . rainbow-delimiters-mode)
 :hook (vala-mode . rainbow-delimiters-mode))

;; Customization of the original modeline
(column-number-mode 1)
(size-indication-mode 1)
(display-battery-mode 1)

(setq dired-listing-switches "-alh")

(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

(add-hook 'makefile-mode-hook (lambda () (setq indent-tabs-mode t)))
(add-hook 'go-ts-mode-hook
          (lambda ()
            (setq indent-tabs-mode t)
            (setq-local tab-width 8)))

(provide 'facade)
