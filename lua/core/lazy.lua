

function lazyload()
  if vim.wo.diff then
    -- local plugins = "nvim-treesitter" -- nvim-treesitter-textobjects should be autoloaded
    -- loader(plugins)
    vim.cmd([[packadd nvim-treesitter]])
    require "nvim-treesitter.configs".setup { 
      highlight = { 
      enable = true,
      use_languagetree = true,
      }
    }
    -- vim.cmd([[syntax on]])
    return
  end
  local load_lsp = true
  print("I am lazy")
  local disable_ft = {"NvimTree", "guihua", "clap_input", "clap_spinner", "TelescopePrompt", "csv", "txt", "defx", "sidekick"}
  local syn_on = not vim.tbl_contains(disable_ft, vim.bo.filetype)
  if syn_on then
    vim.cmd([[syntax manual]])
  end
  local loader = require "packer".loader
  -- local fname = vim.fn.expand("%:p:f")
  local fsize = vim.fn.getfsize(vim.fn.expand("%:p:f"))
  if fsize == nil or fsize < 0 then
    fsize = 1
  end
  local load_ts_plugins = true
  if fsize > 1024 * 1024 then
    load_ts_plugins = false
    load_lsp = false
  end
  if fsize > 6 * 1024 * 1024 then
    -- vim.cmd([[syntax off]])
    return
  end

  -- if vim.bo.filetype == 'lua' then
  --   loader("lua-dev.nvim")
  -- end

  plugins = "plenary.nvim gitsigns.nvim" --nvim-lspconfig navigator.lua   guihua.lua navigator.lua 
  vim.g.vimsyn_embed = 'lPr'
  loader(plugins)

  if load_lsp then
    loader("nvim-lspconfig guihua.lua lsp_signature.nvim navigator.lua")
  end

  --require'lsp.config'.setup()

  require("vscripts.cursorhold")
  require("vscripts.tools")
  local bytes = vim.fn.wordcount()['bytes']
  -- print(bytes)
  if load_ts_plugins then
    print("lazy treesitter loading")
    plugins = "nvim-treesitter nvim-treesitter-refactor indent-blankline.nvim"  --  nvim-ts-rainbow nvim-ts-autotag
    -- nvim-treesitter-textobjects should be autoloaded
    loader(plugins)
    -- enable syntax if is small  
    if fsize < 512 * 1024 and syn_on then
      vim.cmd([[setlocal syntax=on]])
    end
    return -- do not enable syntax
  else
    vim.cmd([[setlocal syntax=on]])
    -- require "nvim-treesitter.configs".setup { 
    --   highlight = { 
    --   enable = true,
    --   use_languagetree = false,
    --   }
    -- }
  end
  if bytes < 1024 * 1024 and syn_on then
    vim.cmd([[setlocal syntax=on]])
  end
end

vim.cmd([[autocmd User LoadLazyPlugin lua lazyload()]])

vim.cmd([[autocmd FileType vista setlocal syntax=on]])
vim.cmd([[autocmd FileType guihua setlocal syntax=on]])
vim.cmd([[autocmd FileType * silent! lua if vim.fn.wordcount()['bytes'] < 2048000 then vim.cmd("setlocal syntax=on") end]])
vim.cmd(
    [["autocmd TextChanged,InsertLeave *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync"]])

vim.cmd("command! Gram lua require'modules.tools.config'.grammcheck()")
vim.cmd("command! Spell call spelunker#check()")

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
