;; extends
;; Keywords
(("return"   @keyword) (#set! conceal ""))
(("var"      @keyword) (#set! conceal  "ν"))
;; (("if"       @keyword) (#set! conceal "? "))
;; (("else"     @keyword) (#set! conceal "! "))
(("func"     @keyword) (#set! conceal ""))
(("for"      @keyword) (#set! conceal ""))
(("switch"   @keyword) (#set! conceal "🎮"))
(("default"  @keyword) (#set! conceal  ""))
(("break"    @keyword.return) (#set! conceal  "⏹️"))
(("case"     @keyword) (#set! conceal  ""))
(("import"   @keyword) (#set! conceal  ""))
(("package"  @keyword) (#set! conceal  ""))
(("range"    @keyword) (#set! conceal ""))
(("chan"     @keyword) (#set! conceal ""))
(("continue" @keyword) (#set! conceal "↙"))
(("struct"   @keyword) (#set! conceal ""))
(("type"     @keyword) (#set! conceal ""))
(("interface"       @keyword) (#set! conceal "🦆"))
(("*"       @keyword) (#set! conceal "✳️"))

;; Function names
((call_expression function: (identifier) @function (#eq? @function "append"  )) (#set! conceal "匿"))  ;;  

;; type
(((type_identifier) @type (#eq? @type "string")) (#set! conceal ""))
(((type_identifier) @type (#eq? @type "error")) (#set! conceal ""))
(((type_identifier) @type (#eq? @type "int")) (#set! conceal "כֿ"))
(((type_identifier) @type (#eq? @type "byte")) (#set! conceal ""))
(((nil) @type (#set! conceal "🈳")))
(((true) @type (#set! conceal "")))
;; fmt.*
(((selector_expression) @error (#eq? @error "fmt.Println"     )) (#set! conceal ""))
(((selector_expression) @error (#eq? @error "fmt.Printf"     )) (#set! conceal "狼"))
(((selector_expression) @field (#eq? @field "fmt.Sprintf"     )) (#set! conceal ""))
;; type
(((qualified_type) @type (#eq? @type "testing.T")) (#set! conceal "τ"))
;; identifiers
(((identifier) @type (#eq? @type "err"     )) (#set! conceal "ε"))
(((identifier) @type (#eq? @type "errors"     )) (#set! conceal "é"))
(((identifier) @type (#eq? @type "request"     )) (#set! conceal "黎"))
(((identifier) @type (#eq? @type "Request"     )) (#set! conceal "黎"))
(((identifier) @type (#eq? @type "response"     )) (#set! conceal ""))
(((identifier) @type (#eq? @type "Response"     )) (#set! conceal ""))
(((identifier) @field (#eq? @field "Errorf"     )) (#set! conceal "🥹"))
(((identifier) @field (#eq? @field "assert"     )) (#set! conceal "🅰️"))
(((field_identifier) @field (#eq? @field "Error"     )) (#set! conceal "E"))
(((field_identifier) @field (#eq? @field "Equal"     )) (#set! conceal "🟰"))
;; (((identifier) @field (#eq? @field "fmt"     )) (#set! conceal ""))
