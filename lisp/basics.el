(global-auto-revert-mode t)
(setq make-backup-files nil)
(savehist-mode 1)
(setq ring-bell-function 'ignore)

(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(global-font-lock-mode t)
(electric-pair-mode t)
(show-paren-mode t)
(setq show-paren-delay 0)
(delete-selection-mode t)
(repeat-mode t)

(set-language-environment "UTF-8")
(set-keyboard-coding-system 'utf-8)

(provide 'basics)
