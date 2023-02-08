local fn, uv, api = vim.fn, vim.loop, vim.api
local vim_path = require('core.global').vim_path
local path_sep = require('core.global').path_sep
local data_dir = require('core.global').data_dir
-- local home = require('core.global').home
local modules_dir = vim_path .. path_sep .. 'lua' .. path_sep .. 'modules'
-- local packer_compiled = data_dir .. 'packer_compiled.vim'
local packer_compiled = data_dir .. 'lua' .. path_sep .. 'packer_compiled.lua'
local packer = nil

local Packer = {}
Packer.__index = Packer

function Packer:load_plugins(use)
  if not packer then
    return
  end
  use = use or packer.use

  use({ 'wbthomason/packer.nvim' })
  use({
    'lewis6991/impatient.nvim',
    opt = true,
    config = function()
      require('impatient')
    end,
  })
  local get_plugins_list = function()
    local list = {}
    local tmp = vim.split(fn.globpath(modules_dir, '*' .. path_sep .. 'plugins.lua'), '\n')
    for _, f in ipairs(tmp) do
      list[#list + 1] = string.match(f, 'lua' .. path_sep .. '(.+).lua$')
    end
    return list
  end

  local plugins_file = get_plugins_list()
  for _, m in ipairs(plugins_file) do
    require(m)(use)
  end
end

function Packer:load_packer()
  if not packer then
    vim.cmd('packadd packer.nvim')
    packer = require('packer')
  end
  packer.init({
    compile_path = packer_compiled,
    git = { clone_timeout = 240 },
    disable_commands = true,
  })
  packer.reset()
  local use = packer.use
end

local ensure_packer = function()
  local fn = vim.fn
  local install_path = data_dir
    .. 'pack'
    .. path_sep
    .. 'packer'
    .. path_sep
    .. 'start'
    .. path_sep
    .. 'packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      'git',
      'clone',
      '--depth',
      '1',
      'https://github.com/wbthomason/packer.nvim',
      install_path,
    })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

function Packer:init_ensure_plugins()
  if not packer then
    vim.cmd('packadd packer.nvim')
    packer = require('packer')
    packer.init({
      compile_path = packer_compiled,
      git = { clone_timeout = 240 },
      disable_commands = true,
    })
  end

  return require('packer').startup(function(use)
    self:load_plugins(packer.use)
    if packer_bootstrap then
      packer.sync()
    end
  end)
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not packer then
      Packer:load_packer()
    end
    return packer[key]
  end,
})

function plugins.ensure_plugins()
  return Packer:init_ensure_plugins()
end

function plugins.compile_notify()
  plugins.compile()
  vim.notify('Compile Done!', 'info', { title = 'Packer' })
end

function plugins.auto_compile()
  local file = vim.fn.expand('%:p')
  if file:match(modules_dir) or file:match(vim.fn.stdpath('config')) then
    plugins.clean()
    plugins.compile()
  end
  vim.cmd([[silent UpdateRemotePlugins]])
  require('packer_compiled')
end

function plugins.compile_loader()
  plugins.clean()
  plugins.compile()
  vim.cmd([[silent UpdateRemotePlugins]])
end

function plugins.precompile_existed()
  return true
end

function plugins.precompile_file()
  return packer_compiled
end
function plugins.load_compile()
end

return plugins
