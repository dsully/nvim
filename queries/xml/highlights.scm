;; extends

; Also look at: https://github.com/CBenoit/helix/blob/0e5159ceca6be34977349156a32cc1a3ec53ab6e/runtime/queries/xml/highlights.scm#L4
(comment) @comment
(tag_name) @tag
(doctype) @constant

(attribute_name) @property
(attribute_value) @string

(entity_ref) @xml.ref
(char_ref) @xml.ref

(cdata) @cdata.data

["<" "</" ">" "<?" "?>" "/>" "="] @operator
