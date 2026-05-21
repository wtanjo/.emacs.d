(keymap-global-set "C-z" nil)
(keymap-global-set "C-c C-f" nil)
(keymap-global-set "C-x s" #'save-buffer)
(keymap-global-set "C-x C-f" #'find-file-at-point)
(keymap-global-set "M-SPC" #'mark-word)

(keymap-global-set "C-c c" #'compile)
(setq-default compile-command "")

(defun wt/duplicate-line (n)
  "duplicate-line and go next line"
  (interactive "p")
  (unless n
    (setq n 1))
  (duplicate-line n)
  (next-line n))

(defvar-keymap repeatable
  :doc "repeatable keymaps"
  :repeat t
  "d" #'scroll-up-line
  "u" #'scroll-down-line)
(keymap-global-set "C-c d" #'scroll-up-line)
(keymap-global-set "C-c u" #'scroll-down-line)
(keymap-global-set "C-," #'wt/duplicate-line)

(defun wt/copy-line-or-region (n)
  "Copy the exact line without an extra blank line, or copy the region."
  (interactive "p")
  (unless n
    (setq n 1))
  (if (region-active-p)
      (kill-ring-save (region-beginning) (region-end))
      (let ((begin (line-beginning-position))
            (end (- (line-beginning-position (+ n 1)) 1)))
        (copy-region-as-kill begin end))))
(keymap-global-set "M-w" #'wt/copy-line-or-region)

(defun wt/kill-line-or-region (n)
  "Kill the exact line without the ending LF, which means you can paste it without an extra blank line, or kill the region.
This function cannot handle correctly occasions where the cursor is on the last line (where there is no line number)."
  (interactive "p")
  (unless n
    (setq n 1))
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (if (minibufferp)
        (kill-whole-line)
      (let ((col (- (point) (pos-bol))))
        (let ((begin (pos-bol))
              (end (- (pos-bol (+ n 1)) 1)))
          (kill-region begin end)
          (when (eq begin 1)
            (forward-line 1))
          (backward-delete-char-untabify 1 nil))
        (move-beginning-of-line nil)
        (catch 'break
          (dotimes (c col)
            (forward-char)
            (when (eq 0 (- (point) (pos-bol)))
              (forward-char -1)
              (throw 'break nil))))))))
(keymap-global-set "C-w" #'wt/kill-line-or-region)

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(with-eval-after-load 'project
  (defun wt/abbreviate-project-name (name)
    (if (< (length name) 12)
        name
      (let ((parts (split-string name "[-_ ]+" t)))
        (if (> (length parts) 1)
            (mapconcat (lambda (word) (substring word 0 1)) parts "-")
          (concat (substring name 0 (min 4 (length name))) "...")))))

  (defun wt/project-try-local (dir)
    "Determine if DIR is a non-Git project."
    (catch 'ret
      (let ((pr-flags '((".project") ;; highest priority
                        ("go.mod"
                         "Cargo.toml"
                         "pyproject.toml" "pyrightconfig.json" ".venv" "requirements.txt"
                         "compile_flags.txt" "compile_commands.json" ".clangd")
                        ("Makefile" "README.org" "README.md" ".editorconfig"))))
        (dolist (current-level pr-flags)
          (dolist (f current-level)
            (when-let ((root (locate-dominating-file dir f)))
              (throw 'ret (cons 'local root))))))))

  (cl-defmethod project-name ((project (head vc)))
    (wt/abbreviate-project-name (file-name-nondirectory (directory-file-name (nth 2 project)))))
  (cl-defmethod project-name ((project (head local)))
    (wt/abbreviate-project-name (file-name-nondirectory (directory-file-name (cdr project)))))

  (cl-defmethod project-root ((project (head local)))
    "Extract the root directory from a 'local' type project object."
    (cdr project))

  (setq project-find-functions '(wt/project-try-local project-try-vc))

  (defun wt/project-files-in-directory (dir)
    "Use `fd' to list files in DIR."
    (let* ((default-directory dir)
           (localdir (file-local-name (expand-file-name dir)))
           (command (format "fd -H -t f -0 . %s" localdir)))
      (project--remote-file-names
       (sort (split-string (shell-command-to-string command) "\0" t)
             #'string<))))

  (cl-defmethod project-files ((project (head local)) &optional dirs)
    "Override `project-files' to use `fd' in local projects."
    (mapcan #'wt/project-files-in-directory
            (or dirs (list (project-root project))))))

(use-package multiple-cursors
  :ensure t
  :bind
  (("C-S-c" . mc/edit-lines)
   ("C->" . mc/mark-next-like-this)
   ("C-<" . mc/mark-previous-like-this)
   ("C-!" . mc/mark-all-like-this)))

(use-package vertico
  :ensure t
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 15)
  (vertico-resize t)
  (vertico-cycle t)
  :init
  (vertico-mode)
  (vertico-flat-mode 1)
  (vertico-mouse-mode))

(use-package orderless
  :ensure t
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t))

(use-package consult
  :ensure t
  :config
  (setq consult-async-min-input 1)
  :bind
  (("C-c f" . consult-fd)
   ("C-c g" . consult-ripgrep)))

(use-package drag-stuff
  :ensure t
  :bind (("M-p" . drag-stuff-up)
         ("M-n" . drag-stuff-down)
         ("M-<up>" . drag-stuff-up)
         ("M-<down>" . drag-stuff-down))
  :config
  (drag-stuff-global-mode 1))

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode)
  (add-hook 'magit-pre-refresh-hook #'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

(use-package corfu
  :ensure t
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  (corfu-quit-no-match t)
  (corfu-preview-current nil)    ;; Disable current candidate preview
  (corfu-preselect 'prompt)      ;; Preselect the prompt(don't preselect any completions)
  (corfu-on-exact-match 'insert) ;; Configure handling of exact matches
  (corfu-preview-current nil)

  (corfu-auto nil)
  (corfu-popupinfo-delay 0.0)

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  ;; :hook (prog-mode . corfu-mode)
  :bind (:map corfu-map
              ("C-M-i" . completion-at-point)
              ("M-p" . corfu-popupinfo-scroll-down)
              ("M-n" . corfu-popupinfo-scroll-up)
              ("M-d" . corfu-popupinfo-toggle))
  :init

  ;; Recommended: Enable Corfu globally.  Recommended since many modes provide
  ;; Capfs and Dabbrev can be used globally (M-/).  See also the customization
  ;; variable `global-corfu-modes' to exclude certain modes.
  (global-corfu-mode)

  ;; Enable optional extension modes:
  (corfu-popupinfo-mode)
  (corfu-history-mode))

(use-package openwith
  :ensure t
  :config
  (setq openwith-associations '(("\\.pdf\\'" "okular" (file))
                                ("\\.docx\\'" "libreoffice" (file))
                                ("\\.doc\\'" "libreoffice" (file))
                                ("\\.xlsx\\'" "libreoffice" (file))
                                ("\\.pptx\\'" "libreoffice" (file))
                                ("\\.mp4\\'" "mpv" (file))
                                ("\\.mkv\\'" "mpv" (file))
                                ("\\.mp3\\'" "deadbeef" (file))
                                ("\\.ogg\\'" "deadbeef" (file))
                                ("\\.avif\\'" "firefox" (file)))))
(add-hook 'dired-mode-hook (lambda () (openwith-mode t)))

(setq org-agenda-files '("~/.emacs.d/agenda/"))
(setq org-latex-pdf-process
      '("latexmk -pdfxe -f -interaction=nonstopmode -output-directory=%o %f"))
(add-hook 'org-mode-hook (lambda () (keymap-set org-mode-map "C-," #'wt/duplicate-line)))

(add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'tags-completion-at-point-function)
  
  (setq dabbrev-check-all-buffers t
        dabbrev-check-other-buffers t))
(add-hook 'octave-mode-hook (lambda ()
                              (add-to-list 'completion-at-point-functions #'cape-dabbrev)))
(add-hook 'tex-mode-hook (lambda ()
                           (add-to-list 'completion-at-point-functions #'cape-tex)))
(add-hook 'org-mode-hook (lambda ()
                           (add-to-list 'completion-at-point-functions #'cape-tex)))

(add-hook 'makefile-mode-hook (lambda () (setq indent-tabs-mode t)))

(keymap-global-set "M-s" #'pinyin-isearch-forward)
(keymap-global-set "M-r" #'pinyin-isearch-backward)

(provide 'utilities)
