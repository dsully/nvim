; extends

((text) @injection.content
  (#inject-underlying-filetype! @injection.content)
  (#set! injection.combined))
