local ui = {}
local conf = require("modules.ui.config")

--
local winwidth = function()
  return vim.api.nvim_call_function("winwidth", { 0 })
end

ui["kyazdani42/nvim-web-devicons"] = {}

ui["windwp/windline.nvim"] = {
  -- event = "UIEntwindlineer",
  config = conf.windline,
  -- requires = {'kyazdani42/nvim-web-devicons'},
  opt = true,
}

ui["lambdalisue/glyph-palette.vim"] = {}
ui["rcarriga/nvim-notify"] = {
  opt = true,
  -- event = "User LoadLazyPlugin",
  config = conf.notify,
}
ui["akinsho/bufferline.nvim"] = {
  config = conf.nvim_bufferline,
  event = "UIEnter",
  diagnostics_update_in_insert = false,
  -- after = {"aurora"}
  -- requires = {'kyazdani42/nvim-web-devicons'}
  opt = true,
}

ui["kyazdani42/nvim-tree.lua"] = {
  cmd = { "NvimTreeToggle", "NvimTreeOpen" },
  -- requires = {'kyazdani42/nvim-web-devicons'},
  setup = conf.nvim_tree_setup,
  config = conf.nvim_tree,
}

ui["sidebar-nvim/sidebar.nvim"] = {
  cmd = { "SidebarNvimToggle", "SidebarNvimOpen" },
  -- requires = {'kyazdani42/nvim-web-devicons'},
  config = conf.sidebar,
}

ui["nvim-neo-tree/neo-tree.nvim"] = {
  cmd = { "Neotree" },
  requires = { "MunifTanjim/nui.nvim" },
  module = "neo-tree",
  -- requires = {'kyazdani42/nvim-web-devicons'},
  config = conf.neo_tree,
}

ui["lukas-reineke/indent-blankline.nvim"] = { opt = true, config = conf.blankline } -- after="nvim-treesitter",

-- disabled does not work with muliti split
ui["lukas-reineke/virt-column.nvim"] = {
  opt = true,
  -- event = {"CursorMoved", "CursorMovedI"},
  config = function()
    vim.cmd("highlight clear ColorColumn")
    require("virt-column").setup()

    vim.cmd("highlight VirtColumn guifg=#4358BF")
  end,
}

ui["dstein64/nvim-scrollview"] = { event = { "CursorMoved", "CursorMovedI" }, config = conf.scrollview }

ui[plugin_folder() .. "aurora"] = { opt = true, config = conf.aurora }
ui["folke/tokyonight.nvim"] = {
  opt = true,
  setup = conf.tokyonight,
  config = function()
    -- vim.cmd [[hi CursorLine guibg=#353644]]
    vim.cmd([[colorscheme tokyonight]])
    vim.cmd([[hi TSCurrentScope guibg=#282338]])
  end,
}

ui["projekt0n/github-nvim-theme"] = {
  opt = true,
  config = conf.gh_theme,
}

ui["sainnhe/sonokai"] = { opt = true, config = conf.sonokai }
ui["sainnhe/gruvbox-material"] = { opt = true, config = conf.gruvbox }
ui["catppuccin/nvim"] = {
  opt = true,
  as = "catppuccin",
  config = conf.cat,
}

ui[plugin_folder() .. "starry.nvim"] = {
  opt = true,
  setup = conf.starry,
  config = function()
    require("starry").set()
  end,
}

-- really good one, only issue is dependency ...
ui["gelguy/wilder.nvim"] = {
  requires = {
    { "romgrk/fzy-lua-native" },
    -- {'nixprime/cpsm', run='UpdateRemotePlugins'}
  },
  opt = true,
  run = "UpdateRemotePlugins",
  event = { "CmdwinEnter", "CmdlineEnter" },
  config = conf.wilder,
}

return ui
