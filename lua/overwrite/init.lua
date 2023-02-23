local overwrite = function()
  require('overwrite.mapping')
  require('overwrite.options')

  if vim.g.goneovim then
    -- vim.api.nvim_set_option('guifont', "FiraCode Nerd Font:h18")
    vim.api.nvim_set_option('guifont', 'VictorMono Nerd Font:h18')
  end
end

if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0.01
  vim.g.neovide_cursor_trail_length = 0.05
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_remember_window_size = true
  vim.cmd([[set guifont=JetBrainsMono\ Nerd\ Font:h16]])
end

vim.cmd([[autocmd TermOpen * setlocal nospell]])
vim.cmd([[autocmd TermOpen,BufEnter term://* startinsert]])
vim.cmd([[tnoremap <Esc>q <C-\><C-n>]])

overwrite()
