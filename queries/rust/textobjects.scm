;; extends

((call_expression
  function: (field_expression
    value: (_) "." @_start
    field: (field_identifier) @method.inner)
  arguments: (arguments) @_end)
  (#make-range! "method.outer" @_start @_end))
