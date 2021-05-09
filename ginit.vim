" This file is only loaded in GUIs
" Neovim-qt Guifont command
" Set the font to DejaVu Sans Mono:h13
" :Guifont Hack:h18
autocmd VimEnter * highlight Comment cterm=italic gui=italic
" Guifont SourceCodePro\ Nerd\ Font:h14
" vimr doesn't support :Guifont
 "" Hack\ Nerd\ Font  VictorMono

if !has("gui_vimr") && has('nvim') " && !exists('g:fvim_loaded')
   :Guifont VictorMono\ Nerd\ Font:h18 
   :GuiTabline 1
   :GuiRenderLigatures 1
   set linespace=0  " a small linespace"
endif

" macvim
"if !has('nvim')
if has('gui_macvim')
	set guifont=JetBrainsMono\ Nerd\ Font:h18
	set macligatures
    let g:macvim_skip_colorscheme=1
endif

if g:gonvim_running
    set guifont=JetBrainsMono\ Nerd\ Font:h18
endif

" mouse copy paste
nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
vnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv


echo "gui loading"