; extends

; Inject CSS into template literals assigned to style.innerHTML
(assignment_expression
  left: (member_expression
    object: (identifier) @_obj
    property: (property_identifier) @_prop)
  right: (template_string
    (string_fragment) @injection.content)
  (#eq? @_prop "innerHTML")
  (#match? @_obj "[Ss]tyle")
  (#set! injection.language "css"))

; Handle template strings with interpolations
(assignment_expression
  left: (member_expression
    object: (identifier) @_obj
    property: (property_identifier) @_prop)
  right: (template_string) @injection.content
  (#eq? @_prop "innerHTML")
  (#match? @_obj "[Ss]tyle")
  (#set! injection.language "css")
  (#set! injection.combined))
