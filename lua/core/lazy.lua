function lazyload()
  print("I am lazy")

  local loader = require "packer".loader
  local fname = vim.fn.expand("%:p:f")
  local fsize = vim.fn.getfsize(fname)
  if fsize == nil or fsize < 0 then
    fsize = 1
  end
  local load_ts_plugins = true
  if fsize > 512 * 1024 then
    load_ts_plugins = false
  end

  local plugins = "nvim-treesitter" -- nvim-treesitter-textobjects should be autoloaded
  loader(plugins)

  plugins = "plenary.nvim gitsigns.nvim nvim-lspconfig guihua.lua navigator.lua indent-blankline.nvim "

  loader(plugins)
  require("modules.tools.config").gitsigns()
  require("vscripts.cursorhold")
  require("vscripts.tools")

  if load_ts_plugins then
    plugins = "nvim-treesitter-refactor nvim-ts-rainbow nvim-ts-autotag"
    loader(plugins)
    return -- do not enable syntax
  end

  vim.cmd([[syntax on]])
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
