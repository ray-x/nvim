local loader = require("packer").loader

local fsize = vim.fn.getfsize(vim.fn.expand("%:p:f"))
if fsize == nil or fsize < 0 then
  fsize = 1
end

local load_ts_plugins = true
local load_lsp = true

if fsize > 1024 * 1024 then
  load_ts_plugins = false
  load_lsp = false
end

math.randomseed(os.time())

local function daylight()
  local h = tonumber(os.date("%H"))
  if h > 6 and h < 18 then
    return "light"
  else
    return "dark"
  end
end

local function loadscheme()
  local themes = {
    "starry.nvim",
    "aurora",
    "aurora",
    "tokyonight.nvim",
    "starry.nvim",
    "aurora",
    "gruvbox-material",
    "sonokai",
    "catppuccin",
    "github-nvim-theme",
  }

  if daylight() == "light" then
    vim.o.background = "light"
    themes = { "gruvbox-material", "starry.nvim", "github-nvim-theme", "catppuccin" }
  end

  -- themes = { "starry.nvim" }
  -- themes = { "catppuccin" }
  -- themes = { "github-nvim-theme" }
  local v = math.random(1, #themes)
  local loading_theme = themes[v]
  lprint(loading_theme)

  require("packer").loader(loading_theme)
end
loadscheme()

_G.PLoader = loader

if vim.wo.diff then
  -- loader(plugins)
  lprint("diffmode")
  if load_ts_plugins then
    vim.cmd([[packadd nvim-treesitter]])
    require("nvim-treesitter.configs").setup({ highlight = { enable = true, use_languagetree = false } })
  end
  vim.cmd([[syntax on]])
  return
else
  loader("nvim-treesitter")
end

function Lazyload()
  lprint("I am lazy")
  local disable_ft = {
    "NvimTree",
    "guihua",
    "packer",
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
    loader("libp.nvim") -- igit
  end

  if load_lsp then
    loader("nvim-lspconfig")
    loader("lsp_signature.nvim")
  end

  loader("guihua.lua")
  if load_lsp or load_ts_plugins then
    loader("navigator.lua")
  end

  if load_ts_plugins then
    plugins = "nvim-treesitter-textobjects nvim-ts-autotag nvim-ts-context-commentstring nvim-treesitter-textsubjects"
    loader(plugins)
    lprint(plugins .. " loaded")
    loader("neogen")
    loader("refactoring.nvim")
    loader("indent-blankline.nvim")
    lprint("ts loaded")
  end

  vim.cmd([[autocmd FileType vista,guihua setlocal syntax=on]])
  vim.cmd(
    [[autocmd FileType * silent! lua if vim.fn.wordcount()['bytes'] > 2048000 then print("syntax off") vim.cmd("setlocal syntax=off") end]]
  )

  if load_lsp and use_nulls() then
    loader("null-ls.nvim")
  end

  if load_lsp and use_efm() then
    loader("efm.nvim")
  end
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

-- vim.cmd([[hi LineNr guifg=#505068]])

vim.cmd([[autocmd User LoadLazyPlugin lua Lazyload()]])

vim.defer_fn(function()
  lprint("ui start")
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
  require("vscripts.cursorhold")
  lprint("all done")
  if vim.fn.executable(vim.g.python3_host_prog) == 0 then
    print("file not find, please update path setup", vim.g.python3_host_prog)
  end
end, lazy_timer + 80)
