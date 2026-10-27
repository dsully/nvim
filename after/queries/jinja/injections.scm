; extends

((content) @injection.content
  (#inject-underlying-filetype! @injection.content)
  (#set! injection.combined))
