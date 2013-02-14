call vimtest#StartTap()
call vimtap#Plan(2) " <== XXX  Keep plan number updated.  XXX

let sinner = Sintax()
let input = [
      \ 'partial foo single_line',
      \ 'partial bar \n  multi\n  line'    " should this have a : in it?
      \]
call sinner.parse(input)

call vimtap#Is(sinner.lookup('foo'), 'single_line', 'single line partial')
call vimtap#Is(sinner.lookup('bar'), '\nmulti\nline', 'multi line partial')

call vimtest#Quit()
