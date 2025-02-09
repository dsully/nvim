; extends

(variable_list
  name: (identifier) @variable.inner
  ","? @_end
  (#make-range! "variable.outer" @variable.inner @_end))
