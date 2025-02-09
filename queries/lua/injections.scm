; extends

; --{{ if .os.isDarwin }}
; ...
; --{{ end }}
(comment
  content: (comment_content) @injection.content
  (#contains? @injection.content "{{" "}}")
  (#set! injection.language "gotmpl")
  (#set! injection.combined))

; local homebrewPrefix = "{{ .os.Posix.HomebrewPrefix }}"
(string
  content: (string_content) @injection.content
  (#contains? @injection.content "{{" "}}")
  (#set! injection.language "gotmpl")
  (#set! injection.combined))
