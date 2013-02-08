
" let [name, flavour, pattern] = ['', '', '']

let erex = ExtendedRegexObject('SinLookup')
function! SinLookup(name)
  " echo 'looking up ''' . a:name . ''''
  " echo get(g:p, a:name)
  return get(s:p, a:name)
endfunction

let s:p = {}
let s:p['word'] = '\%(\s\+\(\h\w\+\)\s*\)'
let s:p['optword'] = s:p['word'] . '\?'
let s:p['sintax_group_name'] = s:p['word']
let s:p['highlight'] = '\%(\.' . s:p['word'] . '\)\?'
let s:p['sinargs'] = '\([^:]*\)'
let s:p['sintax_args'] = s:p['sintax_group_name'] . s:p['highlight'] . s:p['sinargs'] . '\%(:\(.*\)\)\?'
let s:p['name_line'] = '^name' . s:p['word']
let s:p['case_line'] = '^case' . s:p['word']
let s:p['spell_line'] = '^spell' . s:p['word']
let s:p['keyword_line'] = '^keyword' . s:p['sintax_args']
let s:p['partial_line'] = '^partial' . s:p['sintax_group_name'] . '\(.*\)\?'
let s:p['match_line'] = '^match' . s:p['sintax_args']
let s:p['region_line'] = '^region' . s:p['sintax_args']
" let s:p['sintax_line'] = erex.parse(
"         \ '\%('
"         \ . join(
"         \   map(
"         \     ['name', 'case', 'spell', 'keyword', 'partial', 'match', 'region'],
"         \     '"\\%{" . v:val . "_line}"'),
"         \   '\)\|\%(')
"         \ . '\)')

function! Sintax(...)
  let sin = {}
  let sin.out = []

  func sin.prepare_output() dict
    let self.out = []
  endfunc

  func sin.passthrough(line) dict
    call extend(self.out, [a:line])
  endfunction

  func sin.matches(string, pattern_name) dict
    let p = SinLookup(a:pattern_name)
    " echo 'matches(' . a:string . ', ' . p . ')'
    return match(a:string, SinLookup(a:pattern_name)) != -1
  endfunc

  func sin.matchlist(string, pattern_name) dict
    let p = SinLookup(a:pattern_name)
    " echo 'matchlist(' . a:string . ', ' . p . ')'
    return matchlist(a:string, SinLookup(a:pattern_name))
  endfunc

  func sin.is_sin_line(line) dict
    let matched = 0
    for t in ['name', 'case', 'spell', 'keyword', 'partial', 'match', 'region']
      if self.matches(a:line, t . '_line')
        let matched = 1
        break
      endif
    endfor
    return matched
  endfunc

  func sin.is_blank_or_comment(line)
    return a:line =~ '^\s*\("\|$\)'
  endfunc

  func sin.parse(file) dict
    call self.prepare_output()
    let self.input = readfile(a:file)
    let self.curline = 0
    let self.eof = len(self.input)
    while self.curline < self.eof
      let line = self.input[self.curline]
      " pass through blank, comment and explicit vim lines
      if self.is_blank_or_comment(line) || (! self.is_sin_line(line))
        call self.passthrough(line)
        let self.curline += 1
        continue
      else
        call self.process(line)
      endif
    endwhile
    return self.output()
  endfunc

  " process a (single or multiline) sintax block
  func sin.process(line) dict
    " non multiline patterns must be flush to first column
    let line = a:line
    " call self.passthrough('----------')
    " TODO: ensure comment lines don't interfere
    while self.curline < self.eof
      " return to outer level parser on blank or comment-only lines
      if self.is_blank_or_comment(line)
        break
      endif
      " TODO: testing only
      call self.passthrough(line)
      let self.curline += 1
      let line = self.input[self.curline]
      " return to outer level parser if input is back at the left edge
      if line =~ '^\S'
        break
      endif
    endwhile
  endfunc

  func sin.output() dict
    return join(self.out, "\n")
  endfunc

  " process constructor

  return sin
endfunc

" test

let sinner = Sintax()
echo sinner.parse('zuishui_2.zs')

finish

echo "---- Tests ----"

function! TestLine(line, pattern)
  let sinner = Sintax()
  if sinner.matches(a:line, a:pattern)
    echohl Title
    echo "Ok"
    echohl None
    echo sinner.matchlist(a:line, a:pattern)
  else
    echohl Error
    echo "Failed to match:\n  --> " . a:line . "\nwith: " . a:pattern
    echohl None
  endif
endfunction


call TestLine('name    vrs', 'name_line')
call TestLine('case    ignore', 'case_line')
call TestLine('spell   default', 'spell_line')

call TestLine('keyword vrsTodo    .Todo : TODO FIXME XXX', 'keyword_line')
call TestLine("keyword vrsTodo    .Todo\n TODO FIXME XXX", 'keyword_line')

call TestLine('partial token \S\+\s\+', 'partial_line')
call TestLine("partial token\n \%(\n      \\}          # an escaped \}\n    \|             # or\n      [^}]         # anything but a }\n    \)", 'partial_line')

call TestLine('match vrsNameErr   .Error      contained : ^\%{token}', 'match_line')
call TestLine("match vrsNameErr   .Error      contained\n ^\%{token}", 'match_line')


call TestLine('match vrsNameErr   .Error      contained : ^\%{token}', 'match_line')
call TestLine("match vrsNameErr   .Error      contained\n ^\%{token}", 'match_line')

