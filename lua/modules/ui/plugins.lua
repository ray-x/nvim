local ui = {}
local conf = require('modules.ui.config')

-- ui['glepnir/zephyr-nvim'] = {
--   config = [[vim.cmd('colorscheme zephyr')]]
-- }
--
local winwidth = function ()
  return vim.api.nvim_call_function('winwidth', {0})
end

ui['kyazdani42/nvim-web-devicons'] = {}
ui['glepnir/galaxyline.nvim'] = {
  branch = 'main',
  -- event = 'UIEnter',
  after = {'aurora'},
  config = conf.galaxyline,
  -- requires = {'kyazdani42/nvim-web-devicons'},
  opt = true,
}

ui['Akin909/nvim-bufferline.lua'] = {
  config = conf.nvim_bufferline,
  -- event = 'UIEnter',
  after = {'aurora'},
  -- requires = {'kyazdani42/nvim-web-devicons'}
}
-- 'luaromgrk/barbar.nvim'
-- ui['romgrk/barbar.nvim'] = {
--   config = conf.barbar,
--   requires = {'kyazdani42/nvim-web-devicons'}
-- }
--

ui['wfxr/minimap.vim'] = {
  run = ':!cargo install --locked code-minimap',
  keys = {'<F14>'},
  cmd = {'Minimap', 'MinimapToggle'},
  setup = conf.minimap
}
-- ui['glepnir/dashboard-nvim'] = {
--   config = conf.dashboard
-- }

ui['kyazdani42/nvim-tree.lua'] = {
  cmd = {'NvimTreeToggle','NvimTreeOpen'},
  -- requires = {'kyazdani42/nvim-web-devicons'},
  setup = conf.nvim_tree,
}


ui['lukas-reineke/indent-blankline.nvim'] = {setup=conf.blankline, branch = 'lua', opt = true} --after="nvim-treesitter", 

-- replaced by nl
ui['ray-x/vim-interestingwords'] = { keys =  {'<Leader>u'}, config = conf.interestingwords, opt = true}

ui['ray-x/aurora'] = {event = 'VimEnter', config = conf.theme}

ui['dstein64/nvim-scrollview'] = {config = conf.scrollview}
return ui
