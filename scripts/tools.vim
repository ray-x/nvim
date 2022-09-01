" Strip trailing whitespace and newlines on save
fun! <SID>StripTrailingWhitespace()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    %s/\($\n\s*\)\+\%$//e
    call cursor(l, c)
endfun
" autocmd BufWritePre * :call <SID>StripTrailingWhitespace()

" Search in project
function! FindProjectRoot(lookFor)
    let s:root=expand('%:p:h')
    let pathMaker='%:p'
    while(len(expand(pathMaker))>len(expand(pathMaker.':h')))
        let pathMaker=pathMaker.':h'
        let fileToCheck=expand(pathMaker).'/'.a:lookFor
        if filereadable(fileToCheck)||isdirectory(fileToCheck)
            let s:root=expand(pathMaker)
        endif
    endwhile
    return s:root
endfunction
" 搜索 .git 为项目路径

"https://github.com/sindrets/diffview.nvim/issues/105
" The last line in the command opens the local cwd for each window if you have
" a netrw-like explorer. Remove this line if you don't.
command! -bar -nargs=+ -complete=dir CompareDir
            \ tabnew | let t:paths = [<f-args>] | let t:compare_mode = 1 | vsp
            \ | silent exe '1windo lcd ' . t:paths[0] . ' | ' . ' 2windo lcd ' . t:paths[1]
            \ | windo exe 'exe "edit " . getcwd()'

augroup CompareDir
    au!
    au BufWinLeave * if get(t:, "compare_mode", 0) | diffoff | endif
    au BufEnter * if get(t:, "compare_mode", 0)
                \ |     if &bt ==# ""
                \ |         setl diff cursorbind scrollbind fdm=diff fdl=0
                \ |     else
                \ |         setl nodiff nocursorbind noscrollbind
                \ |     endif
                \ | endif
