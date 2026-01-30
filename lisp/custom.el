(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-message t)
(global-hl-line-mode 1)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(add-to-list 'default-frame-alist '(fullscreen . maximized))      ;; 启动时全屏
(add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))    ;; 编程模式中禁止折行
(global-set-key (kbd "C-c z") 'toggle-truncate-lines)             ;; C-c [a-z] 为官方规定用户自定义键位保留区
(setq scroll-margin 1
      scroll-step 1
      hscroll-margin 2
      hscroll-step 1
      auto-window-vscroll nil
      scroll-preserve-screen-position t)

(set-frame-font (font-spec :family "Iosevka" :size 45))
(set-fontset-font t 'unicode (font-spec :family "Segoe UI Emoji"))
(set-fontset-font t 'han (font-spec :family "华文行楷" :size 45))
(set-fontset-font t 'kana (font-spec :family "HGGyoshotai" :size 45))

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
                      :background 'unspecified
                      :foreground 'unspecified
                      :weight 'bold))

(use-package dashboard
  :ensure t
  :config
  (setq dashboard-banner-logo-title "In solitude, where we are least alone.")
  (setq dashboard-startup-banner 'official) ;; 也可以自定义图片
  (setq dashboard-startupify-list '(dashboard-insert-banner
                                    dashboard-insert-newline
                                    dashboard-insert-banner-title
                                    dashboard-insert-newline
                                    dashboard-insert-navigator
                                    dashboard-insert-newline
                                    dashboard-insert-init-info
                                    dashboard-insert-items
                                    dashboard-insert-newline
                                    dashboard-insert-footer))

  (setq dashboard-navigator-buttons
      `((("1" "NA II" "Open" (lambda (&rest _) (dired "E:/DS/Numerical Algorithm II")))
         ("2" "DB" "Open" (lambda (&rest _) (dired "E:/DS/Database")))
         ("3" "Config" "Open Emacs Config" (lambda (&rest _) (dired "~/.emacs.d"))))))
  (setq dashboard-items '((recents   . 20)
			              (projects  . 10)
			              (agenda    . 10) ;; org-agenda
                          (bookmarks . 5)
                          (registers . 5)))
  (setq dashboard-item-shortcuts '((recents   . "r")
				                   (projects  . "p")
				                   (agenda    . "a")
                                   (bookmarks . "m")                                  
                                   (registers . "e")))
  (setq dashboard-center-content t)
  (dashboard-setup-startup-hook))

(use-package rainbow-delimiters
 :ensure t
 :hook (prog-mode . rainbow-delimiters-mode))

;; Customization of the original modeline
(column-number-mode 1)
(size-indication-mode 1)
(display-battery-mode 1)
(setq-default mode-line-mule-info 
              '(""  mode-line-coding-system-indicator))













(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(catppuccin-theme consult corfu dashboard diff-hl drag-stuff magit
                      multiple-cursors orderless
                      rainbow-delimiters vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
