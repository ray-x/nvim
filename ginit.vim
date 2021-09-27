" This file is only loaded in GUIs
" Neovim-qt Guifont command
" Set the font to DejaVu Sans Mono:h13
" :Guifont Hack:h18
autocmd VimEnter * highlight Comment cterm=italic gui=italic
" set guifont=VictorMono\ Nerd\ Font:h14
" set guifont=FiraCode\ Nerd\ Font:h18
let g:neovide_input_use_logo=v:true
" set guifont=Victor\ Mono:h18
" set guifont=Iosevka\ Mono:h18
" Guifont SourceCodePro\ Nerd\ Font:h14
" vimr doesn't support :Guifont
 "" Hack\ Nerd\ Font  VictorMono

if exists(':GuiFont')
   :Guifont VictorMono\ Nerd\ Font:h18 
   :GuiTabline 1
   :GuiRenderLigatures 1
   set linespace=0  " a small linespace"
endif

if exists('g:fvim_loaded')
    set guifont=JetBrainsMono\ Nerd\ Font:h18    
    FVimCursorSmoothMove v:true
    FVimCursorSmoothBlink v:true
endif


" macvim
"if !has('nvim')
if has('gui_macvim')
	set guifont=JetBrainsMono\ Nerd\ Font:h18
	set macligatures
    let g:macvim_skip_colorscheme=1
endif

if exists('g:gonvim_running')
    " set guifont=JetBrainsMono\ Nerd\ Font:h14
    " set guifont=VictorMono\ Nerd\ Font:h14
endif


""victor\ mono is nerd font
" set guifont=Victor\ Mono:h14
if exists('g:neoray')
    "set guifont=Go_Mono:h11
    set guifont=SpaceMono:h14
    NeoraySet CursorAnimTime 0.04
    NeoraySet Transparency   0.95
    NeoraySet TargetTPS      120
    NeoraySet ContextMenuOn  TRUE
    NeoraySet WindowSize     120x40
    NeoraySet WindowState    centered
    NeoraySet KeyFullscreen  <M-C-CR>
    NeoraySet KeyZoomIn      <C-kPlus>
    NeoraySet KeyZoomOut     <C-kMinus>
endif

" mouse copy paste
nnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>
inoremap <silent><RightMouse> <Esc>:call GuiShowContextMenu()<CR>
vnoremap <silent><RightMouse> :call GuiShowContextMenu()<CR>gv




echo "gui loading"