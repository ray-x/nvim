function lazyload()
  print("I am lazy")
  vim.cmd([[syntax on]])
  local plugins = ""
  local plugins =
    "plenary.nvim gitsigns.nvim nvim-treesitter nvim-treesitter-textobjects nvim-treesitter-refactor nvim-lspconfig guihua.lua navigator.lua indent-blankline.nvim"

  local loader = require "packer".loader
  loader(plugins)
  require("modules.tools.config").gitsigns()
  require("vscripts.cursorhold")
  require("vscripts.tools")
end

vim.cmd([[autocmd User LoadLazyPlugin lua lazyload()]])

vim.defer_fn(
  function()
    vim.cmd([[doautocmd User LoadLazyPlugin]])
  end,
  80
)

vim.defer_fn(
  function()
    vim.cmd([[doautocmd ColorScheme]])
  end,
  100
)
