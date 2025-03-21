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

  -- print(vim.inspect(debug.traceback()))
  disable_distribution_plugins()
  leader_map()

  require('core.options')
  -- require('core.mapping')
  require('core.runner')
  require('core.event')
  _G.lprint = require('utils.log').lprint
  local fsz = require('core.lazy_nvim'):boot_strap() or 1024
  -- get file size
  local fsize = vim.fn.getfsize(vim.fn.expand('%:p:f')) or 1
  if fsize >= 10 * 1024 * 1024 then
    return
  end
  if vim.wo.diff then
    vim.wo.wrap = true
    -- default colorschem for diff
    require('modules.ui.galaxy').shine()
    return
  end

  if fsz < 10 * 1024 * 1024 then
    require('core.colorscheme').load_colorscheme()
  end

  require('keymap')
  require('core.commands')
  lprint('load compiled and lazy', uv.now() - start)

  require('core.lazy').setup(fsz)

  lprint('lazy done', uv.now() - start)
  -- require('utils.markdown')
end

load_core()
