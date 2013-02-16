" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

syntax case ignore
syntax sync fromstart
syntax spell default
syntax region sintax_command_region start=/^\%(partial\|match\|keyword\|name\|case\|spell\)/ end=/\n\%(\n\|\S\|\%$\)\@=/ contains=sintax_name_line,sintax_case_line,sintax_spell_line,sintax_keyword_line,sintax_partial_line,sintax_match_line
syntax region sintax_command_region start=/^region/ end=/\n\%(\n\|\%(start\|skip\|end\)\@!\S\|\%$\)\@=/ contains=sintax_region_line,sintax_region_arg_line
syntax match sintax_region_cmd /^\%(start\|skip\|end\)\>/
syntax match sintax_name_line /^name\%(\n\%(\n\|\S\)\@!\|\s\)*\%(\<\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\)\?/ contained contains=sintax_command,sintax_syn_name,sintax_highlight
syntax match sintax_case_line /^case\%(\n\%(\n\|\S\)\@!\|\s\)*\%(\<\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\)\?/ contained contains=sintax_command,sintax_syn_name,sintax_highlight
syntax match sintax_spell_line /^spell\%(\n\%(\n\|\S\)\@!\|\s\)*\%(\<\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\)\?/ contained contains=sintax_command,sintax_syn_name,sintax_highlight
syntax match sintax_keyword_line /^keyword\%(\n\%(\n\|\S\)\@!\|\s\)*\%(\<\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\)\?\%(\.\%(\<\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\)\)\?\%(\%(contain\%(s\|ed\%(in\)\?\)\|oneline\|fold\|display\|extend\|conceal\%(ends\)\?\|cchar\|nextgroup\|transparent\|skip\%(white\|nl\|empty\)\)\%(=\S*\)\?\)*\%(\k\+\%(\n\%(\n\|\S\)\@!\|\s\)*\)*/ contained contains=sintax_command,sintax_syn_name,sintax_highlight,sintax_keyword
syntax match sintax_partial_line /^partial\%(\n\%(\n\|\S\)\@!\|\s\)*\%(\<\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\)\?\%(:\%(\n\%(\n\|\S\)\@!\|.\)\+\)\?/ contained contains=sintax_command,sintax_syn_name,sintax_highlight,sintax_pat
syntax match sintax_match_line /^match\%(\n\%(\n\|\S\)\@!\|\s\)*\%(\<\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\)\%(\.\%(\<\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\)\)\?\%(\%(\<\h[^:]*\)\?\)\%(:\%(\n\%(\n\|\S\)\@!\|.\)\+\)/ contained contains=sintax_command,sintax_syn_name,sintax_highlight,sintax_args,sintax_pat
syntax match sintax_region_line /^region\%(\n\%(\n\|\S\)\@!\|\s\)*\%(\<\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\)\%(\.\%(\<\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\)\)\%(\%(\<\h[^:]*\)\?\)/ contained contains=sintax_command,sintax_syn_name,sintax_highlight,sintax_args
syntax match sintax_region_arg_line /^\%(start\|skip\|end\)\>\%(\n\%(\n\|\S\)\@!\|\s\)*\%(:\%(\n\%(\n\|\S\)\@!\|.\)\+\)/ contained contains=sintax_command,sintax_syn_name,sintax_highlight,sintax_pat
syntax match sintax_keyword /\%(\k\+\%(\n\%(\n\|\S\)\@!\|\s\)*\)\+/ contained
syntax match sintax_command /^\h\w*/ contained
syntax match sintax_syn_name /\%(^\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)\+\)\@<=\h\w\+/ contained
syntax match sintax_highlight /\%(^\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)\+\h\w\+\%(\n\%(\n\|\S\)\@!\|\s\)\+\)\@<=\.\h\w*/ contained
syntax match sintax_args /\%(^\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)\+\%(\h\w\+\%(\n\%(\n\|\S\)\@!\|\s\)\+\)\%(\.\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)\+\)\?\)\@<=\%(\%(\%(\%(contain\%(s\|ed\%(in\)\?\)\|oneline\|fold\|display\|extend\|conceal\%(ends\)\?\|cchar\|nextgroup\|transparent\|skip\%(white\|nl\|empty\)\)\%(=\S*\)\?\)\)\%(\n\%(\n\|\S\)\@!\|\s\)*\)\+/ contained  contains=sintax_args_name
syntax match sintax_args_name /=\@<=\S\+/ contained contains=sintax_args_comma
syntax match sintax_args_comma /,/ contained
syntax match sintax_pat /\%(^\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\%(\h\w\+\%(\n\%(\n\|\S\)\@!\|\s\)*\)\?\%(\.\h\w*\%(\n\%(\n\|\S\)\@!\|\s\)*\)\?\%([^:]\+\)\?\)\@<=\%(:\%(\n\%(\n\|\S\)\@!\|.\)\+\)/ contained contains=sintax_comment
syntax match sintax_comment /\s\#\s*\S*$/ contained

hi def link sintax_keyword Special
hi def link sintax_command Identifier
hi def link sintax_syn_name PreProc
hi def link sintax_highlight Statement
hi def link sintax_args Type
hi def link sintax_args_name Normal
hi def link sintax_args_comma Type
hi def link sintax_pat String
hi def link sintax_comment Comment

let b:current_syntax = "sintax"

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:
