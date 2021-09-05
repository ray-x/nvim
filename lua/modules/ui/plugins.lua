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
  -- event = "UIEnter",
  -- after = {"aurora"},
  -- config = conf.galaxyline,
  -- requires = {'kyazdani42/nvim-web-devicons'},
  opt = true
}

ui["windwp/windline.nvim"] = {
  event = "UIEnter",
  config = conf.windline,
  -- requires = {'kyazdani42/nvim-web-devicons'},
  opt = true
}

ui["lambdalisue/glyph-palette.vim"] = {}

ui["akinsho/bufferline.nvim"] = {
  config = conf.nvim_bufferline,
  event = "UIEnter",
  diagnostics_update_in_insert = false,
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
-- not so useful...
-- ui["wfxr/minimap.vim"] = {
--   run = ":!cargo install --locked code-minimap",
--   keys = {"<F14>"},
--   cmd = {"Minimap", "MinimapToggle"},
--   setup = conf.minimap
-- }

-- session is better
-- ui['glepnir/dashboard-nvim'] = {
--   config = conf.dashboard
-- }

ui["kyazdani42/nvim-tree.lua"] = {
  cmd = {"NvimTreeToggle", "NvimTreeOpen"},
  -- requires = {'kyazdani42/nvim-web-devicons'},
  setup = conf.nvim_tree
}

ui["lukas-reineke/indent-blankline.nvim"] = {setup = conf.blankline,  opt = true} -- after="nvim-treesitter",

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

ui["projekt0n/github-nvim-theme"] = {
  opt = true,
  config = function()
    -- vim.cmd [[hi CursorLine guibg=#353644]]
    local styles = {'dark', 'dimmed'}
    local v = math.random(1, 2)
    local st = styles[v]
    require('github-theme').setup(
      {
        functionStyle = "bold",
        themeStyle =  st,
        sidebars = {"qf", "vista_kind", "terminal", "packer"},
        colors = {bg_statusline = '#332344'}
      }
    )
  end
}


-- ui["ChristianChiarulli/nvcode-color-schemes.vim"] = {opt = true, config = conf.nvcode}

ui["sainnhe/sonokai"] = {opt = true, config = conf.sonokai}
ui["sainnhe/gruvbox-material"] = {opt = true, config = conf.gruvbox}

-- cant config cursor line
-- ui["rafamadriz/neon"] = {opt = true, config = conf.neon}

ui["~/github/zephyr-nvim"] = {opt = true, config = conf.zephyr}
ui["~/github/material_plus.nvim"] = {
  opt = true,
  setup = conf.material,
  config = function()
    require("material").set()
  end
}
return ui
