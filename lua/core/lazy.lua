local function daylight()
  local h = tonumber(os.date("%H"))
  if h > 6 and h < 18 then
    return "light"
  else
    return "dark"
  end
end

local loader = require("packer").loader
math.randomseed(os.time())
function loadscheme()
  local themes = {
    "starry.nvim",
    "aurora",
    "aurora",
    "tokyonight.nvim",
    "starry.nvim",
    "aurora",
    "gruvbox-material",
    "sonokai",
    "github-nvim-theme",
  }

  if plugin_folder() == [[~/github/]] then
    if daylight() == "light" then
      themes = { "gruvbox-material", "starry.nvim" }
    end

    -- themes = { "aurora" }
  end
  local v = math.random(1, #themes)
  local loading_theme = themes[v]

  loader(loading_theme)
end

_G.PLoader = loader


if vim.wo.diff then
  -- loader(plugins)
  lprint("diffmode")
  vim.cmd([[packadd nvim-treesitter]])
  require("nvim-treesitter.configs").setup({ highlight = { enable = true, use_languagetree = false } })
  vim.cmd([[syntax on]])
  return
else
  loader("nvim-treesitter")
end

function Lazyload()
  --
  --


  lprint("I am lazy")

  local disable_ft = {
    "NvimTree",
    "guihua",
    "guihua_rust",
    "clap_input",
    "clap_spinner",
    "TelescopePrompt",
    "csv",
    "txt",
    "defx",
  }

  local syn_on = not vim.tbl_contains(disable_ft, vim.bo.filetype)
  if not syn_on then
    vim.cmd([[syntax manual]])
  end

  -- local fname = vim.fn.expand("%:p:f")
  local fsize = vim.fn.getfsize(vim.fn.expand("%:p:f"))
  if fsize == nil or fsize < 0 then
    fsize = 1
  end

  local load_lsp = true
  local load_ts_plugins = true

  if fsize > 1024 * 1024 then
    load_ts_plugins = false
    load_lsp = false
  end
  if fsize > 6 * 1024 * 1024 then
    vim.cmd([[syntax off]])
    return
  end

  local plugins = "plenary.nvim"
  loader("plenary.nvim")

  if vim.bo.filetype == "lua" then
    loader("lua-dev.nvim")
  end

  vim.g.vimsyn_embed = "lPr"

  local gitrepo = vim.fn.isdirectory(".git/index")
  if gitrepo then
    loader("gitsigns.nvim") -- neogit vgit.nvim
  end

  if load_lsp then
    loader("nvim-lspconfig") -- null-ls.nvim
    loader("lsp_signature.nvim")
    if use_nulls() then
      loader("null-ls.nvim")
    end
  end

  if load_lsp or load_ts_plugins then
    loader("guihua.lua")
    loader("navigator.lua")
  end

  -- local bytes = vim.fn.wordcount()['bytes']
  if load_ts_plugins then
    -- nvim-treesitter-textobjects nvim-treesitter-refactor auto loaded with after
    plugins = "nvim-treesitter-textobjects nvim-ts-autotag nvim-ts-context-commentstring nvim-treesitter-textsubjects"
    loader(plugins)
    lprint(plugins)
    loader("neogen")
    -- nvim-treesitter-textobjects should be autoloaded
    loader("refactoring.nvim")
    loader("indent-blankline.nvim")
  end

  -- if bytes < 2 * 1024 * 1024 and syn_on then
  --   vim.cmd([[setlocal syntax=on]])
  -- end

  vim.cmd([[autocmd FileType vista,guihua setlocal syntax=on]])
  vim.cmd(
    [[autocmd FileType * silent! lua if vim.fn.wordcount()['bytes'] > 2048000 then print("syntax off") vim.cmd("setlocal syntax=off") end]]
  )
  lprint("LoadLazyPlugin finished")
end

local lazy_timer = 30
if _G.packer_plugins == nil or _G.packer_plugins["packer.nvim"] == nil then
  print("recompile")
  vim.cmd([[PackerCompile]])
  vim.defer_fn(function()
    print("Packer recompiled, please run `:PackerCompile` and restart nvim")
  end, 400)
  return
end

vim.defer_fn(function()
  vim.cmd([[doautocmd User LoadLazyPlugin]])
end, lazy_timer)

-- vim.defer_fn(function()
--   -- in case highlight is incorrect
--   local cmd = "TSEnableAll highlight " .. vim.o.ft
--   vim.cmd(cmd)
--   vim.cmd([[doautocmd ColorScheme]])
--   vim.cmd(cmd)
-- end, lazy_timer + 20)

vim.cmd([[hi LineNr guifg=#505068]])

vim.cmd([[autocmd User LoadLazyPlugin lua Lazyload()]])

loadscheme()
vim.defer_fn(function()
  loader("windline.nvim")
  require("modules.ui.eviline")
  require("wlfloatline").setup()
  require("vscripts.tools")
  vim.cmd("command! Gram lua require'modules.tools.config'.grammcheck()")
  vim.cmd("command! Spell call spelunker#check()")
  lprint("ui loaded")
end, lazy_timer + 60)
--
vim.defer_fn(function()
  lprint("telescope family")
  loader("telescope.nvim")
  loader("telescope-zoxide project.nvim nvim-neoclip.lua")
  loader("harpoon")
  loader("nvim-notify")
  vim.notify = require("notify")
  -- require("vscripts.cursorhold")
  lprint("all done")
end, lazy_timer + 80)
