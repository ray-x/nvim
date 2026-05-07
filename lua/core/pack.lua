-- vim.pack bootstrap
local uv, fn = vim.uv, vim.fn
local helper = require('core.helper')
local global = require('core.global')
local win = global.is_windows
local pack = {}
pack.__index = pack
local start = global.start
local sep = global.path_sep

-- Plugin specification accumulator.
function pack.add(repo)
  if not repo then
    return
  end
  if not pack.plug then
    pack.plug = {}
  end
  if repo.lazy == nil then
    repo.lazy = true
  end
  if vim.g.disable_plugins and vim.tbl_contains(vim.g.disable_plugins, repo[1]) then
    repo.lazy = true
    repo.cond = false
  end
  table.insert(pack.plug, repo)
end

local createdir = function()
  local data_dir = {
    global.cache_dir .. sep .. 'backup',
    global.cache_dir .. sep .. 'sessions',
    global.cache_dir .. sep .. 'swap',
    global.cache_dir .. sep .. 'tags',
    global.cache_dir .. sep .. 'undo',
  }
  for _, v in pairs(data_dir) do
    if fn.isdirectory(v) == 0 then
      os.execute('mkdir -p ' .. v)
    end
  end
end

function pack:load_modules_pack()
  createdir()
  if not win then
    vim.loader.enable()
  end
  local modules_dir = helper.get_config_path() .. sep .. 'lua' .. sep .. 'modules'
  self.plug = {}

  local plugins_list = {
    modules_dir .. sep .. 'completion' .. sep .. 'plugins.lua',
    modules_dir .. sep .. 'lang' .. sep .. 'plugins.lua',
    modules_dir .. sep .. 'ui' .. sep .. 'plugins.lua',
    modules_dir .. sep .. 'editor' .. sep .. 'plugins.lua',
    modules_dir .. sep .. 'tools' .. sep .. 'plugins.lua',
  }

  if vim.g.vscode then
    plugins_list = {
      modules_dir .. sep .. 'editor' .. sep .. 'plugins.lua',
      modules_dir .. sep .. 'tools' .. sep .. 'plugins.lua',
    }
  end

  local disable_modules = {}
  if fn.exists('g:disable_modules') == 1 then
    disable_modules = vim.split(vim.g.disable_modules, ',')
  end

  for _, f in pairs(plugins_list) do
    if win then
      f = string.gsub(f, '/', '\\')
    end
    local _, pos = f:find(modules_dir)
    if pos then
      f = f:sub(pos - 6, #f - 4)
    end
    if not vim.tbl_contains(disable_modules, f) then
      local plugins = require(f)
      plugins(pack.add)
      lprint('loaded ' .. f, vim.uv.now() - start)
    end
  end
  lprint('pack modules loaded', vim.uv.now() - start)
end

function pack:boot_strap()
  local fsize = vim.fn.getfsize(vim.fn.expand('%:p:f'))
  if fsize == nil or fsize < 0 then
    fsize = 1
  end
  if fsize > 10 * 1024 * 1024 then
    return fsize
  end

  local start_time = uv.now()
  self:load_modules_pack()
  lprint('pack bootstrap start', vim.uv.now() - start_time)

  local pack_loader = require('core.pack_loader'):new()
  pack_loader:create_directories()

  for _, plugin_spec in ipairs(self.plug) do
    pack_loader:register_plugin(plugin_spec)
  end

  local installer = require('core.pack_installer')
  local dev_mode = _G.is_dev and _G.is_dev() or false
  installer.install_all_plugins(pack_loader.pack_dir, dev_mode)

  pack_loader:init()
  lprint('pack bootstrap complete', vim.uv.now() - start_time)

  package.path = package.path .. ';' .. vim.fn.expand('$HOME') .. '/.luarocks/share/lua/5.1/?/init.lua'
  package.path = package.path .. ';' .. vim.fn.expand('$HOME') .. '/.luarocks/share/lua/5.1/?.lua'

  return fsize
end

return pack
