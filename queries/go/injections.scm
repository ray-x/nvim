;; extends

; inject sql in single line strings
; e.g. db.GetContext(ctx, "SELECT * FROM users WHERE name = 'John'")

; ([
;   (interpreted_string_literal)
;   (raw_string_literal)
;   (raw_string_literal_content)
;   (interpreted_string_literal_content)
;   ] @injection.content
;  (#match? @injection.content "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).+(FROM|from|INTO|into|VALUES|values|SET|set).*(WHERE|where|GROUP BY|group by)?")
;  (#offset! @injection.content 0 1 0 -1)
; (#set! injection.language "sql"))
;
; (call_expression
;   (selector_expression
;     operand: (identifier)
;     field: (field_identifier) @_field)
;   (argument_list
;     (raw_string_literal (raw_string_literal_content) @sql)
;   (#any-of? @_field "Exec" "GetContext" "ExecContext" "SelectContext" "In"
; 				            "RebindNamed" "Rebind" "Query" "QueryRow" "QueryRowxContext" "NamedExec" "MustExec" "Get" "Queryx")
;   (#offset! @sql 0 1 0 -1)))

      ; (expression_statement ; [21, 1] - [21, 43]
      ;   (call_expression ; [21, 1] - [21, 43]
      ;     function: (selector_expression ; [21, 1] - [21, 8]
      ;       operand: (identifier) ; [21, 1] - [21, 3]
      ;       field: (field_identifier)) ; [21, 4] - [21, 8]
      ;     arguments: (argument_list ; [21, 8] - [21, 43]
      ;       (interpreted_string_literal ; [21, 9] - [21, 42]
      ;         (interpreted_string_literal_content))))) ; [21, 10] - [21, 41]
        (call_expression ; [21, 1] - [21, 43]
          (selector_expression ; [21, 1] - [21, 8]
            field: (field_identifier) @_field) ; [21, 4] - [21, 8]
          (argument_list ; [21, 8] - [21, 43]
              (interpreted_string_literal (interpreted_string_literal_content) @sql))
(#any-of? @_field "Exec" "GetContext" "ExecContext" "SelectContext" "In"
				            "RebindNamed" "Rebind" "Query" "QueryRow" "QueryRowxContext" "NamedExec" "MustExec" "Get" "Queryx")
  (#offset! @sql 0 1 0 -1)
              ) ; [21, 10] - [21, 41]


((call_expression
  (selector_expression
    field: (field_identifier) @_field (#any-of? @_field "Exec" "GetContext" "ExecContext" "SelectContext" "In" "RebindNamed" "Rebind" "Query" "QueryRow" "QueryRowxContext" "NamedExec" "MustExec" "Get" "Queryx"))
  (argument_list
    (interpreted_string_literal (interpreted_string_literal_content)) @injection.content))
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "sql"))

((call_expression
  (selector_expression
    field: (field_identifier) @_field)
  (argument_list
    (interpreted_string_literal (interpreted_string_literal_content) @sql)))
  (#any-of? @_field "Exec" "Query" "QueryRow" "NamedExec" "MustExec" "Get" "Queryx")
  (#offset! @sql 0 1 0 -1))

(call_expression
  (selector_expression
    field: (field_identifier) @_field)
  (argument_list
    (interpreted_string_literal (interpreted_string_literal_content) @sql)
  (#any-of? @_field "Exec" "GetContext" "ExecContext" "SelectContext" "In"
				            "RebindNamed" "Rebind" "Query" "QueryRow" "QueryRowxContext" "NamedExec" "MustExec" "Get" "Queryx")
  (#offset! @sql 0 1 0 -1)))


      ; (expression_statement ; [21, 1] - [21, 43]
      ;   (call_expression ; [21, 1] - [21, 43]
      ;     function: (selector_expression ; [21, 1] - [21, 8]
      ;       operand: (identifier) ; [21, 1] - [21, 3]
      ;       field: (field_identifier)) ; [21, 4] - [21, 8]
      ;     arguments: (argument_list ; [21, 8] - [21, 43]
      ;       (interpreted_string_literal ; [21, 9] - [21, 42]
      ;         (interpreted_string_literal_content))))) ; [21, 10] - [21, 41]

        ; (call_expression
        ;   function: (selector_expression
        ;     operand: (identifier)
        ;     field: (field_identifier))
        ;   arguments: (argument_list
        ;     (interpreted_string_literal
        ;       (interpreted_string_literal_content))))
