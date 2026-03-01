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

  :bind (("C-x m" . mu4e)
         :map mu4e-main-mode-map
         ("U" . mu4e-update-mail-and-index)))

(use-package org-msg
  :ensure t
  :after mu4e
  :config
  (setq org-msg-options "html-postamble:nil"
        org-msg-startup "hidestars"
        org-msg-greeting-fmt "\nHi %s,\n\n"
        org-msg-default-alternatives '((html (text desc)) (text)))
  (org-msg-mode))

(provide 'email)
