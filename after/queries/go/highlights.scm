;; Keywords
(("return"   @keyword) (#set! conceal "﬋ "))
(("var"      @keyword) (#set! conceal  "כֿ"))
;; (("if"       @keyword) (#set! conceal "? "))
;; (("else"     @keyword) (#set! conceal "! "))
(("func"     @keyword) (#set! conceal ""))
(("for"      @keyword) (#set! conceal ""))
(("switch"   @keyword) (#set! conceal   "ﳟ"))
(("default"  @keyword) (#set! conceal  ""))
(("break"    @keyword) (#set! conceal  ""))
;; (("for"      @keyword) (#set! conceal  " "))
(("case"     @keyword) (#set! conceal  ""))
(("import"   @keyword) (#set! conceal  ""))
(("package"  @keyword) (#set! conceal  ""))
(("range"    @keyword) (#set! conceal ""))
(("chan"     @keyword) (#set! conceal ""))
(("continue" @keyword) (#set! conceal "↙"))
(("struct"   @keyword) (#set! conceal ""))
(("type"     @keyword) (#set! conceal ""))
(("interface"       @keyword) (#set! conceal ""))

;; Function names
((call_expression function: (identifier) @function (#eq? @function "append"  )) (#set! conceal " "))  ;;  

;; type
(((type_identifier) @type (#eq? @type "string")) (#set! conceal ""))
(((type_identifier) @type (#eq? @type "error")) (#set! conceal ""))

(((nil) @type (#set! conceal "ﳠ")))
;; fmt.*
(((selector_expression) @error (#eq? @error "fmt.Println"     )) (#set! conceal ""))
(((selector_expression) @error (#eq? @error "fmt.Printf"     )) (#set! conceal "狼"))
(((selector_expression) @field (#eq? @field "fmt.Sprintf"     )) (#set! conceal ""))
;; type
(((pointer_type) @type (#eq? @type "*testing.T")) (#set! conceal "τ"))
;; identifiers
(((identifier) @type (#eq? @type "err"     )) (#set! conceal "ε"))
;; (((identifier) @field (#eq? @field "fmt"     )) (#set! conceal ""))
