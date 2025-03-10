; extends

((command
  name: (command_name) @command
  redirect: (herestring_redirect
    (string) @injection.content))
  (#eq? @command "python3")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "python")
  (#set! injection.include-children))

; echo "
; local a = 1
; " > file.lua
(redirected_statement
  body: (command
    name: (command_name
      (word) @_cmd)
    argument: [
      (string)
      (raw_string)
    ] @injection.content)
  redirect: (file_redirect
    destination: (_) @injection.filename)
  (#eq? @_cmd echo)
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children))

; cat <<'EOF' > file.lua
; local a = 1
; EOF
(redirected_statement
  body: (_) @_cmd
  redirect: (heredoc_redirect
    redirect: (file_redirect
      destination: (_) @injection.filename)
    (heredoc_body) @injection.content)
  (#eq? @_cmd cat)
  (#set! injection.include-children))

; #{{ if .os.isDarwin }}
; ...
; #{{ end }}
((comment) @injection.content
  (#contains? @injection.content "{{" "}}")
  ; BUG: for some reason parser tries to parse a string inside a comment
  (#not-contains? @injection.content "chezmoi:template:")
  (#set! injection.language "gotmpl")
  (#set! injection.combined))

; source "{{ .os.Posix.HomebrewPrefix }}"
(string
  (string_content) @injection.content
  (#contains? @injection.content "{{" "}}")
  (#set! injection.language "gotmpl"))

((raw_string) @injection.content
  (#contains? @injection.content "{{" "}}")
  (#set! injection.language "gotmpl"))
