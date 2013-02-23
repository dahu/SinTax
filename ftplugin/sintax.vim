" Vim filetype plugin for filetype name.
" Maintainer:	Israel Chauca F. <israelchauca@gmail.com>
" Version:	0.1
" Description:	Long description.
" Last Change:	2013-02-22
" License:	Vim License (see :help license)
" Location:	ftplugin/sintax.vim
" Website:	https://github.com//sintax
"
" See sintax.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help sintax

let g:sintax_version = '0.1'

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another filetype plugin for this buffer
let b:did_ftplugin = 1

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" Restore things when changing filetype.
let b:undo_ftplugin = 'delcommand Sintax'

function! s:write_output(bang, path)
  let dest = !empty(a:path) ? a:path : expand('%:p:r') . '.vim'
  if empty(glob(dest)) || a:bang
    let lines = getline(1,'$')
    let options = {'document' : 0}
    call writefile(split(Sintax().parse(lines, options), "\n"), dest)
  else
    echohl ErrorMsg
    echom 'Sintax: A file already exists at ' . string(dest) . '. Add a bang (!) to overwrite it.'
    echohl Normal
  endif
endfunction

command! -buffer -bang -nargs=? Sintax call s:write_output(<bang>0, <q-args>)

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:

