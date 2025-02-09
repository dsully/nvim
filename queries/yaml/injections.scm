; TODO: currently cannot be used in conjunction with 'gotmpl' that has injected 'yaml'
; ; extends
;
; ; #{{ if .os.isDarwin }}
; ; ...
; ; #{{ end }}
;
; ((comment) @injection.content
;   (#set! injection.language "gotmpl")
;   ; (#set! injection.combined)
; )
;
;
; ; field: "{{ .os.Posix.HomebrewPrefix }}"
; ([(single_quote_scalar) (double_quote_scalar)] @injection.content
;   (#contains? @injection.content "{{" "}}")
;   (#set! injection.language "gotmpl")
; )
;
;   ; field: |
;   ;   {{ if .os.Str }}
;   ;   someString
;   ;   {{ end }}
; ([(block_scalar)] @injection.content
;   (#offset! @injection.content -1 0 0 0)
;   (#contains? @injection.content "{{" "}}")
;   (#set! injection.language "gotmpl")
;   (#set! injection.combined)
; )
