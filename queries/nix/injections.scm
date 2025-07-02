; pkgs.writeScript - dynamic language detection based on filename
(binding
  expression: (apply_expression
    function: (apply_expression
      function: (select_expression
        expression: (variable_expression
          name: (identifier) @_pkg
          (#eq? @_pkg "pkgs"))
        attrpath: (attrpath
          attr: (identifier) @_func
          (#eq? @_func "writeScript")))
      argument: (string_expression
        (string_fragment) @injection.language
        (#lua-match? @injection.language "%.%w+$")))
    argument: (indented_string_expression
      (string_fragment) @injection.content))
  (#gsub! @injection.language ".*%.(%w+)$" "%1")
  (#set! injection.combined))
