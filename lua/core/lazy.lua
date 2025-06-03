local api = vim.api
local argc = vim.fn.argc() or 0

if argc > 0 then
  local arg = vim.fn.argv()
  for i = 1, argc do
    if arg[i] == '--headless' then
      return
    end
  end
  if arg[1] and vim.fn.isdirectory(arg[1]) == 1 then
    vim.defer_fn(function()
      require('telescope').extensions.file_browser.file_browser()
    end, 200)
  end
end

lprint('I am lazy begin', vim.loop.now() - require('core.global').start)
local loader = require('utils.helper').loader

-- Create cache dir and subs dir
local global = require('core.global')
-- load module but not init/config it
function setup(fsize)
  require('core.helper').init()
  local start = require('core.global').start

  lprint('lazy core plugins start', vim.loop.now() - start)
  lprint('I am lazy', vim.loop.now() - start)
  local disable_ft = {
    'NvimTree',
    'guihua',
    'neo-tree',
    'packer',
    'guihua_rust',
    'clap_input',
    'clap_spinner',
    'TelescopePrompt',
    'csv',
    'txt',
    'defx',
  }

  if fsize == nil or fsize < 0 then
    fsize = 4096
  end

  vim.g.vimsyn_embed = 'lPr'
  if fsize >= 1024 * 1024 then
    vim.opt_local.swapfile = false
    vim.opt_local.foldmethod = 'manual'
    vim.opt_local.undolevels = -1
    vim.opt_local.undoreload = 0
    vim.opt_local.list = false
    vim.opt_local.spell = false
    -- vim.g.disable_plugins = {'indent_blankline','nvim-tree','nvim-web-devicons','telescope.nvim','telescope-file-browser.nvim','mini.sessions','nvim-treesitter','nvim-treesitter-textobjects','nvim-treesitter-context','nvim-ts-rainbow','nvim-ts-autotag','nvim-ts-rainbow2','nvim-ts-context-commentstring','mini.surround','mini.comment','mini.pairs','mini.indentscope','mini.trailspace','navigator'}
    vim.g.disable_plugins = {'nvim-tree/nvim-tree.lua', 'lukas-reineke/indent-blankline.nvim',
    'nvim-treesitter/nvim-treesitter', 'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-context', 'nvim-treesitter/nvim-ts-rainbow', 'nvim-treesitter/nvim-ts-autotag',
    'nvim-treesitter/nvim-ts-rainbow2', 'nvim-treesitter/nvim-ts-context-commentstring', 'echasnovski/mini.surround',
    'echasnovski/mini.comment', 'echasnovski/mini.pairs', 'echasnovski/mini.indentscope',
    'echasnovski/mini.trailspace', 'telescope-nvim/telescope.nvim', 'akinsho/bufferline.nvim',}
    vim.g.disable_modules = 'completion,tools'
  end

  vim.cmd([[doautocmd User LoadLazyPlugin]])
  vim.cmd('tabdo windo set relativenumber')
  -- vim.cmd('highlight clear ColorColumn')
  -- vim.cmd("command! Gram lua require'modules.tools.config'.grammcheck()")
  lprint('lazy colorscheme loaded', vim.uv.now() - start)
end

local lazy_timer = 20

--

require('modules.ui.notify').setup()
-- vim.notify = require('notify')

if vim.fn.isdirectory(arg[1]) == 1 then
  loader('telescope.nvim')
  loader('telescope-file-browser.nvim')
end
-- lprint("all done", os.clock())
if vim.fn.executable(vim.g.python3_host_prog) == 0 then
  print('file not find, please update path setup', vim.g.python3_host_prog)
end
require('core.ab')

if plugin_folder() == [[~/github/ray-x/]] then
  -- it is my own box, setup fish
  if vim.o.shell ~= 'fish' and vim.fn.executable('fish') == 1 then
    if global.is_mac then
      vim.cmd([[set shell=/opt/homebrew/bin/fish]])
    elseif global.is_linux then
      vim.cmd([[set shell=/usr/bin/fish]])
    else
      vim.cmd([[set shell=sh ]])
    end
    vim.cmd([[command! GD term gd]])
  end
  -- vim.cmd([[set shell=/usr/bin/fish]])
end

vim.cmd('set runtimepath+=/usr/share/vim/vimfiles')
vim.cmd('runtime! plugin/fzf.vim')

vim.defer_fn(function()
  if vim.fn.empty(vim.fn.expand('%')) == 1 then
    local folder = vim.fn.getcwd()
    folder = require('utils.selfunc').convertPathToPercentString(folder) .. '.vim'
    lprint('auto-session load', folder)
    local r = require('mini.sessions').read
    pcall(r, folder)

    lprint('auto-session loaded', folder, vim.fn.empty(folder))
    if vim.fn.empty(vim.v.this_session) == 1 then
      lprint('no session folder found')
      lprint('save session to ' .. folder)
      require('mini.sessions').write(folder)
    end
  end
end, lazy_timer)
return { setup = setup }
