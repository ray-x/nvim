-- Utilities for vim.pack management
local fn = vim.fn
local global = require("core.global")
local sep = global.path_sep

local pack_utils = {}

local function pack_roots()
  local data_dir = fn.stdpath("data")
  return {
    data_dir .. sep .. "site" .. sep .. "pack" .. sep .. "ray-x",
    data_dir .. sep .. "pack" .. sep .. "ray-x",
  }
end

local function installed_plugin_locations()
  local plugins = {}

  for _, pack_dir in ipairs(pack_roots()) do
    local start_dir = pack_dir .. sep .. "start"
    local opt_dir = pack_dir .. sep .. "opt"

    if fn.isdirectory(start_dir) == 1 then
      for _, item in ipairs(fn.readdir(start_dir)) do
        table.insert(plugins, {
          name = item,
          type = "start",
          path = start_dir .. sep .. item,
          root = pack_dir,
        })
      end
    end

    if fn.isdirectory(opt_dir) == 1 then
      for _, item in ipairs(fn.readdir(opt_dir)) do
        table.insert(plugins, {
          name = item,
          type = "opt",
          path = opt_dir .. sep .. item,
          root = pack_dir,
        })
      end
    end
  end

  return plugins
end

local function desired_plugin_names()
  local installer = require("core.pack_installer")
  local desired = {}

  for _, spec in ipairs(installer.collect_all_plugins()) do
    local repo = spec[1]
    if type(repo) == "string" then
      desired[repo:match("[^/]+$")] = true
    end
  end

  return desired
end

-- Helper to check if a plugin is installed
function pack_utils.plugin_exists(plugin_name)
  for _, pack_dir in ipairs(pack_roots()) do
    local start_dir = pack_dir .. sep .. "start" .. sep .. plugin_name
    local opt_dir = pack_dir .. sep .. "opt" .. sep .. plugin_name
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

  for _, plugin in ipairs(installed_plugin_locations()) do
    local key = plugin.type .. ":" .. plugin.name
    if not seen[key] then
      seen[key] = true
      table.insert(plugins, { name = plugin.name, type = plugin.type })
    end
  end

  return plugins
end

-- Load a specific optional plugin
function pack_utils.load_plugin(plugin_name)
  vim.cmd("packadd " .. plugin_name)
end

-- Check and install missing plugins
function pack_utils.check_and_install()
  local installer = require("core.pack_installer")
  local pack_loader = require("core.pack_loader"):new()
  local dev_mode = _G.is_dev and _G.is_dev() or false

  -- Load plugins from specs
  local pack = require("core.pack")
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
    local start_dir = pack_dir .. sep .. "start" .. sep .. plugin_name
    local opt_dir = pack_dir .. sep .. "opt" .. sep .. plugin_name

    if fn.isdirectory(start_dir) == 1 then
      return start_dir
    elseif fn.isdirectory(opt_dir) == 1 then
      return opt_dir
    end
  end
  return nil
end

local function sort_plugins(plugins)
  table.sort(plugins, function(a, b)
    if a.name == b.name then
      return a.path < b.path
    end

    return a.name < b.name
  end)
end

-- Remove a plugin
function pack_utils.remove_plugin(plugin_name)
  local removed = {}

  for _, plugin in ipairs(installed_plugin_locations()) do
    if plugin.name == plugin_name and fn.delete(plugin.path, "rf") == 0 then
      table.insert(removed, plugin)
    end
  end

  sort_plugins(removed)

  return removed
end

local function sort_strings(items)
  table.sort(items, function(a, b)
    return a < b
  end)
end

function pack_utils.get_unused_plugins()
  local desired = desired_plugin_names()
  local unused = {}

  for _, plugin in ipairs(installed_plugin_locations()) do
    if not desired[plugin.name] then
      table.insert(unused, plugin)
    end
  end

  sort_plugins(unused)

  return unused
end

-- Clean up old plugins
function pack_utils.cleanup(plugins)
  local removed = {}

  for _, plugin in ipairs(plugins or pack_utils.get_unused_plugins()) do
    if fn.delete(plugin.path, "rf") == 0 then
      table.insert(removed, plugin)
    end
  end

  sort_plugins(removed)

  return removed
end

function pack_utils.get_update_targets(plugin_names)
  local requested = {}
  local targets = {}
  local missing = {}

  if plugin_names ~= nil and #plugin_names > 0 then
    for _, name in ipairs(plugin_names) do
      if type(name) == "string" and name ~= "" then
        requested[name] = false
      end
    end
  end

  for _, plugin in ipairs(installed_plugin_locations()) do
    if vim.tbl_isempty(requested) or requested[plugin.name] ~= nil then
      table.insert(targets, plugin)
      if requested[plugin.name] ~= nil then
        requested[plugin.name] = true
      end
    end
  end

  for name, found in pairs(requested) do
    if not found then
      table.insert(missing, name)
    end
  end

  sort_plugins(targets)
  sort_strings(missing)

  return targets, missing
end

function pack_utils.update_plugins(plugin_names, on_complete)
  local targets, missing = pack_utils.get_update_targets(plugin_names)
  local results = {
    succeeded = {},
    failed = {},
    missing = missing,
  }
  local pending = #targets

  local function finish()
    sort_plugins(results.succeeded)
    sort_plugins(results.failed)
    if on_complete then
      vim.schedule(function()
        on_complete(results)
      end)
    end
  end

  if pending == 0 then
    finish()
    return
  end

  local function complete_plugin(plugin, code, stdout_data, stderr_data)
    local entry = vim.tbl_extend("force", plugin, {
      code = code,
      stdout = stdout_data or "",
      stderr = stderr_data or "",
    })

    if code == 0 then
      table.insert(results.succeeded, entry)
    else
      table.insert(results.failed, entry)
    end

    pending = pending - 1
    if pending == 0 then
      finish()
    end
  end

  for _, plugin in ipairs(targets) do
    local stdout = {}
    local stderr = {}
    local job_id = fn.jobstart({
      "git",
      "-C",
      plugin.path,
      "pull",
      "--ff-only",
      "--quiet",
    }, {
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, data)
        if data then
          vim.list_extend(stdout, data)
        end
      end,
      on_stderr = function(_, data)
        if data then
          vim.list_extend(stderr, data)
        end
      end,
      on_exit = function(_, code)
        complete_plugin(plugin, code, table.concat(stdout, "\n"), table.concat(stderr, "\n"))
      end,
    })

    if job_id <= 0 then
      complete_plugin(plugin, -1, "", "Failed to start git pull job")
    end
  end
end

return pack_utils
