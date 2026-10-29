;;; hare-ts-mode.el --- tree-sitter support for Hare  -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Alex McGrath

;; Author     : Alex McGrath <amk@amk.ie>
;; Maintainer : Alex McGrath <amk@amk.ie>
;; Keywords   : Hare languages tree-sitter
;; Version: 0.1.0
;; Package-Requires: ((emacs "29"))

;;;
;;; Commentary:
;;

;;; Code:

(require 'treesit)
(eval-when-compile (require 'rx))

(declare-function treesit-parser-create "treesit.c")
(declare-function treesit-induce-sparse-tree "treesit.c")
(declare-function treesit-node-child "treesit.c")
(declare-function treesit-node-child-by-field-name "treesit.c")
(declare-function treesit-node-start "treesit.c")
(declare-function treesit-node-end "treesit.c")
(declare-function treesit-node-type "treesit.c")
(declare-function treesit-search-subtree "treesit.c")

(defcustom hare-ts-mode-indent-offset 8
  "Number of spaces for each indentation step in `hare-ts-mode'."
  :version "29.1"
  :type 'integer
  :safe 'integerp
  :group 'hare)

(defvar hare-ts-mode--syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?+   "."      table)
    (modify-syntax-entry ?-   "."      table)
    (modify-syntax-entry ?=   "."      table)
    (modify-syntax-entry ?%   "."      table)
    (modify-syntax-entry ?&   "."      table)
    (modify-syntax-entry ?|   "."      table)
    (modify-syntax-entry ?^   "."      table)
    (modify-syntax-entry ?!   "."      table)
    (modify-syntax-entry ?<   "."      table)
    (modify-syntax-entry ?>   "."      table)
    (modify-syntax-entry ?\\  "\\"     table)
    (modify-syntax-entry ?/   ". 124b" table)
    (modify-syntax-entry ?*   ". 23"   table)
    (modify-syntax-entry ?\n  "> b"    table)
    table)
  "Syntax table for `hare-ts-mode'.")

(defvar hare-ts-mode--indent-rules
  `((hare
     ((node-is "}") parent-bol 0)
     ((node-is "]") parent-bol 0)
     ((node-is ")") parent-bol 0)
     ((parent-is "sub_unit") column-0 0)
     ((parent-is "match_cases") parent-bol 0)
     ((parent-is "match_case") parent-bol hare-ts-mode-indent-offset)
     ((parent-is "switch_cases") parent-bol 0)
     ((parent-is "switch_case") parent-bol hare-ts-mode-indent-offset)
     ((parent-is "enum_type") parent-bol hare-ts-mode-indent-offset)
     ((parent-is "enum_values") parent-bol 0)
	 ((parent-is "struct_union_type") parent-bol hare-ts-mode-indent-offset)
	 ((parent-is "struct_literal") parent-bol hare-ts-mode-indent-offset)
     ((parent-is "bindings") parent-bol 0)
	 ((parent-is "binding_list") parent-bol hare-ts-mode-indent-offset)
	 ((parent-is "array_literal") parent-bol hare-ts-mode-indent-offset)
	 ((parent-is "tuple_literal") parent-bol hare-ts-mode-indent-offset)
     ((parent-is "declaration") parent-bol hare-ts-mode-indent-offset)
     ((parent-is "call_expression")  parent-bol hare-ts-mode-indent-offset)
     ((parent-is "member_list")  parent-bol hare-ts-mode-indent-offset)
     ((parent-is "argument_list")  parent-bol 0)
	 ((parent-is "expression_list") parent-bol 0)
     ((parent-is "compound_expression") parent-bol hare-ts-mode-indent-offset)
     (no-node parent-bol 0)))
  "Tree-sitter indent rules for `hare-ts-mode'.")

(defvar hare-ts-mode--keywords
  '("abort" "alloc" "append" "as" "assert" "bool" "break" "case"
	"const"  "continue" "def" "defer" "delete" "else" "enum"
	"export" "fn" "for" "free" "if" "is" "len" "let" "match"
	"nullable" "offset" "return" "size" "static" "struct" "switch"
	"true" "type" "union" "use" "yield")
  "Hare keywords for tree-sitter font-locking.")

(defvar hare-ts-mode--operators
  '("." "!" "~" "?" "*" "/" "%" "+" "-" "<<" ">>" "::" "<"
	"<=" ">" ">=" "==" "!=" "&" "|" "^" "&&" "||" "=" "+="
	"-=" "*=" "/=" "%=" "&=" "|=" "<<=" ">>=" "^=" "=>" )
  "Hare operators for tree-sitter font-locking.")

(defvar hare-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'hare
   :feature 'delimiter
   '([":" ";" "{" "}"] @font-lock-delimiter-face)

   :language 'hare
   :feature 'comment
   '((comment) @font-lock-comment-face)

   :language 'hare
   :feature 'function
   '((call_expression (postfix_expression) @font-lock-function-call-face))

   :language 'hare
   :feature 'definition
   '((function_declaration name: (identifier) @font-lock-function-name-face))

   :language 'hare
   :feature 'type
   '((_ (name) (type) @font-lock-type-face))

   :language 'hare
   :feature 'keyword
   `([,@hare-ts-mode--keywords] @font-lock-keyword-face)

   :language 'hare
   :feature 'number
   '([(floating_literal)
      (integer_literal)] @font-lock-number-face)

   :language 'hare
   :feature 'string
   '([(string_literal) (rune_literal)] @font-lock-string-face)

   :language 'hare
   :feature 'variable
   '((identifier) @font-lock-variable-use-face)

   :language 'hare
   :feature 'escape-sequence
   :override t
   '((escape_sequence) @font-lock-escape-face)

   :language 'hare
   :feature 'variable.parameter
   '((parameter (name) @font-lock-variable-name-face))

   :language 'hare
   :feature 'special
   '((["@symbol" "@fini" "@init"]) @font-lock-type-face)

   :language 'hare
   :feature 'error
   :override t
   '((ERROR) @font-lock-warning-face))
  "Tree-sitter font-lock settings for `hare-ts-mode'.")

;;;###autoload
(define-derived-mode hare-ts-mode prog-mode "Hare"
  "Major mode for editing hare, powered by tree-sitter.

\\{hare-ts-mode-map}"
  :group 'hare
  :syntax-table hare-ts-mode--syntax-table

  (when (treesit-ready-p 'hare)
    (treesit-parser-create 'hare)

    ;; Comments.
    (setq-local comment-start "// ")
    (setq-local comment-end "")
    (setq-local comment-start-skip (rx "//" (* (syntax whitespace))))

    ;; ;; Indent.
    (setq-local indent-tabs-mode t
				treesit-simple-indent-rules hare-ts-mode--indent-rules
				tab-width 8)

    ;; Electric
    (setq-local electric-indent-chars
                (append "{}()" electric-indent-chars))

    ;; Font-lock.
    (setq-local treesit-font-lock-settings hare-ts-mode--font-lock-settings)
    (setq-local treesit-font-lock-feature-list
                '(( comment )
                  ( keyword string type special)
                  ( escape-sequence number)
                  ( delimiter error function definition variable variable.parameter)))

    (treesit-major-mode-setup)))

(if (treesit-ready-p 'hare)
    (add-to-list 'auto-mode-alist '("\\.ha\\'" . hare-ts-mode)))

(provide 'hare-ts-mode)

;;; hare-ts-mode.el ends here
