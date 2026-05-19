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

lprint('pack runtime begin', vim.uv.now() - require('core.global').start)
local loader = require('utils.helper').loader

local global = require('core.global')

function setup(fsize)
  require('core.helper').init()
  local start = require('core.global').start

  lprint('pack core plugins start', vim.uv.now() - start)
  lprint('pack runtime', vim.uv.now() - start)

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
    vim.g.disable_plugins = {'nvim-tree/nvim-tree.lua', 'lukas-reineke/indent-blankline.nvim',
    'neovim-treesitter/nvim-treesitter', 'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-context', 'nvim-treesitter/nvim-ts-rainbow', 'nvim-treesitter/nvim-ts-autotag',
    'nvim-treesitter/nvim-ts-rainbow2', 'nvim-treesitter/nvim-ts-context-commentstring', 'echasnovski/mini.surround',
    'echasnovski/mini.comment', 'echasnovski/mini.pairs', 'echasnovski/mini.indentscope',
    'echasnovski/mini.trailspace', 'telescope-nvim/telescope.nvim', 'akinsho/bufferline.nvim',}
    vim.g.disable_modules = 'completion,tools'
  end

  vim.cmd([[doautocmd User LoadPackPlugin]])
  vim.cmd('tabdo windo set relativenumber')
  lprint('pack colorscheme loaded', vim.uv.now() - start)
end

require('modules.ui.notify').setup()

if argc > 0 and vim.fn.isdirectory(vim.fn.argv()[1]) == 1 then
  loader('telescope.nvim')
  loader('telescope-file-browser.nvim')
end

if vim.fn.executable(vim.g.python3_host_prog) == 0 then
  print('file not find, please update path setup', vim.g.python3_host_prog)
end
require('core.ab')

if plugin_folder() == [[~/github/ray-x/]] then
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
end

vim.cmd('set runtimepath+=/usr/share/vim/vimfiles')
vim.cmd('runtime! plugin/fzf.vim')

local function current_session_name()
  local root = _G.FindRoot and _G.FindRoot() or vim.fn.getcwd()
  return require('utils.selfunc').convertPathToPercentString(root) .. '.vim'
end

local function should_restore_session()
  if vim.fn.argc() > 0 then
    return false
  end

  local listed_buffers = vim.tbl_filter(function(buf_id)
    return vim.fn.buflisted(buf_id) == 1
  end, vim.api.nvim_list_bufs())

  if #listed_buffers > 1 then
    return false
  end

  if #listed_buffers == 1 then
    local buf_id = listed_buffers[1]
    if vim.api.nvim_buf_get_name(buf_id) ~= '' or vim.bo[buf_id].modified then
      return false
    end
  end

  return true
end

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    if not should_restore_session() then
      return
    end

    local ok, sessions = pcall(require, 'mini.sessions')
    if not ok then
      return
    end

    local session_name = current_session_name()
    local session_path = vim.fn.stdpath('data') .. '/session/' .. session_name

    if vim.fn.filereadable(session_path) == 1 then
      lprint('auto-session load', session_name)
      sessions.read(session_name, { force = true })
    else
      lprint('auto-session create', session_name)
      sessions.write(session_name, { force = true })
    end
  end,
})

return { setup = setup }
