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

ui["lambdalisue/glyph-palette.vim"] = {}

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

-- ui["wfxr/minimap.vim"] = {
--   run = ":!cargo install --locked code-minimap",
--   keys = {"<F14>"},
--   cmd = {"Minimap", "MinimapToggle"},
--   setup = conf.minimap
-- }
-- ui['glepnir/dashboard-nvim'] = {
--   config = conf.dashboard
-- }

ui["kyazdani42/nvim-tree.lua"] = {
  cmd = {"NvimTreeToggle", "NvimTreeOpen"},
  -- requires = {'kyazdani42/nvim-web-devicons'},
  setup = conf.nvim_tree
}

ui["lukas-reineke/indent-blankline.nvim"] = {setup = conf.blankline, branch = "lua", opt = true} -- after="nvim-treesitter",

-- replaced by nl fn = "InterestingWords", keys = {"<Leader>k"}
ui["ray-x/vim-interestingwords"] = {opt = true, setup = conf.interestingwords}

ui["dstein64/nvim-scrollview"] = {config = conf.scrollview}

ui["ray-x/aurora"] = {opt = true, config = conf.aurora}
ui["folke/tokyonight.nvim"] = {
  opt = true,
  setup = conf.tokyonight,
  config = function()

    -- vim.cmd [[hi CursorLine guibg=#353644]]

    vim.cmd [[colorscheme tokyonight]]
    vim.cmd [[hi TSCurrentScope guibg=#282338]]
  end
}

-- ui["bluz71/vim-nightfly-guicolors"] = {
--   opt = true,
--   setup = conf.nightfly,
--   config = function()
--     vim.cmd([[colorscheme nightfly]])
--   end
-- }

-- ui['bluz71/vim-moonfly-colors'] = {
--   opt = true,
--   setup = moonfly,
--   config = function()
--     vim.cmd([[colorscheme moonfly]])
--   end
-- }

-- ui["ChristianChiarulli/nvcode-color-schemes.vim"] = {opt = true, config = conf.nvcode}

ui["sainnhe/sonokai"] = {opt = true, config = conf.sonokai}
ui["sainnhe/gruvbox-material"] = {opt = true, config = conf.gruvbox}
-- eddyekofo94/gruvbox-flat.nvim, sainnhe/gruvbox-material
-- ui["npxbr/gruvbox.nvim"] = {
--   opt = true,
--   requires = {'rktjmp/lush.nvim', opt = true},
--   setup = function()
--     vim.cmd([[set background=dark]])
--   end,
--   config = function()
--     vim.cmd([[set background=dark]])
--     vim.cmd('highlight StatusLine gui=reverse guifg=#ebdbb2 guibg=#3c3836')
--     vim.cmd([[colorscheme gruvbox]])
--   end
-- }

-- ui['dracula/vim'] = {
--   opt = true,
--   config = function()
--     vim.cmd([[colorscheme darcula]])
--   end
-- }

ui["rafamadriz/neon"] = {opt = true, config = conf.neon}

ui["/Users/ray.xu/github/zephyr-nvim"] = {opt = true, config = conf.zephyr}
ui["~/github/material_plus.nvim"] = {
  opt = true,
  setup = conf.material,
  config = function()
    require("material").set()
  end
}
return ui
