(keymap-global-set "C-z" nil)
(keymap-global-set "C-s" nil)
(bind-key* "C-c C-f" #'ignore)
(keymap-global-set "C-x C-f" #'find-file-at-point)

(keymap-global-set "C-c c" #'compile)
(setq-default compile-command "")
(defun wt/python-compile-setup ()
  "compile setup for python"
  (setq-local compile-command (format "./.venv/Scripts/activate && python3 %s" (shell-quote-argument (buffer-file-name)))))
(add-hook 'python-base-mode-hook #'wt/python-compile-setup)

(defun wt/c-compile-setup ()
  "compile setup for c"
  (setq-local compile-command (format "clang %s -o %s && ./%s" 
                                      (buffer-file-name)
                                      (file-name-sans-extension (buffer-file-name))
                                      (file-name-sans-extension (buffer-file-name)))))
(add-hook 'c-mode-hook #'wt/c-compile-setup)
(add-hook 'c-ts-mode-hook #'wt/c-compile-setup)

(defun wt/c++-compile-setup ()
  "compile setup for c++"
  (setq-local compile-command (format "clang++ %s -o %s && ./%s" 
                                      (buffer-file-name)
                                      (file-name-sans-extension (buffer-file-name))
                                      (file-name-sans-extension (buffer-file-name)))))
(add-hook 'c++-mode-hook #'wt/c++-compile-setup)
(add-hook 'c++-ts-mode-hook #'wt/c++-compile-setup)

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
(keymap-global-set "C-s d" #'scroll-up-line)
(keymap-global-set "C-s u" #'scroll-down-line)
(keymap-global-set "C-," #'wt/duplicate-line)

(defun wt/copy-line-or-region (n)
  (interactive "p")
  (unless n
    (setq n 1))
  (if (region-active-p)
      (kill-ring-save (region-beginning) (region-end))
    (save-excursion
      (let ((beg (line-beginning-position))
            (end (line-beginning-position (+ n 1))))
        (copy-region-as-kill beg end)))))
(keymap-global-set "M-w" #'wt/copy-line-or-region)

;; BUILTIN: C-S-backspace == 'kill-whole-line
(defun wt/kill-line-or-region (n)
  (interactive "p")
  (unless n
    (setq n 1))
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (kill-whole-line n)
    (previous-line n)))
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
  (("C-c C-c l" . consult-line)
   ("C-c C-c f" . consult-fd)
   ("C-c C-c g" . consult-ripgrep)))

(use-package drag-stuff
  :ensure t
  :bind (("M-p" . drag-stuff-up)    ; Alt + P 向上移
         ("M-n" . drag-stuff-down)  ; Alt + N 向下移
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

(use-package treesit
  :when (and (fboundp 'treesit-available-p)
             (treesit-available-p))
  :config
  (setq major-mode-remap-alist
   '((c-mode          . c-ts-mode)
     (c++-mode        . c++-ts-mode)
     (python-mode     . python-ts-mode)
     (go-mode         . go-ts-mode)
     (conf-toml-mode  . toml-ts-mode)
     (js-json-mode    . json-ts-mode)))
  (setq treesit-font-lock-level 4)
  (setq treesit-language-source-alist
   '((c "https://github.com/tree-sitter/tree-sitter-c" "v0.23.6")
     (cpp "https://github.com/tree-sitter/tree-sitter-cpp" "v0.23.4")
     (python "https://github.com/tree-sitter/tree-sitter-python" "v0.23.6")
     (go "https://github.com/tree-sitter/tree-sitter-go" "v0.23.4")
     (rust "https://github.com/tree-sitter/tree-sitter-rust" "v0.23.3")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (json "https://github.com/tree-sitter/tree-sitter-json")))
  :mode
  (("\\.rs\\'" . rust-ts-mode)))

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

  (corfu-auto t)
  (corfu-auto-delay 0)
  (corfu-auto-prefix 1)
  (corfu-popupinfo-delay 0)

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  :hook (prog-mode . corfu-mode)
  :bind (:map corfu-map
              ("M-p" . corfu-popupinfo-scroll-down)
              ("M-n" . corfu-popupinfo-scroll-up)
              ("M-d" . corfu-popupinfo-toggle))
  :init

  ;; Recommended: Enable Corfu globally.  Recommended since many modes provide
  ;; Capfs and Dabbrev can be used globally (M-/).  See also the customization
  ;; variable `global-corfu-modes' to exclude certain modes.
  ;; (global-corfu-mode)

  ;; Enable optional extension modes:
  (corfu-popupinfo-mode)
  (corfu-history-mode))

(use-package eglot
  :ensure t
  :hook ((python-mode . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (c-ts-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (c++-ts-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs
               (list '(python-mode python-ts-mode)
                     (if (eq system-type 'windows-nt)
                         "basedpyright-langserver.CMD"
                       "basedpyright-langserver")
                     "--stdio"))
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode c-ts-mode c++-ts-mode)
                 . ("clangd" "--background-index" "--clang-tidy"))))

(use-package eaf
  :load-path "~/.emacs.d/site-lisp/emacs-application-framework"
  :config
  (require 'eaf-browser)
  (require 'eaf-pdf-viewer)
  (require 'eaf-image-viewer)
  (require 'eaf-file-sender)
  (require 'eaf-airshare)
  (require 'eaf-file-browser)
  (require 'eaf-video-player)
  (require 'eaf-camera)
  (require 'eaf-2048)
  :custom
  (eaf-browser-enable-adblocker t)
  (eaf-browser-continue-where-left-off t))

(provide 'utilities)
