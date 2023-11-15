;; extends
;; Keywords
;;
(("return"   @keyword) (#set! conceal "󰌑"))

(("local"    @keyword) (#set! conceal "~"))

;; (("if"       @keyword) (#set! conceal "?"))
;; (("else"     @keyword) (#set! conceal "!"))
;; (("elseif"   @keyword) (#set! conceal "¿"))
(("function" @keyword) (#set! conceal ""))  ;;  "ﬦ"))
(("for"      @keyword) (#set! conceal ""))

;; (("and"      @keyword) (#set! conceal "▼"))
(("end"      @keyword) (#set! conceal "–"))
(("then"     @keyword) (#set! conceal "↙"))
(("do"       @keyword) (#set! conceal ""))

;; (("comment_start"    @comment) (#set! conceal "󰡡"))

;; Function names
((function_call name: (identifier) @TSFuncMacro (#eq? @TSFuncMacro "require")) (#set! conceal ""))
((function_call name: (identifier) @TSFuncMacro (#eq? @TSFuncMacro "print"  )) (#set! conceal " "))
((function_call name: (identifier) @TSFuncMacro (#eq? @TSFuncMacro "pairs"  )) (#set! conceal ""))
((function_call name: (identifier) @TSFuncMacro (#eq? @TSFuncMacro "ipairs" )) (#set! conceal ""))

;; table.
((dot_index_expression table: (identifier) @keyword  (#eq? @keyword  "math" )) (#set! conceal "󱖦"))

;; break_statement
(((break_statement) @keyword) (#set! conceal "󱞣"))

;; vim.*
(((dot_index_expression) @field (#eq? @field "vim.cmd"     )) (#set! conceal  "" ))
(((dot_index_expression) @field (#eq? @field "vim.api"     )) (#set! conceal ""))
(((dot_index_expression) @field (#eq? @field "vim.fn"      )) (#set! conceal ""))
(((dot_index_expression) @field (#eq? @field "vim.g"       )) (#set! conceal ""))
(((dot_index_expression) @field (#eq? @field "vim.schedule")) (#set! conceal "󰄉"))
(((dot_index_expression) @field (#eq? @field "vim.opt"     )) (#set! conceal "󰘵"))
(((dot_index_expression) @field (#eq? @field "vim.env"     )) (#set! conceal "$"))
(((dot_index_expression) @field (#eq? @field "vim.o"       )) (#set! conceal "O"))
(((dot_index_expression) @field (#eq? @field "vim.bo"      )) (#set! conceal ""))
(((dot_index_expression) @field (#eq? @field "vim.wo"      )) (#set! conceal ""))
(((dot_index_expression) @field (#eq? @field "vim.keymap.set")) (#set! conceal ""))
