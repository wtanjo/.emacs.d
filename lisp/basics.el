(global-auto-revert-mode t)              ; 当外部程序修改了文件时，让 Emacs 及时刷新 Buffer
(setq make-backup-files nil)
(savehist-mode 1)                        ; 打开 Buffer 历史记录保存
(setq ring-bell-function 'ignore)

(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)      ; 相当于 Vim 里的 expandtab
(add-hook 'makefile-mode-hook (lambda () (setq indent-tabs-mode t)))
(global-font-lock-mode t)                ; 语法高亮
(electric-pair-mode t)                   ; 自动补全括号
(show-paren-mode t)                      ; 括号高亮
(setq show-paren-delay 0)                ; 括号高亮不要延迟
(delete-selection-mode t)                ; 选中文本后输入文本会替换文本
(repeat-mode t)                          ; 开启后重复命令可以只输一次前缀
(set-fringe-mode '(16 . 8))

(set-keyboard-coding-system 'utf-8)

(keymap-global-set "RET" #'newline-and-indent)

(when (eq system-type 'windows-nt)
  (setq explicit-shell-file-name "pwsh.exe")
  (setq shell-file-name "pwsh.exe"))

(provide 'basics)
