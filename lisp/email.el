(setq epa-pinentry-mode 'loopback)

(use-package mu4e
  :ensure nil
  :load-path "/usr/share/emacs/site-lisp/mu4e"
  :config
  ;; --- 基础路径设置 ---
  (setq mu4e-maildir "~/Mails"
        mu4e-get-mail-command "mbsync -a"
        mu4e-update-interval 300
        mu4e-attachment-dir "~/Downloads"
        mu4e-change-filenames-when-moving t
        mu4e-completing-read-function 'completing-read)

  ;; --- 界面美化 ---
  (setq mu4e-use-fancy-chars t
        mu4e-view-show-images t
        mu4e-view-show-addresses t
        mu4e-headers-include-related t
        mu4e-headers-fields '((:human-date . 12)
                              (:flags . 6)
                              (:maildir . 10)
                              (:from . 22)
                              (:subject . nil)))

  ;; --- 多账号上下文 (Contexts) ---
  (setq mu4e-contexts
        (list
         (make-mu4e-context
          :name "QQ"
          :match-func (lambda (msg) (when msg (string-prefix-p "/QQ" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address  . "2403627832@qq.com")
                  (user-full-name     . "wtanjo")
                  (mu4e-sent-folder   . "/QQ/Sent Messages")
                  (mu4e-drafts-folder . "/QQ/Drafts")
                  (mu4e-trash-folder  . "/QQ/Trash")
                  (smtpmail-smtp-server . "smtp.qq.com")
                  (smtpmail-smtp-service . 465)
                  (smtpmail-stream-type . ssl)))
         (make-mu4e-context
          :name "Fudan"
          :match-func (lambda (msg) (when msg (string-prefix-p "/Fudan" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address  . "24300240119@m.fudan.edu.cn")
                  (mu4e-sent-folder   . "/Fudan/Sent") ; 请根据实际目录名修改
                  (smtpmail-smtp-server . "smtp.exmail.qq.com")
                  (smtpmail-smtp-service . 465)
                  (smtpmail-stream-type . ssl)))))

  (setq mu4e-context-policy 'pick-first)

  (setq message-send-mail-function 'smtpmail-send-it
        smtpmail-debug-info t)
  (setq mu4e-compose-format-flowed nil)

  :bind (("C-x m" . mu4e)
         :map mu4e-main-mode-map
         ("U" . mu4e-update-mail-and-index)))

(use-package org-mime
  :ensure t
  :config
  ;; 1. 设置导出选项：强制使用图片处理公式
  (setq org-mime-export-options '(:with-latex dvipng :section-numbers nil :with-toc nil))
  
  ;; 2. 核心：强制将 CSS 类转为内联 Style (解决居中问题)
  ;; 2. 暴力修复钩子
  (add-hook 'org-mime-html-hook
            (lambda ()
              (save-excursion
                (goto-char (point-min))
                ;; 暴力替换 1：把 org-center 类直接换成内联样式
                (while (re-search-forward "class=\"org-center\"" nil t)
                  (replace-match "style=\"text-align: center; margin: 0 auto;\""))
                
                ;; 暴力替换 2：处理可能存在的其它居中容器
                (goto-char (point-min))
                (while (re-search-forward "<div class=\"outline-text-[0-9]\"" nil t)
                  (replace-match "<div style=\"text-align: left;\"")) ;; 确保正文不被误伤
                )))
  :bind ("C-c M-f" . org-mime-htmlize))

(provide 'email)
