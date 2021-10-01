set encoding=utf-8
"" Note: vim only, neovim use init.lua

if &compatible
  set nocompatible
endif
" Add the dein installation directory into runtimepath
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim


if has('nvim')
  finish
  let s:config_home = stdpath('config')
else
  let s:config_home = '~/.config/nvim'
endif

" Set python/ruby interpreter path

if has('mac')
  let s:brew_prefix = '/usr/local'
elseif executable('brew')
  let s:brew_prefix = systemlist('brew --prefix')[0]
endif


"""""""""""""" dein Plugins"""""""""""""""""""""
let g:dein#install_max_processes = 16
command! Dc :call dein#recache_runtimepath()
command! Du :call dein#update()

"""""""""""""" Packer Plugins"""""""""""""""""""""

" command! Gt :lua require('selfunc').float_terminal()


"""""""""""""" Packer Plugins"""""""""""""""""""""

" lua require('plugins')
" command! PackerInstall packadd packer.nvim | lua require('plugins').install()
" command! PackerUpdate packadd packer.nvim | lua require('plugins').update()
" command! PackerSync packadd packer.nvim | lua require('plugins').sync()
" command! PackerClean packadd packer.nvim | lua require('plugins').clean()
" command! PackerCompile packadd packer.nvim | lua require('plugins').compile()
""""""""""""""Plugins"""""""""""""""""""""

filetype plugin indent on

autocmd StdinReadPre * let s:std_in=1


""""""""""""""""""""""
"      Settings      "
""""""""""""""""""""""
"" see options.lua
set nocompatible  " nvim is always nocompatible, vim only
set termguicolors
set noshowmode                  " We show the mode with airline or lightline

" lua vim.wo options
" set foldmethod=indent
" set signcolumn=yes/auto
" set list
" set concealcursor=niv

" set nocursorcolumn              " (turn off to speeds up highlighting)
" set nocursorline                " (turn off speeds up highlighting)
set lazyredraw                  " Wait to redraw
" au FocusGained,BufEnter * :checktime  " autoload

" augroup vimrc
"   autocmd!
"    autocmd BufWinEnter,Syntax * syn sync minlines=200 maxlines=200
" augroup END

syntax sync minlines=256
syntax on
set synmaxcol=128
set re=1

if !has('nvim')
  set ttyscroll=3                 " Speedup scrolling
  set ttymouse=xterm2
endif

" configure tabwidth and insert spaces instead of tabs
set tabstop=4        " tab width is 4 spaces
set shiftwidth=4     " indent also with 4 spaces

set cpoptions+=n                " use the number column for the text of wrapped lines

" list of files use two space as tab
autocmd FileType javascript,vim,yml,markdown setlocal ts=2 sts=2 sw=2


" intelligent comments
set comments=sl:/*,mb:\ *,elx:\ */


" yank
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=1500, on_visual=false}
augroup END


