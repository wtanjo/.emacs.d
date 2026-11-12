;;; -*- lexical-binding: t -*-

(set-frame-font (font-spec :family "Iosevka" :size 28))
(set-fontset-font t 'unicode (font-spec :family "Twemoji Mozilla" :size 28))
(set-fontset-font t 'han (font-spec :family "LXGW WenKai Mono" :size 28))
(set-fontset-font t 'cjk-misc (font-spec :family "LXGW WenKai Mono" :size 28))
(set-fontset-font t 'kana (font-spec :family "Sarasa" :size 28))

(use-package gruber-darker-theme
  :ensure t
  :config
  (load-theme 'gruber-darker :no-confirm)
  (set-face-background 'show-paren-match "steelblue4")
  (set-face-foreground 'shadow "#9d9087"))

(provide 'gruber-darker-scheme)
