; extends

; #{{ if .os.isDarwin }}
; ...
; #{{ end }}
((comment) @injection.content
  (#set! injection.language "gotmpl")
  (#set! injection.combined))

; field = "{{ .os.Posix.HomebrewPrefix }}"
((string) @injection.content
  (#offset! @injection.content 0 -1 0 1)
  (#contains? @injection.content "{{" "}}")
  (#set! injection.language "gotmpl"))
