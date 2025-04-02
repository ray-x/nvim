local vim = vim
local uv = vim.uv or vim.loop
local start = uv.now()

local disable_distribution_plugins = function()
  vim.g.loaded_gzip = 1
  vim.g.loaded_tar = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_zip = 1
  vim.g.loaded_zipPlugin = 1
  vim.g.loaded_getscript = 1
  vim.g.loaded_getscriptPlugin = 1
  vim.g.loaded_vimball = 1
  vim.g.loaded_vimballPlugin = 1
  vim.g.loaded_matchit = 1
  vim.g.loaded_matchparen = 1
  vim.g.loaded_2html_plugin = 1
  vim.g.loaded_logiPat = 1
  vim.g.loaded_rrhelper = 1
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_netrwSettings = 1
  vim.g.loaded_netrwFileHandlers = 1
  vim.g.skip_ts_context_commentstring_module = true
end

local leader_map = function()
  vim.g.mapleader = '\\'
  vim.api.nvim_set_keymap('n', ' ', '', { noremap = true })
  vim.api.nvim_set_keymap('x', ' ', '', { noremap = true })
end

local load_core = function()
  require('core.helper').init()

  _G.lprint = require('utils.log').lprint
  -- print(vim.inspect(debug.traceback()))
  disable_distribution_plugins()
  leader_map()
  lprint('load core')

  require('core.options')
  require('core.runner')
  require('core.event')
  local fsize = require('core.lazy_nvim'):boot_strap() or 10
  -- get file size
  lprint('load core done', uv.now() - start)
  local theme
  if fsize >= 10 * 1024 * 1024 then
    lprint('file size too large, skip loading')
    theme = 'galaxy'
  end
  if vim.wo.diff then
    vim.wo.wrap = true
    -- default colorschem for diff
    require('modules.ui.galaxy').shine()
    return
  end

  require('core.colorscheme').load_colorscheme(theme)
  require('keymap')
  require('core.commands')
  lprint('load compiled and lazy', uv.now() - start)

  if fsize >= 1 * 1024 * 1024 then
    vim.g.large_file = true
  end
  if fsize >= 4 * 1024 * 1024 then
    vim.g.huge_file = true
  end
  require('core.lazy').setup(fsize)

  lprint('lazy done', uv.now() - start)
end

load_core()
