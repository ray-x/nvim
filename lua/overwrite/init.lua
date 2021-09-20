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


_G.lprint=require'utils.log'.lprint



if vim.g.neovide then
  vim.g.neovide_cursor_animation_length=0.01
  vim.g.neovide_cursor_trail_length=0.05
  vim.g.neovide_cursor_antialiasing=true
  vim.g.neovide_remember_window_size = true
  vim.cmd([[set guifont=JetBrainsMono\ Nerd\ Font:h16]])
end

overwrite()
