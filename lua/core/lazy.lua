local function daylight()
  local h = tonumber(os.date("%H"))
  if h > 6 and h < 18 then
    return "light"
  else
    return "dark"
  end
end

local loader = require("packer").loader
_G.PLoader = loader
function Lazyload()
  --
  math.randomseed(os.time())
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
    "mechanical.nvim",
  }

  if plugin_folder() == [[~/github/]] then
    if daylight() == "light" then
      themes = { "gruvbox-material", "starry.nvim" }
    end

    -- themes = {"gruvbox-material"}
    -- debug the color theme
    -- themes = { "starry.nvim" }
    -- themes = {"aurora"}
  end
  local v = math.random(1, #themes)
  local loading_theme = themes[v]

  loader(loading_theme)
  --
  if vim.wo.diff then
    -- loader(plugins)
    lprint("diffmode")
    vim.cmd([[packadd nvim-treesitter]])
    require("nvim-treesitter.configs").setup({ highlight = { enable = true, use_languagetree = false } })
    -- vim.cmd([[syntax on]])
    return
  end

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
    "sidekick",
  }

  local syn_on = not vim.tbl_contains(disable_ft, vim.bo.filetype)
  if syn_on then
    vim.cmd([[syntax manual]])
    -- else
    --   vim.cmd([[syntax on]])
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

  local plugins = "plenary.nvim" -- nvim-lspconfig navigator.lua   guihua.lua navigator.lua  -- gitsigns.nvim
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
    loader("null-ls.nvim")
    loader("nvim-lspconfig") -- null-ls.nvim
    loader("lsp_signature.nvim")
  end

  require("vscripts.cursorhold")
  require("vscripts.tools")
  if load_ts_plugins then
    -- print('load ts plugins')
    loader("nvim-treesitter")
  end

  if load_lsp or load_ts_plugins then
    loader("guihua.lua")
    loader("navigator.lua")
  end

  -- local bytes = vim.fn.wordcount()['bytes']
  if load_ts_plugins then
    plugins =
      "nvim-treesitter-textobjects nvim-treesitter-refactor nvim-ts-autotag nvim-ts-context-commentstring nvim-treesitter-textsubjects" --  nvim-ts-rainbow  nvim-treesitter nvim-treesitter-refactor

    lprint(plugins)
    -- nvim-treesitter-textobjects should be autoloaded
    loader(plugins)
    loader("indent-blankline.nvim")
  end

  -- if bytes < 2 * 1024 * 1024 and syn_on then
  --   vim.cmd([[setlocal syntax=on]])
  -- end

  vim.cmd([[autocmd FileType vista,guihua setlocal syntax=on]])
  vim.cmd(
    [[autocmd FileType * silent! lua if vim.fn.wordcount()['bytes'] > 2048000 then print("syntax off") vim.cmd("setlocal syntax=off") else vim.cmd("setlocal syntax=on") end]]
  )
  -- local cmd = [[au VimEnter * ++once lua require("packer.load")({']] .. loading_theme
  --                 .. [['}, { event = "VimEnter *" }, _G.packer_plugins)]]
  -- vim.cmd(cmd)
  require("modules.ui.eviline")
  require("wlfloatline").setup()
end

vim.cmd([[autocmd User LoadLazyPlugin lua Lazyload()]])
vim.cmd("command! Gram lua require'modules.tools.config'.grammcheck()")
vim.cmd("command! Spell call spelunker#check()")

local lazy_timer = 50
vim.defer_fn(function()
  vim.cmd([[doautocmd User LoadLazyPlugin]])
end, lazy_timer)

-- vim.defer_fn(function()
--   -- lazyload()
--   local cmd = 'TSEnableAll highlight ' .. vim.o.ft
--   -- vim.cmd(cmd)
--   -- vim.cmd([[doautocmd ColorScheme]])
--   -- vim.cmd(cmd)
-- end, lazy_timer + 20)

vim.cmd([[hi LineNr guifg=#505068]])

vim.defer_fn(function()
  local loader = require("packer").loader
  loader("telescope.nvim telescope-zoxide project.nvim nvim-neoclip.lua")
  loader("neogen harpoon")
  loader('windline.nvim')
end, lazy_timer + 100)
