; extends

; All chezmoi template functions
(function_call
  function: (identifier) @function.builtin
  (#set! priority 130)
  (#any-of? @function.builtin
    "awsSecretsManager" "awsSecretsManagerRaw" "bitwarden" "bitwardenAttachment" "bitwardenFields"
    "comment" "completion" "decrypt" "encrypt" "eqFold" "exit" "fromIni" "fromToml" "fromYaml"
    "gitHubKeys" "gitHubLatestRelease" "gitHubLatestTag" "glob" "gopass" "gopassRaw" "hexDecode"
    "hexEncode" "include" "includeTemplate" "ioreg" "joinPath" "keepassxc" "keepassxcAttachment"
    "keepassxcAttribute" "keeper" "keeperDataFields" "keeperFindPassword" "keyring" "lastpass"
    "lastpassRaw" "lookPath" "lstat" "mozillaInstallHash" "onepassword" "onepasswordDetailsFields"
    "onepasswordDocument" "onepasswordItemFields" "onepasswordRead" "output" "pass" "passFields"
    "passRaw" "passhole" "promptBool" "promptBoolOnce" "promptInt" "promptIntOnce" "promptString"
    "promptStringOnce" "quote" "quoteList" "replaceAllRegex" "secret" "secretJSON" "setValueAtPath"
    "sha256sum" "stat" "stdinIsATTY" "toIni" "toToml" "toYaml" "vault" "writeToStdout"))

; Template variables
((variable) @variable
  (#set! priority 130))

; Template operators
("|" @operator
  (#set! priority 130))

; Template literals
([
  (interpreted_string_literal)
  (raw_string_literal)
] @string
  (#set! priority 130))

; Comments with template syntax
((comment) @comment
  (#set! priority 130))
