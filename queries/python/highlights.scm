; Reset highlighting in f-string interpolations
(interpolation) @none

((identifier) @constant
 (#lua-match? @constant "^[A-Z][A-Z_0-9]*$"))

((identifier) @constant.builtin
  ; format-ignore
  (#any-of? @constant.builtin
    ; https://docs.python.org/3/library/constants.html
    "NotImplemented" "Ellipsis"
    "quit" "exit" "copyright" "credits" "license"
    "__name__" "__module__"
  ))

"_" @constant.builtin ; match wildcard

; Literals
(none) @constant.builtin
[(true) (false)] @boolean
((identifier) @variable.builtin
  (#eq? @variable.builtin "self"))
((identifier) @variable.builtin
  (#eq? @variable.builtin "cls"))
(integer) @number
(float) @number.float

(comment) @comment @spell
(string) @string @spell
[(escape_sequence) (escape_interpolation)] @string.escape

; doc-strings
(module
  .
  (comment)*
  .
  (expression_statement
    (string) @string.documentation @spell))
(class_definition
  body:
    (block
      .
      (expression_statement
        (string) @string.documentation @spell)))
(function_definition
  body:
    (block
      .
      (expression_statement
        (string) @string.documentation @spell)))


; Decorators
(decorator
  [
    ; (call function: (attribute) @function.macro)
    (identifier) @function.macro
    (attribute) @function.macro
    (call (attribute) @function.macro)
    (call (identifier) @function.macro)
  ]
)

; Builtin functions
((call
  function: (identifier) @function.builtin)
  (#any-of? @function.builtin
    "bytes" "str" "int" "float" "bool" "object" "frozenset" "set" "tuple" "list" "dict" "type"
    "abs" "all" "any" "ascii" "bin" "breakpoint" "bytearray"
    "callable" "chr" "classmethod" "compile" "complex" "delattr" "dir"
    "divmod" "enumerate" "eval" "exec" "filter" "format"
    "getattr" "globals" "hasattr" "hash" "help" "hex" "id" "input" "isinstance"
    "issubclass" "iter" "len" "locals" "map" "max" "memoryview" "min"
    "next" "oct" "open" "ord" "pow" "print" "property" "range" "repr"
    "reversed" "round" "setattr" "slice" "sorted" "staticmethod"
    "sum" "super" "vars" "zip" "__import__"
  ))

((identifier) @type
 (#any-of? @type
    "bytes" "str" "int" "float" "bool" "object" "frozenset" "set" "tuple" "list" "dict" "type"
 ))

;; Function definitions
(function_definition
  name: (identifier) @function)

(call
  function: (identifier) @function.call)

((call
  function: (identifier) @_isinstance
  arguments: (argument_list
    (_)
    (identifier) @type))
  (#eq? @_isinstance "isinstance"))

; Normal parameters
(parameters
  (identifier) @variable.parameter)

; Lambda parameters
(lambda_parameters
  (identifier) @variable.parameter)

(lambda_parameters
  (tuple_pattern
    (identifier) @variable.parameter))

; Default parameters
(keyword_argument
  name: (identifier) @variable.parameter)

; Naming parameters on call-site
(default_parameter
  name: (identifier) @variable.parameter)

(typed_parameter
  (identifier) @variable.parameter)

(typed_default_parameter
  name: (identifier) @variable.parameter)

; Variadic parameters *args, **kwargs
(parameters
  (list_splat_pattern ; *args
    (identifier) @variable.parameter))

(parameters
  (dictionary_splat_pattern ; **kwargs
    (identifier) @variable.parameter))

; Typed variadic parameters
(parameters
  (typed_parameter
    (list_splat_pattern ; *args: type
      (identifier) @variable.parameter)))

(parameters
  (typed_parameter
    (dictionary_splat_pattern ; *kwargs: type
      (identifier) @variable.parameter)))

; Lambda parameters
(lambda_parameters
  (list_splat_pattern
    (identifier) @variable.parameter))

(lambda_parameters
  (dictionary_splat_pattern
    (identifier) @variable.parameter))


; Tokens

[
  "-"
  "-="
  ":="
  "!="
  "*"
  "**"
  "**="
  "*="
  "/"
  "//"
  "//="
  "/="
  "&"
  "&="
  "%"
  "%="
  "^"
  "^="
  "+"
  "+="
  "<"
  "<<"
  "<<="
  "<="
  "<>"
  "="
  "=="
  ">"
  ">="
  ">>"
  ">>="
  "|"
  "|="
  "~"
  "->"
] @operator

; Keywords
["and" "in" "is" "not" "or" "is not" "not in" "del" "@"] @keyword.operator
["def" "lambda"] @keyword.function
["assert" "class" "exec" "global" "nonlocal" "pass" "print" "with" "as" "type"] @keyword
["async" "await"] @keyword.coroutine
["return" "yield"] @keyword.return
(yield "from" @keyword.return)

(future_import_statement
  "from" @keyword.import
  "__future__" @constant.builtin)
(import_from_statement
  "from" @keyword.import)
"import" @keyword.import
(aliased_import
  "as" @keyword.import)

["if" "elif" "else" "match" "case"] @keyword.conditional

["for" "while" "break" "continue"] @keyword.repeat

["try" "except" "except*" "raise" "finally"] @keyword.exception

(raise_statement
  "from" @keyword.exception)
(try_statement
  (else_clause
    "else" @keyword.exception))

; Exceptions
((identifier) @type.builtin
  ; format-ignore
  (#any-of? @type.builtin
    ; https://docs.python.org/3/library/exceptions.html
    "BaseException" "Exception" "ArithmeticError" "BufferError" "LookupError" "AssertionError" "AttributeError"
    "EOFError" "FloatingPointError" "GeneratorExit" "ImportError" "ModuleNotFoundError" "IndexError" "KeyError"
    "KeyboardInterrupt" "MemoryError" "NameError" "NotImplementedError" "OSError" "OverflowError" "RecursionError"
    "ReferenceError" "RuntimeError" "StopIteration" "StopAsyncIteration" "SyntaxError" "IndentationError" "TabError"
    "SystemError" "SystemExit" "TypeError" "UnboundLocalError" "UnicodeError" "UnicodeEncodeError" "UnicodeDecodeError"
    "UnicodeTranslateError" "ValueError" "ZeroDivisionError" "EnvironmentError" "IOError" "WindowsError"
    "BlockingIOError" "ChildProcessError" "ConnectionError" "BrokenPipeError" "ConnectionAbortedError"
    "ConnectionRefusedError" "ConnectionResetError" "FileExistsError" "FileNotFoundError" "InterruptedError"
    "IsADirectoryError" "NotADirectoryError" "PermissionError" "ProcessLookupError" "TimeoutError" "Warning"
    "UserWarning" "DeprecationWarning" "PendingDeprecationWarning" "SyntaxWarning" "RuntimeWarning"
    "FutureWarning" "ImportWarning" "UnicodeWarning" "BytesWarning" "ResourceWarning"
))
; (raise_statement
;   [
;     (call (identifier) @keyword.exception)
;   ]
; )


["(" ")" "[" "]" "{" "}"] @punctuation.bracket

; (interpolation
;   "{" @punctuation.special
;   "}" @punctuation.special)

(type_conversion) @function.macro

["," "." ":"] @punctuation.delimiter

(ellipsis) @punctuation.special


;; Type Hint
(type
  (identifier) @type)
(type
  (subscript
    (identifier) @type)) ; type subscript: Tuple[int]

((assignment
  left: (identifier) @type.definition
  (type
    (identifier) @_annotation))
  (#eq? @_annotation "TypeAlias"))

((assignment
  left: (identifier) @type.definition
  right: (call
    function: (identifier) @_func))
  (#any-of? @_func "TypeVar" "NewType"))

;; Class definitions
(class_definition
  name: (identifier) @type)

(class_definition
  body: (block
    [
      (function_definition name: (identifier) @function.method)
      (decorated_definition (function_definition (identifier) @function.method))
    ]
  )
)
(class_definition
  superclasses:
    (argument_list
      (identifier) @type))

((class_definition
  body:
    (block
      (expression_statement
        (assignment
          left: (identifier) @variable.member))))
  (#lua-match? @variable.member "^[%l_].*$"))

((class_definition
  body:
    (block
      (expression_statement
        (assignment
          left:
            (_
              (identifier) @variable.member)))))
  (#lua-match? @variable.member "^[%l_].*$"))

((class_definition
  (block
    (function_definition
      name: (identifier) @constructor)))
 (#any-of? @constructor "__new__" "__init__"))

((attribute
    attribute: (identifier) @field)
 (#vim-match? @field "^([A-Z])@!.*$"))


; Regex from the `re` module
(call
  function:
    (attribute
      object: (identifier) @_re)
  arguments:
    (argument_list
      .
      (string
        (string_content) @string.regexp))
  (#eq? @_re "re"))
