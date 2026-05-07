-- Utilities for vim.pack management
local fn = vim.fn
local helper = require('core.helper')
local global = require('core.global')
local sep = global.path_sep

local pack_utils = {}

local function pack_roots()
  local data_dir = fn.stdpath('data')
  return {
    data_dir .. sep .. 'site' .. sep .. 'pack' .. sep .. 'ray-x',
    data_dir .. sep .. 'pack' .. sep .. 'ray-x',
  }
end

-- Helper to check if a plugin is installed
function pack_utils.plugin_exists(plugin_name)
  for _, pack_dir in ipairs(pack_roots()) do
    local start_dir = pack_dir .. sep .. 'start' .. sep .. plugin_name
    local opt_dir = pack_dir .. sep .. 'opt' .. sep .. plugin_name
    if fn.isdirectory(start_dir) == 1 or fn.isdirectory(opt_dir) == 1 then
      return true
    end
  end
  return false
end

-- Get all installed plugins
function pack_utils.get_installed_plugins()
  local plugins = {}
  local seen = {}

  for _, pack_dir in ipairs(pack_roots()) do
    local start_dir = pack_dir .. sep .. 'start'
    local opt_dir = pack_dir .. sep .. 'opt'

    if fn.isdirectory(start_dir) == 1 then
      local items = fn.readdir(start_dir)
      for _, item in ipairs(items) do
        local key = 'start:' .. item
        if not seen[key] then
          seen[key] = true
          table.insert(plugins, { name = item, type = 'start' })
        end
      end
    end

    if fn.isdirectory(opt_dir) == 1 then
      local items = fn.readdir(opt_dir)
      for _, item in ipairs(items) do
        local key = 'opt:' .. item
        if not seen[key] then
          seen[key] = true
          table.insert(plugins, { name = item, type = 'opt' })
        end
      end
    end
  end

  return plugins
end

-- Load a specific optional plugin
function pack_utils.load_plugin(plugin_name)
  vim.cmd('packadd ' .. plugin_name)
end

-- Check and install missing plugins
function pack_utils.check_and_install()
  local installer = require('core.pack_installer')
  local pack_loader = require('core.pack_loader'):new()
  local dev_mode = _G.is_dev and _G.is_dev() or false

  -- Load plugins from specs
  local pack = require('core.pack')
  if pack.plug then
    for _, spec in ipairs(pack.plug) do
      pack_loader:register_plugin(spec)
    end
  end

  -- Install any missing plugins
  installer.install_all_plugins(pack_loader.pack_dir, dev_mode)
end

-- Get plugin directory
function pack_utils.get_plugin_dir(plugin_name)
  for _, pack_dir in ipairs(pack_roots()) do
    local start_dir = pack_dir .. sep .. 'start' .. sep .. plugin_name
    local opt_dir = pack_dir .. sep .. 'opt' .. sep .. plugin_name

    if fn.isdirectory(start_dir) == 1 then
      return start_dir
    elseif fn.isdirectory(opt_dir) == 1 then
      return opt_dir
    end
  end
  return nil
end

-- Remove a plugin
function pack_utils.remove_plugin(plugin_name)
  local plugin_dir = pack_utils.get_plugin_dir(plugin_name)
  if plugin_dir then
    os.execute('rm -rf "' .. plugin_dir .. '"')
    return true
  end
  return false
end

-- Clean up old plugins
function pack_utils.cleanup()
  -- This would be used to remove plugins no longer in the plugin list
  -- For now, just a placeholder
end

return pack_utils
