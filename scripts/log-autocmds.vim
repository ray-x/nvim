"https://github.com/lervag/dotnvim/blob/main/autoload/personal/log.vim
"print autocmd to a log
"
function! personal#log#clear() abort " {{{1
  call delete(s:logfile)
endfunction

" }}}1
function! personal#log#log(msg) abort " {{{1
  let l:time = strftime('%T', localtime())
  let l:file = expand('%')
  let l:line = line('.') . '-' . line("'\"")

  if empty(l:file)
    let l:string = printf('%s %s', l:time, a:msg)
  elseif empty(l:line)
    let l:string = printf('%s %s %s', l:time, l:file, a:msg)
  else
    let l:string = printf('%s %s:%s %s', l:time, l:file, l:line, a:msg)
  endif

  call writefile([l:string], s:logfile, 'a')
endfunction

" }}}1
function! personal#log#autocmd(cmd) abort " {{{1
  let l:log = a:cmd

  let l:parts = []
  for l:x in ['<abuf>', '<afile>', '<amatch>']
    let l:match = expand(l:x)
    if !empty(l:match)
      let l:parts += [l:x . '=' . l:match]
    endif
  endfor
  if !empty(l:parts)
    let l:log .= ': ' . join(l:parts, ' ')
  endif

  call personal#log#log(l:log)
endfunction

" }}}1
function! personal#log#autocmds() abort " {{{1
  augroup log_autocmds
    autocmd!
  augroup END

  let s:activate = get(s:, 'activate', 0) ? 0 : 1
  if !s:activate
    call personal#log#log('Stopped autocmd log')
    return
  endif

  call personal#log#log('Started autocmd log')
  augroup log_autocmds
    for l:au in s:aulist
      silent execute printf(
            \ 'autocmd %s * call personal#log#autocmd(''%s'')',
            \ l:au, l:au)
    endfor
  augroup END
endfunction

" These are deliberately left out due to side effects
" - SourceCmd
" - FileAppendCmd
" - FileWriteCmd
" - BufWriteCmd
" - FileReadCmd
" - BufReadCmd
" - FuncUndefined

let s:aulist = [
      \ 'BufNewFile',
      \ 'BufReadPre',
      \ 'BufRead',
      \ 'BufReadPost',
      \ 'FileReadPre',
      \ 'FileReadPost',
      \ 'FilterReadPre',
      \ 'FilterReadPost',
      \ 'StdinReadPre',
      \ 'StdinReadPost',
      \ 'BufWrite',
      \ 'BufWritePre',
      \ 'BufWritePost',
      \ 'FileWritePre',
      \ 'FileWritePost',
      \ 'FileAppendPre',
      \ 'FileAppendPost',
      \ 'FilterWritePre',
      \ 'FilterWritePost',
      \ 'BufAdd',
      \ 'BufCreate',
      \ 'BufDelete',
      \ 'BufWipeout',
      \ 'BufFilePre',
      \ 'BufFilePost',
      \ 'BufEnter',
      \ 'BufLeave',
      \ 'BufWinEnter',
      \ 'BufWinLeave',
      \ 'BufUnload',
      \ 'BufHidden',
      \ 'BufNew',
      \ 'SwapExists',
      \ 'FileType',
      \ 'Syntax',
      \ 'EncodingChanged',
      \ 'TermChanged',
      \ 'VimEnter',
      \ 'GUIEnter',
      \ 'GUIFailed',
      \ 'TermResponse',
      \ 'QuitPre',
      \ 'VimLeavePre',
      \ 'VimLeave',
      \ 'FileChangedShell',
      \ 'FileChangedShellPost',
      \ 'FileChangedRO',
      \ 'ShellCmdPost',
      \ 'ShellFilterPost',
      \ 'CmdUndefined',
      \ 'SpellFileMissing',
      \ 'SourcePre',
      \ 'VimResized',
      \ 'FocusGained',
      \ 'FocusLost',
      \ 'CursorHold',
      \ 'CursorHoldI',
      \ 'CursorMoved',
      \ 'CursorMovedI',
      \ 'WinEnter',
      \ 'WinLeave',
      \ 'TabEnter',
      \ 'TabLeave',
      \ 'CmdwinEnter',
      \ 'CmdwinLeave',
      \ 'InsertEnter',
      \ 'InsertChange',
      \ 'InsertLeave',
      \ 'InsertCharPre',
      \ 'TextChanged',
      \ 'TextChangedI',
      \ 'ColorScheme',
      \ 'RemoteReply',
      \ 'QuickFixCmdPre',
      \ 'QuickFixCmdPost',
      \ 'SessionLoadPost',
      \ 'MenuPopup',
      \ 'CompleteDone',
      \ 'User',
      \ ]

" }}}1

let s:logfile = '/tmp/nvim_personal_log'
