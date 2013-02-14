" Vim filetype detect plugin for filetype name.
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" 		Israel Chauca F. <israelchauca@gmail.com>
" Version:	0.1
" Description:	Long description.
" Last Change:	2013-02-09
" License:	Vim License (see :help license)
" Location:	ftdetect/sintax.vim
" Website:	https://github.com/dahu/sintax
"
" See sintax.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help sintax

let g:sintax_version = '0.1'

au BufRead,BufNewFile *.sintax	set filetype=sintax