augroup END
command Jsonformat %!python -m json.tool
command Hex :%!xxd
" command! Jsonf :execute '%!python -c "import json,sys,collections,re; sys.stdout.write(re.sub(r\"\\\u[0-9a-f]{4}\", lambda m:m.group().decode(\"unicode_escape\").encode(\"utf-8\"),json.dumps(json.load(sys.stdin, object_pairs_hook=collections.OrderedDict), indent=2)))"'

function! FindRoot()
  let s:root = system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
  let s:list = ['go.mod', 'Makefile', 'CMakefile.txt', 'package.json']
  if len(s:root) == 0
    for k in s:list
      let s:root =  FindProjectRoot(k)
      if len(s:root) > 0
        return s:root
      endif
    endfor
  else
    return s:root
  endif
  return expand("%:p:h")
endfunction

" let g:root_dir = FindRoot() " Note disable root finder, null-ls will do this
" autocmd BufEnter * silent! lcd g:root_dir  " 设置当前路径为项目路径


" Protect large files from sourcing and other overhead.
" Files become read only
let g:LargeFile=1
if !exists("my_auto_commands_loaded")
  let my_auto_commands_loaded = 1
  " Large files are > 1M
  " Set options:
  " eventignore+=FileType (no syntax highlighting etc
  " assumes FileType always on)
  " noswapfile (save copy of file)
  " bufhidden=unload (save memory when other file is viewed)
  " buftype=nowrite (file is read-only)
  " undolevels=-1 (no undo possible)
  let g:LargeFile = 1024 * 1024 * 10
  augroup LargeFile
    autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) > g:LargeFile | set eventignore+=FileType | setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1 | else | set eventignore-=FileType | endif
    augroup END
  endif

command! Scratch new | setlocal bt=nofile bh=wipe nobl noswapfile nu

" let s:hidden_all = 0
" function! ToggleHiddenAll()
"     if s:hidden_all  == 0
"         let s:hidden_all = 1
"         set noshowmode
"         set noruler
"         set laststatus=0
"         set noshowcmd
"     else
"         let s:hidden_all = 0
"         set showmode
"         set ruler
"         set laststatus=2
"         set showcmd
"     endif
" endfunction

" nnoremap <Leader><S-h> :call ToggleHiddenAll()<CR>

" lfile loclist jump
function! LF()
    let temp = tempname()
    exec 'silent !lf -selection-path=' . shellescape(temp)
    if !filereadable(temp)
        redraw!
        return
    endif
    let names = readfile(temp)
    if empty(names)
        redraw!
        return
    endif
    exec 'edit ' . fnameescape(names[0])
    for name in names[1:]
        exec 'argadd ' . fnameescape(name)
    endfor
    redraw!
endfunction
command! -bar LF call LF()

""" internal wordcount
"function! WordCount()
"    let currentmode = mode()
"    if !exists("g:lastmode_wc")
"        let g:lastmode_wc = currentmode
"    endif
"    " if we modify file, open a new buffer, be in visual ever, or switch modes
"    " since last run, we recompute.
"    if &modified || !exists("b:wordcount") || currentmode =~? '\c.*v' || currentmode != g:lastmode_wc
"        let g:lastmode_wc = currentmode
"        let l:old_position = getpos('.')
"        let l:old_status = v:statusmsg
"        execute "silent normal g\<c-g>"
"        if v:statusmsg == "--No lines in buffer--"
"            let b:wordcount = 0
"        else
"            let s:split_wc = split(v:statusmsg)
"            if index(s:split_wc, "Selected") < 0
"                let b:wordcount =  str2nr(s:split_wc[11]) ..'w' .. str2nr(s:split_wc[13]) .. 'c'
"            else
"                let b:wordcount = str2nr(s:split_wc[5]) .. 'w' .. str2nr(s:split_wc[9]) .. 'c'
"            endif
"            let v:statusmsg = l:old_status
"        endif
"        call setpos('.', l:old_position)
"        return b:wordcount
"    else
"        return b:wordcount
"    endif
"endfunction



" Create a mapping (e.g. in your .vimrc) like this:

command! Bd bp\|bd \#

" inoremap (; (<CR>);<C-c>O
" inoremap (, (<CR>),<C-c>O
" inoremap {; {<CR>};<C-c>O
" inoremap {, {<CR>},<C-c>O
" inoremap [; [<CR>];<C-c>O
" inoremap [, [<CR>],<C-c>O
"auto close {
function! s:CloseBracket()
    let line = getline('.')
    if line =~# '^\s*\(struct\|class\|enum\) '
        return "{\<Enter>};\<Esc>O"
    elseif searchpair('(', '', ')', 'bmn', '', line('.'))
        " Probably inside a function call. Close it off.
        return "{\<Enter>});\<Esc>O"
    else
        return "{\<Enter>}\<Esc>O"
    endif
endfunction
inoremap <expr> {<Enter> <SID>CloseBracket()

" forma json" also :%!python3 -m json.tool


"""""""""""""""""""""""maximizer""""""""""""""""""""""""""""
fun! s:maximize()
    let t:maximizer_sizes = { 'before': winrestcmd() }
    vert resize | resize
    let t:maximizer_sizes.after = winrestcmd()
    normal! ze
endfun

fun! s:toggle(force)
    if exists('t:maximizer_sizes') && (a:force || (t:maximizer_sizes.after == winrestcmd()))
        call s:restore()
    elseif winnr('$') > 1
        call s:maximize()
    endif
endfun

fun! s:maximize()
    let t:maximizer_sizes = { 'before': winrestcmd() }
    vert resize | resize
    let t:maximizer_sizes.after = winrestcmd()
    normal! ze
endfun

fun! s:restore()
    if exists('t:maximizer_sizes')
        silent! exe t:maximizer_sizes.before
        if t:maximizer_sizes.before != winrestcmd()
            wincmd =
        endif
        unlet t:maximizer_sizes
        normal! ze
    end
endfun

augroup maximizer
    au!
    au WinLeave * call s:restore()
augroup END

command! -bang -nargs=0 -range MaximizerToggle :call s:toggle(<bang>0)
