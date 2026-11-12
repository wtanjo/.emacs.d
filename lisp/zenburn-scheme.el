;;; -*- lexical-binding: t -*-

(set-frame-font (font-spec :family "Ubuntu Mono" :size 28))
(set-fontset-font t 'unicode (font-spec :family "Twemoji Mozilla" :size 28))
(set-fontset-font t 'han (font-spec :family "LXGW WenKai Mono" :size 28))
(set-fontset-font t 'cjk-misc (font-spec :family "LXGW WenKai Mono" :size 28))
(set-fontset-font t 'kana (font-spec :family "Sarasa" :size 28))

(use-package zenburn-theme
  :ensure t
  :config
  (load-theme 'zenburn :no-confirm))

(provide 'zenburn-scheme)
