
let erex = ExtendedRegexObject('SinLookup')
function! SinLookup(name)
  " echo 'looking up ''' . a:name . ''''
  return get(s:p, a:name)
endfunction

let s:p = {}
let s:p['word'] = '\%(\s*\(\h\w\+\)\s*\)'
let s:p['optword'] = s:p['word'] . '\?'
let s:p['sintax_group_name'] = s:p['word']
let s:p['highlight'] = '\%(\.' . s:p['word'] . '\)\?'
let s:p['sinargs'] = '\([^:]*\)'
let s:p['sintax_args'] = s:p['sintax_group_name'] . s:p['highlight'] . s:p['sinargs'] . '\%(:\(.*\)\)\?'
let s:p['name_line'] = '^name\s\+' . s:p['word']
let s:p['case_line'] = '^case\s\+' . s:p['word']
let s:p['spell_line'] = '^spell\s\+' . s:p['word']
let s:p['keyword_line'] = '^keyword\s\+' . s:p['sintax_args']
let s:p['partial_line'] = '^partial\s\+' . s:p['sintax_group_name'] . '\(.*\)\?'
let s:p['match_line'] = '^match\s\+' . s:p['sintax_args']
let s:p['region_line'] = '^region\s\+' . s:p['sintax_args']

function! Sintax(...)
  let sin = {}
  let sin.out = []
  let sin.highlights = []
  let sin.patterns = {}
  let sin.sinline = []
  let sin.preamble = join([
        \  ''
        \ ,'" Quit when a (custom) syntax file was already loaded'
        \ ,'if exists("b:current_syntax")'
        \ ,'  finish'
        \ ,'endif'
        \ ,''
        \ ,'" Allow use of line continuation.'
        \ ,'let s:save_cpo = &cpo'
        \ ,'set cpo&vim'
        \ ,''], "\n")
  let sin.postamble = join([
        \  'let b:current_syntax = "%name"'
        \ ,''
        \ ,'let &cpo = s:save_cpo'
        \ ,'unlet s:save_cpo'
        \ ,''
        \ ,'" vim: set sw=2 sts=2 et fdm=marker:'], "\n")

  func sin.lookup(name) dict
    " echo 'looking up name="' . a:name . '", value="' . get(self.patterns, a:name) . '"'
    return get(self.patterns, a:name)
  endfunc

  let sin.erex = ExtendedRegexObject(eval('sin.lookup'), sin)

  func sin.prepare_output() dict
    let self.out = []
  endfunc

  func sin.passthrough(line) dict
    call extend(self.out, [a:line])
  endfunction

  func sin.matches(string, pattern_name) dict
    let p = SinLookup(a:pattern_name)
    return match(a:string, SinLookup(a:pattern_name)) != -1
  endfunc

  func sin.matchlist(string, pattern_name) dict
    let p = SinLookup(a:pattern_name)
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
        if line != ''
          call self.passthrough(line)
        endif
        let self.curline += 1
        continue
      else
        call self.process(line)
      endif
    endwhile
    return self.output()
  endfunc

  func sin.warn(msg) dict
    echohl Warning
    echo "Warning: " . a:msg
    echohl None
  endfunc

  func sin.process_name(line) dict
    let [_, name ;__] = matchlist(a:line, SinLookup('name_line'))
    let self.postamble = substitute(self.postamble, '%name', name, 'g')
    return []
  endfunc

  func sin.process_case(line) dict
    let [_, case ;__] = matchlist(a:line, SinLookup('case_line'))
    if case !~# 'match\|ignore'
      self.warn("Unknown 'case' argument : " . case)
    endif
    return ['syntax case ' . case]
  endfunc

  func sin.process_spell(line) dict
    let [_, spell ;__] = matchlist(a:line, SinLookup('spell_line'))
    if spell !~# 'toplevel\|notoplevel\|default'
      self.warn("Unknown 'spell' argument : " . case)
    endif
    return ['syntax spell ' . spell]
  endfunc

  func sin.process_sinargs(line) dict
    let [_, _, name, highlight, args, pattern ;__] = matchlist(a:line, '^\(\w\+\)' . SinLookup('sintax_args'))
    if pattern == ''
      let pattern = escape(self.erex.parse(join(a:line[1:-1])), '/')
    else
      let pattern = escape(self.erex.parse(pattern), '/')
    endif
    return [name, highlight, args, pattern]
  endfunc

  func sin.highlight(name, link) dict
    if a:link != ''
      call extend(self.highlights, ['hi def link ' . a:name . ' ' . a:link])
    endif
  endfunc

  func sin.process_keyword(line) dict
    let [_, _, name, highlight, args, pattern ;__] = matchlist(a:line, '^\(\w\+\)' . SinLookup('sintax_args'))
    call self.highlight(name, highlight)
    return ['syntax keyword ' . join([name, pattern, args], ' ')]
  endfunc

  func sin.process_partial(line) dict
    let [_, name, pattern ;__] = matchlist(a:line, SinLookup('partial_line'))
    if pattern == ''
      let pattern = escape(self.erex.parse(join(a:line[1:-1])), '/')
    else
      let pattern = escape(self.erex.parse(pattern), '/')
    endif
    let self.patterns[name] = pattern
    return []
  endfunc

  func sin.process_match(line) dict
    let [name, highlight, args, pattern] = self.process_sinargs(a:line)
    call self.highlight(name, highlight)
    let self.patterns[name] = pattern
    return ['syntax match ' . name . ' /' . pattern . '/ ' . args]
  endfunc

  " TODO: get region working
