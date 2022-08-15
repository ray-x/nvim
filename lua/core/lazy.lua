local loader = require("packer").loader

lprint("lazy")

local start = vim.loop.now()
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

local function randomscheme()
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
    "galaxy",
  }

  if daylight() == "light" then
    vim.o.background = "light"
    themes = { "gruvbox-material", "starry.nvim", "catppuccin", "github-nvim-theme" }
  end

  local v = math.random(1, #themes)

  local loading_theme = themes[v]
  --[[ loading_theme = "aurora" ]]
  -- lprint(loading_theme, os.clock())
  if daylight() == "light" then
    if loading_theme == "github-nvim-theme" or loading_theme == "catppuccin" then
      if vim.fn.executable("kitty") == 1 and transparent == true then --TODO: not finished
        vim.cmd([[silent exec "!kitty +kitten themes --reload-in=all Material"]])
      end
    end
  end
  return loading_theme
end

local loading_theme = randomscheme()

local function load_colorscheme(theme)
  if theme == "galaxy" then
    require("modules.ui.galaxy").shine()
  else
    require("packer").loader(theme)
  end
end

load_colorscheme(loading_theme)

if vim.wo.diff then
  -- loader(plugins)
  lprint("diffmode")
  if load_ts_plugins then
    vim.cmd([[packadd nvim-treesitter]])
    require("nvim-treesitter.configs").setup({ highlight = { enable = true, use_languagetree = false } })
  else
    vim.cmd([[syntax on]])
  end
  return
end

-- load module but not init/config it
vim.cmd([[packadd nvim-treesitter]])
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
    lprint("syntax off")
    load_lsp = false
    load_ts_plugins = false
    vim.cmd([[syntax off]])
  end
  if load_ts_plugins then
    lprint("loading treesitter")
    loader("nvim-treesitter")
  end
  local plugins = "plenary.nvim"
  loader("plenary.nvim")

  if vim.bo.filetype == "lua" then
    loader("lua-dev.nvim")
  end

  vim.g.vimsyn_embed = "lPr"

  if load_lsp then
    loader("nvim-lspconfig")
    loader("lsp_signature.nvim")
  end

  loader("guihua.lua")
  if load_lsp or load_ts_plugins then
    loader("navigator.lua")
  end

  if load_ts_plugins then
    lprint("loading treesitter related plugins")
    plugins = "nvim-treesitter-textobjects nvim-ts-autotag nvim-ts-context-commentstring nvim-treesitter-textsubjects"
    loader(plugins)
    -- lprint(plugins .. " loaded", os.clock())
    loader("neogen")
    loader("refactoring.nvim")
    loader("indent-blankline.nvim")
    loader("hlargs.nvim")
    lprint("ts loaded")
  end

  vim.cmd([[autocmd FileType vista,guihua,guihua_rust setlocal syntax=on]])
  vim.cmd(
    [[autocmd FileType * silent! lua if vim.fn.wordcount()['bytes'] > 2048000 then print("syntax off") vim.cmd("setlocal syntax=off") end]]
  )

  if load_lsp and use_nulls() then
    loader("null-ls.nvim")
  end

  if load_lsp and use_efm() then
    loader("efm.nvim")
  end

  loader("bufferline.nvim")
  -- lprint("LoadLazyPlugin finished", os.clock())

  lprint("lazy colorscheme loaded", vim.loop.now() - start)
end

local lazy_timer = 20
if _G.packer_plugins == nil or _G.packer_plugins["packer.nvim"] == nil then
  print("recompile")
  vim.cmd([[PackerCompile]])
  vim.defer_fn(function()
    print("Packer recompiled, please run `:PackerCompile` and restart nvim")
  end, 400)
  return
end

vim.defer_fn(function()
  Lazyload()
end, lazy_timer)

vim.cmd([[autocmd User LoadLazyPlugin lua Lazyload()]])

vim.defer_fn(function()
  loader("hydra.nvim")
  loader("windline.nvim")
  require("modules.ui.eviline")
  require("wlfloatline").setup()
  require("vscripts.tools")
  vim.cmd("command! Gram lua require'modules.tools.config'.grammcheck()")
  vim.cmd("command! Spell call spelunker#check()")

  lprint("lazy wlfloat loaded", vim.loop.now() - start)
end, lazy_timer + 30)
--
vim.defer_fn(function()
  loader("telescope.nvim")
  -- load from
  -- loader("telescope-zoxide project.nvim nvim-neoclip.lua")
  loader("harpoon")
  loader("nvim-notify")
  vim.notify = require("notify")
  require("vscripts.cursorhold")

  local gitrepo = vim.fn.isdirectory(".git/index")
  if gitrepo then
    loader("gitsigns.nvim") -- neogit
    loader("git-conflict.nvim")
    require("modules.editor.hydra").hydra_git()
  end
  -- lprint("all done", os.clock())
  if vim.fn.executable(vim.g.python3_host_prog) == 0 then
    print("file not find, please update path setup", vim.g.python3_host_prog)
  end
  lprint("lazy2 loaded", vim.loop.now() - start)
end, lazy_timer + 80)

if plugin_folder() == [[~/github/ray-x/]] then
  -- it is my own box, setup fish
  vim.cmd([[set shell=/usr/bin/fish]])
  vim.cmd([[command! GD term gd]])
end
