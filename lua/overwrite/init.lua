local overwrite =function()
  require('overwrite.event') 
  require('overwrite.mapping') 
  require('overwrite.options')

  if vim.g.gonvim_running then
    vim.api.nvim_set_option('guifont', "FiraCode Nerd Font:h18")
  end
end

-- vim.g.debug_output=true
vim.g.navigator_verbose=true
overwrite()