" let s:p['match_line'] = '^match\s\+' . s:p['sintax_args']
" let s:p['sintax_args'] = s:p['sintax_group_name'] . s:p['highlight'] . s:p['sinargs'] . '\%(:\(.*\)\)\?'
  func sin.process_region(line) dict
    let [name, highlight, args, pattern] = self.process_sinargs(a:line)
    call self.highlight(name, highlight)
    return ['syntax region ' . name . ' /' . pattern . '/ ' . args]
  endfunc

  func sin.process_sintax_block()
    let type = matchstr(self.sinline[0], '^\w\+')
    return call(eval('self.process_' . type), [self.sinline], self)
  endfunc

  func sin.flush_old_sintax_line()
    if ! empty(self.sinline)
      let output = self.process_sintax_block()
      if ! empty(output)
        call extend(self.out, output)
      endif
    else
      "TODO: this should probably be in a method of its own for logical separation
      " prepend the preamble before processing the first sintax line
      call extend(self.out, [self.preamble])
    endif
  endfunc

  func sin.prepare_sintax_line() dict
    call self.flush_old_sintax_line()
    let self.sinline = []
  endfunc

  func sin.append_sintax(line) dict
    call extend(self.sinline, [a:line])
  endfunc

  " process a (single or multiline) sintax block
  func sin.process(line) dict
    call self.prepare_sintax_line()
    " non multiline patterns must be flush to first column
    let line = a:line
    " TODO: ensure comment lines don't interfere
    while self.curline < self.eof
      " return to outer level parser on blank or comment-only lines
      if self.is_blank_or_comment(line)
        break
      endif
      call self.append_sintax(line)
      " are we still in the same sintax block?
      let self.curline += 1
      if self.curline >= self.eof
        break
      endif
      let line = self.input[self.curline]
      " return to outer level parser if input is back at the left edge
      if line =~ '^\S'
        break
      endif
    endwhile
  endfunc

  func sin.output() dict
    call self.flush_old_sintax_line()
    let inner = join(self.out, "\n")
    let highlights = join(self.highlights, "\n")
    return join([inner, highlights, self.postamble], "\n\n")
  endfunc

  " process constructor

  return sin
endfunc

" test

let sinner = Sintax()
echo sinner.parse('vrs.sintax')

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

