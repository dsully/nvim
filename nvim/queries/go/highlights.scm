;; extends

(raw_string_literal) @string @nospell
((interpreted_string_literal) @nospell
	(#not-has-parent? @nospell
		import_spec
	)
)
