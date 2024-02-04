if exists('b:current_syntax')
  finish
endif

" https://linkedin.github.io/rest.li/pdl_schema

" Maybe syntax sync match would be faster for large files
syntax sync fromstart

syntax match pdlEscapedKeyword '\v`.*`'
highlight link pdlEscapedKeyword Identifier

syntax keyword pdlKeyword namespace import package includes typeref fixed
syntax keyword pdlKeyword optional
highlight link pdlKeyword Keyword

syntax keyword pdlStructure enum record
highlight link pdlStructure Structure

syntax keyword pdlType map array union
syntax keyword pdlType string boolean float double bytes int long
highlight link pdlType Type

syntax match pdlLineComment '\v\/\/.*$'
highlight link pdlLineComment Comment
syntax region  pdlMultilineComment start='\v\/\*' end='\v\*\/' fold
highlight link pdlMultilineComment Comment

syntax match pdlIdentifier '\v[a-zA-Z_][a-zA-Z0-9_]*'
highlight link pdlIdentifier Identifier

syntax region pdlString start='\v"' skip='\v\\.' end='\v"'
highlight link pdlString String

syntax match pdlInt '\v[0-9]+'
highlight link pdlInt Number

syntax match pdlFloat '\v[0-9]+\.[0-9]+'
highlight link pdlFloat Float

syntax match pdlEFloat '\v[0-9]+\.[0-9]+[Ee][0-9]+'
syntax match pdlEFloat '\v[0-9]+[Ee][0-9]+'
highlight link pdlEFloat Float

syntax keyword pdlBool true false
highlight link pdlBool Boolean

syntax match pdlProperty '\v\@\S+'
highlight link pdlProperty Identifier

let b:current_syntax = 'pdl'

" vim: set fdm=marker
