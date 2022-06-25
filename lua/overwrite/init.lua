local overwrite =function()
  require('overwrite.event')
  require('overwrite.mapping')
  require('overwrite.options')

  if vim.g.goneovim then
    -- vim.api.nvim_set_option('guifont', "FiraCode Nerd Font:h18")
    vim.api.nvim_set_option('guifont', "VictorMono Nerd Font:h18")
  end


  if vim.g.neoray then
    vim.api.nvim_set_option('guifont', 'Victor Mono:h14')
    vim.cmd([[NeoraySet CursorAnimTime 0.04]])
    vim.cmd([[NeoraySet Transparency   0.95]])
    vim.cmd([[NeoraySet TargetTPS      120]])
    vim.cmd([[NeoraySet ContextMenuOn  TRUE]])
    -- vim.cmd([[NeoraySet WindowSize     120x40]])
    -- vim.cmd([[NeoraySet WindowState    centered]])
    vim.cmd([[NeoraySet KeyFullscreen  <M-C-CR>]])
    vim.cmd([[NeoraySet KeyZoomIn      <C-=>]])
    vim.cmd([[NeoraySet KeyZoomOut     <C-->]])
    vim.cmd([[NeoraySet BoxDrawingOn    TRUE]])
  end
end

if vim.g.neovide then
  vim.g.neovide_cursor_animation_length=0.01
  vim.g.neovide_cursor_trail_length=0.05
  vim.g.neovide_cursor_antialiasing=true
  vim.g.neovide_remember_window_size = true
  vim.cmd([[set guifont=JetBrainsMono\ Nerd\ Font:h16]])
end

if vim.fn.exists('g:nvui') ~= 0 then
  -- Configure nvui here
  vim.cmd([[NvuiCmdFontFamily VictorMono Nerd Font]])
  vim.cmd([[set linespace=1]])
  vim.cmd([[set guifont=VictorMono\ Nerd\ Font:h18]])
  vim.cmd([[NvuiPopupMenuDefaultIconFg white]])
  vim.cmd([[NvuiCmdBg #1e2125]])
  vim.cmd([[NvuiCmdFg #abb2bf]])
  vim.cmd([[NvuiCmdBigFontScaleFactor 1.0]])
  vim.cmd([[NvuiCmdPadding 10]])
  vim.cmd([[NvuiCmdCenterXPos 0.5]])
  vim.cmd([[NvuiCmdTopPos 0.0]])
  vim.cmd([[NvuiCmdFontSize 25.0]])
  vim.cmd([[NvuiCmdBorderWidth 5]])
  vim.cmd([[NvuiPopupMenuIconFg variable #56b6c2]])
  vim.cmd([[NvuiPopupMenuIconFg function #c678dd]])
  vim.cmd([[NvuiPopupMenuIconFg method #c678dd]])
  vim.cmd([[NvuiPopupMenuIconFg field #d19a66]])
  vim.cmd([[NvuiPopupMenuIconFg property #d19a66]])
  vim.cmd([[NvuiPopupMenuIconFg module white]])
  vim.cmd([[NvuiPopupMenuIconFg struct #e5c07b]])
  vim.cmd([[NvuiCaretExtendTop 15]])
  vim.cmd([[NvuiCaretExtendBottom 8]])
  vim.cmd([[NvuiTitlebarFontSize 12]])
  vim.cmd([[NvuiTitlebarFontFamily Arial]])
  vim.cmd([[NvuiCursorAnimationDuration 0.1]])
  -- vim.cmd([[set guicursor=n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor-blinkwait300-blinkon500-blinkoff300,r-cr-o:hor20]])
end

vim.cmd([[autocmd TermOpen * setlocal nospell]])
vim.cmd([[autocmd TermOpen,BufEnter term://* startinsert]])
vim.cmd([[tnoremap <Esc>q <C-\><C-n>]])

overwrite()
