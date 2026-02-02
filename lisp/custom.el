(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-message t)
(global-hl-line-mode 1)
(global-display-line-numbers-mode 1)
(setq-default display-line-numbers-width-start t)
(setq display-line-numbers-type 'relative)
(add-to-list 'default-frame-alist '(fullscreen . maximized))      ;; 启动时全屏
(add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))    ;; 编程模式中禁止折行
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'markdown-mode-hook #'visual-line-mode)
(global-goto-address-mode 1)
(keymap-global-set "C-c z" #'toggle-truncate-lines)               ;; C-c [a-z] 为官方规定用户自定义键位保留区
(setq scroll-margin 1
      scroll-step 1
      hscroll-margin 2
      hscroll-step 1
      auto-window-vscroll nil
      scroll-preserve-screen-position t)

(set-frame-font (font-spec :family "Iosevka" :size 45))
(set-fontset-font t 'unicode (font-spec :family "Segoe UI Emoji" :size 45))
(set-fontset-font t 'han (font-spec :family "LXGW Wenkai Mono" :size 45))
(set-fontset-font t 'kana (font-spec :family "UD Digi Kyokasho N" :size 45))

(use-package catppuccin-theme
  :ensure t
  :config
  (catppuccin-set-color 'base "#000000")
  (catppuccin-set-color 'yellow "#ffdd55" 'mocha)
  (catppuccin-set-color 'green "#66bb33" 'mocha)
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin :no-confirm)
  
  (set-face-background 'hl-line "#242730")
  (set-face-foreground 'font-lock-comment-face "#6272a4")
  (set-face-italic 'font-lock-comment-face t)
  (set-face-attribute 'font-lock-comment-delimiter-face nil :foreground 'unspecified :inherit 'font-lock-comment-face)
  (set-face-attribute 'region nil :background "#5c3d4a" :foreground 'unspecified :weight 'bold))

(with-eval-after-load 'vertico
  (set-face-attribute 'vertico-current nil 
                      :background "#242730"
                      :foreground 'unspecified
                      :weight 'bold))

(use-package enlight
  :ensure t
  :custom
  (enlight-content
   (concat
    (propertize "Emacs" 'face '(:family "Lucida Handwriting Italic" :height 1.5))

    "\n\n\n\n"

    (enlight-menu
     '(("Org Mode"
	    ("Org-Agenda" (org-agenda nil "a") "a"))
       ("Courses"
        ("Numerical Algorithm II" (dired "e:/DS/Numerical Algorithm II") "n")
        ("Database" (dired "e:/DS/Database") "d"))
       ("Disks"
        ("C:/" (dired "c:/") "C")
        ("D:/" (dired "d:/") "D")
        ("E:/" (dired "e:/") "E"))
       ("Config"
        ("Emacs Config" (dired "~/.emacs.d") "c"))
       ("Others"
	    ("Projects" project-switch-project "p"))))))
  
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














(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(catppuccin-theme consult corfu diff-hl drag-stuff enlight
                      magit multiple-cursors orderless
                      rainbow-delimiters vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
