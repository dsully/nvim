;; extends

; Python Requirements via https://github.com/otherJL0/tree-sitter-requirements/
(name) @namespace @nospell
(version) @float
(extra) @include
(comment) @comment
(url) @text.uri
(local_path) @text.uri
(version_cmp) @operator
; (env_var) @constant.macro

(option) @label

(str) @string

[ "," ";" ] @punctuation.delimiter
[ "[" "]" ] @punctuation.bracket
