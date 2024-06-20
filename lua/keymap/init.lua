vim.cmd([[vnoremap  <leader>y  "+y
nnoremap  <leader>Y  "+yg_
vnoremap  <M-c>  "+y
nnoremap  <M-c>  "+yg_
inoremap  <M-c>  "+yg_
inoremap  <M-v>  <CTRL-r>*
inoremap  <D-v>  <CTRL-r>*]])
-- yank whole file and reset cursor back

vim.cmd([[map <C-a><C-c> gg"*yG``
imap <C-a><C-c> <ESC>gg"*yGgi
nmap <C-Insert> "*yy
imap <C-Insert> <ESC>"*yygi
nmap <S-Insert> "*p
imap <S-Insert> <C-R>*
" Capitalize inner word
map <M-c> guiw~w
" UPPERCASE inner word
map <M-u> gUiww
" lowercase inner word
map <M-l> guiww
" just one space on the line, preserving indent
map <M-Space> m`:s/\S\+\zs \+/ /g<CR>``:nohl<CR>]])

vim.cmd([[
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz
nnoremap <C-b> <PageUp>H0
nnoremap <C-f> <PageDown>L0
]])

--
vim.cmd([[imap <M-V> <C-R>+
imap <C-V> <C-R>*
vmap <LeftRelease> "*ygv]])
-- unlet loaded_matchparen
require('keymap.keys')
require('keymap.func')