""""""""""""""""""""""
"      Mappings      "
""""""""""""""""""""""
" if setup up <S-fn> for terminal, please refer to kitty.conf
" use terminfo-x / cat to show the special key combinations
" Extensions to the xterm protocol: https://sw.kovidgoyal.net/kitty/protocol-extensions.html
" vim or nvim
if !has("gui_running")
  if !has('nvim')
    set <S-F1>=^[[1;2P
    map <Esc>[1;2P <S-F1>
    set <S-F2>=^[[1;2Q
    map <Esc>[1;2Q <S-F2>
    set <S-F3>=^[[1;2R
    map <Esc>[1;2R <S-F3>
  else
    map <F13> <S-F1>
    map <F14> <S-F2>
    map <F15> <S-F3>
    map <F16> <S-F4>
    map <F17> <S-F5>
    map <F18> <S-F6>
    map <F19> <S-F7>
    map <F20> <S-F8>
    map <F21> <S-F9>
    map <F22> <S-F10>
    map <F23> <S-F11>
    map <F24> <S-F12>
  endif
endif

" Jump to next error with Ctrl-n and previous error with Ctrl-m. Close the
" quickfix window with <leader>a
"map <C-n> :cnext<CR>
"map <C-m> :cprevious<CR>
nnoremap <leader>a :cclose<CR>

" Visual linewise up and down by default (and use gj gk to go quicker)
noremap <Up> gk
noremap <Down> gj
noremap j gj
noremap k gk

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <leader><leader>d "_d    "" \\dw to delete without put it to register
"

" paste and copy
"
" " Copy to clipboard
vnoremap  <leader>y  "+y
nnoremap  <leader>Y  "+yg_

" Paste with middle mouse click
vmap <LeftRelease> "*ygv

" Paste with <Shift> + <Insert>
imap <C-V> <C-R>*
imap <M-V> <C-R>+   " for mac

" " Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P


" Tab/buffer
" map <C-H> :bn<CR>
" map <C-L> :bp<CR>
map <C-T>c BD <cr>
map <C-T>n :tabnew split<CR>

"" Python
au BufNewFile,BufRead *.py set colorcolumn=79
au BufNewFile,BufRead *.py set shiftwidth=4
au BufNewFile,BufRead *.py set softtabstop=4
au BufNewFile,BufRead *.py set tabstop=4
" au BufNewFile,BufRead *.py setlocal foldmethod=indent
au BufNewFile,BufRead *.py vmap <CR> :s/\(^\s*\)/\1# /<CR>:let @/ = ""<CR>
au BufNewFile,BufRead *.py vmap <S-CR> :s/\(^\s*\)# /\1/<CR>:let @/ = ""<CR>


" markdown disable conceal when edit current line
set concealcursor="i"



" file hidden
set wildmenu
set wildignore+=**/node_modules/**,/node_modules/*,*/tmp/*,*.so,*.swp,*.zip


set wildmode=longest,list,full

if has('nvim')
  set wildoptions+=pum
  set wildmode-=list
end

cnoremap <C-N> <Up>
cnoremap <C-P> <Down>


"""""""""""""""""""""
"      Plugins      "
"""""""""""""""""""""

if &diff
  set foldmethod=diff
  set diffopt+=context:0
  set cursorline
  set foldlevel=0
  set noreadonly
  colorscheme aurora
  lua require('domain.core')
  finish  " skip all following
endif



if dein#load_state('~/.cache/dein')
   call dein#begin('~/.cache/dein')
   call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')

   call dein#add('shmup/vim-sql-syntax', {'on_ft': ['sql', 'pgsql']})
   call dein#add('liuchengxu/vista.vim', {'on_cmd': ['Vista', 'Vista!!']})

   call dein#add('kamykn/spelunker.vim', {'on_func': ['spelunker#check','spelunker#check_displayed_words']})  " nevim-qt 'on_func': 'spelunker#check'failed"
   
   call dein#add('mattn/emmet-vim', { 'on_ft': ['html','css', 'js', 'ts', 'tsx'] })

   " add comments to code, tomtom/tcomment_vim is another alternative
   call dein#add('preservim/nerdcommenter', {'on_cmd': ['NERDCommenterComment', 'NERDCommenterToggle'], 'on_map':'<Leader>c<space>'})

   call dein#add('fatih/vim-go', { 'on_ft': 'go'})
   " call dein#add('zchee/nvim-go', {'build': 'make'})
   call dein#add('buoto/gotests-vim', { 'on_ft': 'go' } )

   call dein#add('voldikss/vim-floaterm', { 'on_cmd': ['FloatermNew','FloatermToggle'] })

   call dein#add('w0rp/ale', {'lazy':1, 'on_cmd': 'ALEEnable', 'on_event':['BufWritePre']})
   
   call dein#add('vim-test/vim-test'  , { 'on_cmd': ['TestNearest', 'TestFile', 'TestSuite'] })

   call dein#add('liuchengxu/vim-clap' , { 'hook_post_update': 'call clap#installer#force_download()','on_map': '<Plug>' } )
   call dein#add('mbbill/undotree')
   call dein#add('ray-x/vim-interestingwords', {'on_func': 'InterestingWords', 'on_map': ['<Plug>', '<Leader>u']})
   call dein#add('justinmk/vim-sneak', {'on_map': ['<Plug>Sneak_', 's']})
   call dein#add('AndrewRadev/splitjoin.vim',{'on_cmd':['SplitjoinJoin','SplitjoinSplit']})
   
   call dein#add('tpope/vim-fugitive', {
       \ 'on_cmd' : ['Gvsplit','Git','Gedit','Gstatus','Gdiffsplit','Gvdiffsplit','Gvdiffsplit!']
       \ })
   call dein#add('lewis6991/gitsigns.nvim')   "replacing gitsignaify

   "" for those cannot handle by lsp
   " call dein#add('Chiel92/vim-autoformat', {'on_cmd': 'Autoformat'})
   call dein#add('ray-x/aurora')

   " work space management
   call dein#add('tpope/vim-obsession')
   call dein#add('dhruvasagar/vim-prosession')

   " bracket
   call dein#add('Raimondi/delimitMate', { 'on_event': 'InsertEnter',  'on_map': '<Plug>'})

   "" seems to be redundant clap. just in case clap is crashing
   " call dein#add('junegunn/fzf', { 'build': './install --all', 'merged': 0 }) 
   " call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })
   " call dein#add('chengzeyi/fzf-preview.vim', { 'depends': 'fzf' })
   

endif ""end of nvim

let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall
" let g:user_emmet_leader_key='<C-Z>'  " <C-Y> leader"



let g:python3_host_prog = '/usr/bin/python3'
colorscheme aurora
