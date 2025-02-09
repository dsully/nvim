; extend
;
(command
  name: (word) @_cmd
  (#eq? @_cmd "printf")
  argument: (double_quote_string) @injection.content
  (#set! injection.include-children))
(#set! injection.language "printf")

; Inject gotmpl sections into fish
((comment) @injection.content
  (#set! injection.include-children)
  (#set! injection.language "gotmpl"))

((brace_expansion) @injection.content
  (#set! injection.include-children)
  (#set! injection.language "gotmpl"))

((double_quote_string) @injection.content
  (#set! injection.include-children)
  (#set! injection.language "gotmpl"))
