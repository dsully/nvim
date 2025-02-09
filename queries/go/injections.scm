; extends

; ; pool.Exec(ctx, `SELECT * x;`)
; ;
; ((call_expression
;   function: (selector_expression
;     field: (field_identifier) @_method)
;   arguments: (argument_list
;     (_)
;     .
;     (raw_string_literal) @injection.content))
;   (#any-of? @_method "Exec" )
;   (#set! injection.language "sql")
;   (#set! injection.include-children)
;   (#offset! @injection.content 0 1 0 -1)
; )
; SQL injections
((comment) @_comment
  [
    (interpreted_string_literal)
    (raw_string_literal)
  ] @injection.content
  (#any-contains? @_comment "sql" "Sql" "SQL")
  (#set! injection.language "sql")
  (#set! injection.include-children)
  (#offset! @injection.content 0 1 0 -1))

([
  (interpreted_string_literal)
  (raw_string_literal)
] @injection.content
  (#any-contains? @injection.content "sql" "Sql" "SQL")
  (#set! injection.language "sql")
  (#set! injection.include-children)
  (#offset! @injection.content 0 1 0 -1))

; json injections
([
  (interpreted_string_literal)
  (raw_string_literal)
] @injection.content
  (#any-match? @injection.content "\".*\": \".*\"")
  (#set! injection.language "json")
  (#set! injection.include-children)
  (#offset! @injection.content 0 1 0 -1))

((comment) @_comment
  [
    (interpreted_string_literal)
    (raw_string_literal)
  ] @injection.content
  (#any-match? @injection.content "\".*\": \".*\"")
  (#set! injection.language "json")
  (#set! injection.include-children)
  (#offset! @injection.content 0 1 0 -1))

((comment) @_comment
  [
    (interpreted_string_literal)
    (raw_string_literal)
  ] @injection.content
  (#any-match? @injection.content "\".*\": \".*\"")
  (#set! injection.language "json5")
  (#set! injection.include-children)
  (#offset! @injection.content 0 1 0 -1))

((comment) @_comment
  [
    (interpreted_string_literal)
    (raw_string_literal)
  ] @injection.content
  (#any-match? @injection.content "\".*\": \".*\"")
  (#set! injection.language "jsonc")
  (#set! injection.include-children)
  (#offset! @injection.content 0 1 0 -1))
