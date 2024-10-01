;; extends

((identifier) @variable.builtin
  (#eq? @variable.builtin "self"))

"?" @operator.try
"unsafe" @keyword.rust.unsafe
["ref" "const" "static" "dyn" "extern" (mutable_specifier)] @storageclass
(lifetime "'" @attribute)

(scoped_identifier
  path: (identifier) @type
  name: (identifier) @constant
    (#match? @type "(^[A-Z]$|^[A-Z][a-zA-Z\d_]+)")
    (#match? @constant "(^[A-Z]$|^[A-Z\d_]+$)"))

(scoped_identifier
  path: (identifier) @type
  name: (identifier) @type.enum
    (#match? @type "(^[A-Z]$|^[A-Z][a-zA-Z\d_]+$)")
    (#match? @type.enum "(^[A-Z]$|^[A-Z][a-zA-Z\d_]+$)")
    (#match? @type.enum "[a-z]"))

(scoped_type_identifier
  path: (identifier) @type
  name: (type_identifier) @type.associated
    (#match? @type "(^[A-Z]$|^[A-Z][a-zA-Z\d_]+$)"))

(struct_expression
  name: (scoped_type_identifier
    path: (identifier) @type
    name: (type_identifier) @type.enum)
  body: (field_initializer_list))

(struct_pattern
  type: (scoped_type_identifier
    path: (identifier) @type
    name: (type_identifier) @type.enum))

(tuple_struct_pattern
  type: (scoped_identifier
    path: (identifier) @type
    name: (identifier) @type.enum))

(enum_item
  body: (enum_variant_list
    (enum_variant
      name: (identifier) @type.enum)))

(trait_bounds
  (type_identifier) @type.trait
    (#match? @type.trait "(^[A-Z]$|^[A-Z][a-zA-Z\d_]+$)")
    (#match? @type.trait "[a-z]"))

(trait_bounds
  (generic_type
    type: (type_identifier) @type.trait
      (#match? @type.trait "(^[A-Z]$|^[A-Z][a-zA-Z\d_]+$)")
      (#match? @type.trait "[a-z]")))

(attribute_item
  (attribute
    (identifier)
    arguments: (token_tree
      (identifier) @type.trait)
        (#match? @type.trait "(^[A-Z]$|^[A-Z][a-zA-Z\d_]+$)")
        (#match? @type.trait "[a-z]")))

(impl_item
  trait: (type_identifier) @type.trait)
