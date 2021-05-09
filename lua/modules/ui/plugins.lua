local ui = {}
local conf = require("modules.ui.config")

-- ui['glepnir/zephyr-nvim'] = {
--   config = [[vim.cmd('colorscheme zephyr')]]
-- }
--
local winwidth = function()
  return vim.api.nvim_call_function("winwidth", {0})
end

ui["kyazdani42/nvim-web-devicons"] = {}
ui["glepnir/galaxyline.nvim"] = {
  branch = "main",
  event = "UIEnter",
  -- after = {"aurora"},
  config = conf.galaxyline,
  -- requires = {'kyazdani42/nvim-web-devicons'},
  opt = true
}

ui["Akin909/nvim-bufferline.lua"] = {
  config = conf.nvim_bufferline,
  event = "UIEnter",
  -- after = {"aurora"}
  -- requires = {'kyazdani42/nvim-web-devicons'}
  opt = true
}
-- 'luaromgrk/barbar.nvim'
-- ui['romgrk/barbar.nvim'] = {
--   config = conf.barbar,
--   requires = {'kyazdani42/nvim-web-devicons'}
-- }
--

ui["wfxr/minimap.vim"] = {
  run = ":!cargo install --locked code-minimap",
  keys = {"<F14>"},
  cmd = {"Minimap", "MinimapToggle"},
  setup = conf.minimap
}
-- ui['glepnir/dashboard-nvim'] = {
--   config = conf.dashboard
-- }

ui["kyazdani42/nvim-tree.lua"] = {
  cmd = {"NvimTreeToggle", "NvimTreeOpen"},
  -- requires = {'kyazdani42/nvim-web-devicons'},
  setup = conf.nvim_tree
}

ui["lukas-reineke/indent-blankline.nvim"] = {setup = conf.blankline, branch = "lua", opt = true} --after="nvim-treesitter",

-- replaced by nl
ui["ray-x/vim-interestingwords"] = {keys = {"<Leader>u"}, config = conf.interestingwords, opt = true}

ui["dstein64/nvim-scrollview"] = {config = conf.scrollview}

ui["ray-x/aurora"] = {opt = true, config = conf.aurora}
ui["folke/tokyonight.nvim"] = {opt = true, config = conf.tokyonight}
ui["shaunsingh/moonlight.nvim"] = {opt = true, config = conf.moonlight}
ui["bluz71/vim-nightfly-guicolors"] = {opt = true, config = conf.nightfly}
ui["ChristianChiarulli/nvcode-color-schemes.vim"] = {opt = true, config = conf.nvcode}
ui["sainnhe/sonokai"] = {opt = true, config = conf.sonokai}
ui["glepnir/zephyr-nvim"] = {opt = true, config = conf.zephyr}

return ui
