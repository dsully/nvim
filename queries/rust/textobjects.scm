; extends

(call_expression
  function: (field_expression
    value: (_)
    "." @_start
    field: (field_identifier) @method.inner)
  arguments: (arguments) @method.outer)
