function lazyload()
  print("I am lazy")
  vim.cmd([[syntax manual]])
  local loader = require "packer".loader
  local fname = vim.fn.expand("%:p:f")
  local fsize = vim.fn.getfsize(fname)
  if fsize == nil or fsize < 0 then
    fsize = 1
  end
  local load_ts_plugins = true
  if fsize > 1024 * 1024 then
    load_ts_plugins = false
  end
  if fsize > 6 * 1024 * 1024 then
    -- vim.cmd([[syntax off]])
    return
  end
  local plugins = "nvim-treesitter" -- nvim-treesitter-textobjects should be autoloaded
  loader(plugins)

  plugins = "plenary.nvim gitsigns.nvim indent-blankline.nvim nvim-lspconfig guihua.lua navigator.lua" --nvim-lspconfig navigator.lua   guihua.lua navigator.lua 
  vim.g.vimsyn_embed = 'lPr'
  loader(plugins)
  require("vscripts.cursorhold")
  require("vscripts.tools")
  local bytes = vim.fn.wordcount()['bytes']
  print(bytes)
  if load_ts_plugins then
    plugins = "nvim-treesitter-refactor"  --  nvim-ts-rainbow nvim-ts-autotag
    loader(plugins)
    -- enable syntax if is small  
    if bytes < 500 * 1024 then
      vim.cmd([[setlocal syntax=on]])
    end
    return -- do not enable syntax
  end
  if bytes < 1024 * 1024 then
    vim.cmd([[setlocal syntax=on]])
  end
end

vim.cmd([[autocmd User LoadLazyPlugin lua lazyload()]])

vim.cmd([[autocmd FileType vista setlocal syntax=on]])
vim.cmd([[autocmd FileType guihua setlocal syntax=on]])
vim.cmd([[autocmd FileType * silent! lua if vim.fn.wordcount()['bytes'] < 2048000 then vim.cmd("setlocal syntax=on") end]])
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
