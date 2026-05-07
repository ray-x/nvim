-- vim.pack loader - replaces lazy.nvim
-- Handles plugin loading, event-based activation, and dependency management
local uv, api, fn = vim.uv, vim.api, vim.fn
local helper = require("core.helper")
local global = require("core.global")
local sep = global.path_sep

local pack_loader = {}
pack_loader.__index = pack_loader

local function pack_verbose()
  return vim.g.pack_verbose == 1 or vim.g.pack_verbose == true
end

local function pack_log(msg, t)
  if pack_verbose() then
    lprint(msg, t)
  end
end

local function pack_warn(msg)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.WARN)
  end)
end

local function resolve_opts(plugin_info)
  local opts = plugin_info.opts
  if opts == nil then
    return nil, true
  end

  if type(opts) == "function" then
    local ok, resolved = pcall(opts, plugin_info)
    if not ok then
      pack_warn("pack opts failed for " .. plugin_info.name .. ": " .. tostring(resolved))
      return nil, false
    end
    opts = resolved
  end

  if opts == nil or opts == true then
    return {}, true
  end

  if type(opts) ~= "table" then
    return {}, true
  end

  return opts, true
end

local function setup_module_candidates(plugin_info)
  local candidates = {}
  local seen = {}

  local function add(candidate)
    if type(candidate) ~= "string" or candidate == "" or seen[candidate] then
      return
    end
    seen[candidate] = true
    table.insert(candidates, candidate)
  end

  add(plugin_info.main)

  local name = plugin_info.name or ""
  local trimmed = name:gsub("%.nvim$", ""):gsub("%.lua$", "")
  local stripped = trimmed:gsub("^nvim%-", ""):gsub("%-nvim$", "")

  add(trimmed)
  add(stripped)
  add(trimmed:gsub("%-", "_"))
  add(stripped:gsub("%-", "_"))
  add(trimmed:gsub("%-", "."))
  add(stripped:gsub("%-", "."))

  return candidates
end

local function run_default_opts_setup(plugin_info, resolved_opts)
  local opts = resolved_opts
  if opts == nil then
    local ok
    opts, ok = resolve_opts(plugin_info)
    if not ok then
      return
    end
  end

  for _, module_name in ipairs(setup_module_candidates(plugin_info)) do
    local loaded, mod = pcall(require, module_name)
    if loaded then
      if type(mod) == "table" and type(mod.setup) == "function" then
        local setup_ok, setup_err = pcall(mod.setup, opts or {})
        if not setup_ok then
          pack_warn("pack setup failed for " .. plugin_info.name .. ": " .. tostring(setup_err))
        end
        return
      end
      if type(mod) == "function" then
        local setup_ok, setup_err = pcall(mod, opts or {})
        if not setup_ok then
          pack_warn("pack setup failed for " .. plugin_info.name .. ": " .. tostring(setup_err))
        end
        return
      end
    end
  end

  if pack_verbose() then
    pack_warn("pack could not infer setup module for " .. plugin_info.name .. "; set config or main")
  end
end

-- State tracking
local plugins_by_event = {}
local plugins_by_command = {}
local plugins_by_filetype = {}
local plugins_by_module = {}
local loaded_plugins = {}
local loading_in_progress = {}

local function as_list(value)
  if value == nil then
    return {}
  end
  return type(value) == "table" and value or { value }
end

local function extend_unique(dst, values)
  local seen = {}
  for _, item in ipairs(as_list(dst)) do
    seen[item] = true
  end

  for _, item in ipairs(as_list(values)) do
    if item ~= nil and not seen[item] then
      table.insert(dst, item)
      seen[item] = true
    end
  end

  return dst
end

local function merge_plugin_info(existing, incoming)
  existing.lazy = existing.lazy and incoming.lazy
  existing.event = extend_unique(as_list(existing.event), incoming.event)
  existing.cmd = extend_unique(as_list(existing.cmd), incoming.cmd)
  existing.ft = extend_unique(as_list(existing.ft), incoming.ft)
  existing.module = extend_unique(as_list(existing.module), incoming.module)
  existing.keys = existing.keys or incoming.keys
  existing.cond = incoming.cond ~= nil and incoming.cond or existing.cond
  existing.main = existing.main or incoming.main
  existing.opts = existing.opts or incoming.opts
  existing.config = existing.config or incoming.config
  existing.dependencies = existing.dependencies or incoming.dependencies
  existing.dev = existing.dev or incoming.dev
  existing.build = existing.build or incoming.build
  return existing
end

local function index_plugin(plugin_info)
  for _, evt in ipairs(as_list(plugin_info.event)) do
    if not plugins_by_event[evt] then
      plugins_by_event[evt] = {}
    end
    if not vim.tbl_contains(plugins_by_event[evt], plugin_info) then
      table.insert(plugins_by_event[evt], plugin_info)
    end
  end

  for _, cmd in ipairs(as_list(plugin_info.cmd)) do
    if not plugins_by_command[cmd] then
      plugins_by_command[cmd] = {}
    end
    if not vim.tbl_contains(plugins_by_command[cmd], plugin_info) then
      table.insert(plugins_by_command[cmd], plugin_info)
    end
  end

  for _, ft in ipairs(as_list(plugin_info.ft)) do
    if not plugins_by_filetype[ft] then
      plugins_by_filetype[ft] = {}
    end
    if not vim.tbl_contains(plugins_by_filetype[ft], plugin_info) then
      table.insert(plugins_by_filetype[ft], plugin_info)
    end
  end

  for _, mod in ipairs(as_list(plugin_info.module)) do
    if not plugins_by_module[mod] then
      plugins_by_module[mod] = plugin_info
    end
  end
end

local function command_exists_exact(cmd)
  for _, name in ipairs(fn.getcompletion(cmd, "command")) do
    if name == cmd then
      return true
    end
  end
  return false
end

local function cond_allows(cond, plugin_name)
  if cond == nil then
    return true
  end

  if type(cond) == "function" then
    local ok, allowed = pcall(cond)
    if not ok then
      pack_warn("pack cond failed for " .. plugin_name .. ": " .. tostring(allowed))
      return false
    end
    return not not allowed
  end

  return cond ~= false
end

function pack_loader:new()
  local self = setmetatable({}, pack_loader)
  self.plugins = {}
  self.plugins_by_name = {}
  local data_dir = fn.stdpath("data")
  self.pack_dir = data_dir .. sep .. "site" .. sep .. "pack" .. sep .. "ray-x"
  self.legacy_pack_dir = data_dir .. sep .. "pack" .. sep .. "ray-x"
  self.start_dir = self.pack_dir .. sep .. "start"
  self.opt_dir = self.pack_dir .. sep .. "opt"
  self.legacy_start_dir = self.legacy_pack_dir .. sep .. "start"
  self.legacy_opt_dir = self.legacy_pack_dir .. sep .. "opt"

  -- Keep compatibility with earlier installs under stdpath('data')/pack.
  local packpath = vim.o.packpath or ""
  if not string.find(packpath, data_dir, 1, true) then
    vim.opt.packpath:append(data_dir)
  end

  return self
end

-- Create pack directory structure
function pack_loader:create_directories()
  for _, dir in ipairs({ self.start_dir, self.opt_dir }) do
    if fn.isdirectory(dir) == 0 then
      fn.mkdir(dir, "p")
    end
  end
end

-- Register a plugin from lazy.nvim spec
function pack_loader:register_plugin(spec)
  if not spec or not spec[1] then
    return
  end

  local name = spec[1]:match("[^/]+$")
  local plugin_info = {
    name = name,
    repo = spec[1],
    lazy = spec.lazy ~= false,
    event = spec.event,
    cmd = spec.cmd,
    ft = spec.ft,
    keys = spec.keys,
    module = spec.module,
    cond = spec.cond,
    main = spec.main,
    opts = spec.opts,
    config = spec.config,
    dependencies = spec.dependencies,
    dev = spec.dev,
    build = spec.build,
  }

  -- Disable check
  if vim.g.disable_plugins and vim.tbl_contains(vim.g.disable_plugins, spec[1]) then
    plugin_info.lazy = true
    plugin_info.cond = false
  end

  if not cond_allows(plugin_info.cond, plugin_info.name) then
    return
  end

  local existing = self.plugins_by_name[name]
  if existing then
    plugin_info = merge_plugin_info(existing, plugin_info)
  else
    table.insert(self.plugins, plugin_info)
    self.plugins_by_name[name] = plugin_info
  end

  index_plugin(plugin_info)

  -- Register nested dependencies so their lazy-load triggers (cmd/event/ft/module)
  -- are available even when they are only referenced from a parent spec.
  local deps = spec.dependencies
  if type(deps) == "table" then
    for _, dep in ipairs(deps) do
      if type(dep) == "string" then
        self:register_plugin({ dep, lazy = true })
      elseif type(dep) == "table" and dep[1] then
        self:register_plugin(dep)
      end
    end
  elseif type(deps) == "string" then
    self:register_plugin({ deps, lazy = true })
  end
end

-- Get plugin path in pack directory
function pack_loader:get_plugin_path(plugin_info)
  -- Lazy plugins go to opt/, others go to start/
  if not cond_allows(plugin_info.cond, plugin_info.name) then
    return nil -- Plugin is disabled
  end

  local is_lazy = plugin_info.lazy == true
  local base_dir = is_lazy and self.opt_dir or self.start_dir
  local plugin_path = base_dir .. sep .. plugin_info.name
  if fn.isdirectory(plugin_path) == 1 then
    return plugin_path
  end

  -- Backward compatibility for old install path.
  local legacy_base = is_lazy and self.legacy_opt_dir or self.legacy_start_dir
  local legacy_path = legacy_base .. sep .. plugin_info.name
  if fn.isdirectory(legacy_path) == 1 then
    return legacy_path
  end

  return plugin_path
end

function pack_loader:load_by_name(plugin_name, origin)
  if loaded_plugins[plugin_name] then
    return true
  end

  local opt_path = self.opt_dir .. sep .. plugin_name
  local start_path = self.start_dir .. sep .. plugin_name
  local legacy_opt_path = self.legacy_opt_dir .. sep .. plugin_name
  local legacy_start_path = self.legacy_start_dir .. sep .. plugin_name

  if
    fn.isdirectory(opt_path) ~= 1
    and fn.isdirectory(start_path) ~= 1
    and fn.isdirectory(legacy_opt_path) ~= 1
    and fn.isdirectory(legacy_start_path) ~= 1
  then
    return false
  end

  local ok = pcall(function()
    vim.cmd("packadd " .. plugin_name)
  end)
  if ok then
    loaded_plugins[plugin_name] = true
    pack_log("Loaded plugin: " .. plugin_name .. " (" .. origin .. ")", vim.uv.now() - require("core.global").start)
  end
  return ok
end

-- Ensure plugin is loaded
function pack_loader:ensure_loaded(plugin_info, origin)
  if loaded_plugins[plugin_info.name] or loading_in_progress[plugin_info.name] then
    return
  end

  if not cond_allows(plugin_info.cond, plugin_info.name) then
    return
  end

  loading_in_progress[plugin_info.name] = true

  -- Load dependencies first
  if plugin_info.dependencies then
    local deps = type(plugin_info.dependencies) == "table" and plugin_info.dependencies or { plugin_info.dependencies }
    for _, dep_spec in ipairs(deps) do
      local dep_name = (type(dep_spec) == "string" and dep_spec or dep_spec[1]):match("[^/]+$")
      local dep_loaded = false
      for _, plugin in ipairs(self.plugins) do
        if plugin.name == dep_name then
          self:ensure_loaded(plugin, "dependency")
          dep_loaded = true
          break
        end
      end
      if not dep_loaded then
        self:load_by_name(dep_name, "dependency")
      end
    end
  end

  local plugin_path = self:get_plugin_path(plugin_info)
  if not plugin_path or fn.isdirectory(plugin_path) ~= 1 then
    loading_in_progress[plugin_info.name] = nil
    return
  end

  -- Load plugin
  pcall(function()
    vim.cmd("packadd " .. plugin_info.name)
    loaded_plugins[plugin_info.name] = true
    pack_log(
      "Loaded plugin: " .. plugin_info.name .. " (" .. origin .. ")",
      vim.uv.now() - require("core.global").start
    )

    -- Execute config if exists
    if plugin_info.config and type(plugin_info.config) == "function" then
      local opts = nil
      if plugin_info.opts ~= nil then
        local ok
        opts, ok = resolve_opts(plugin_info)
        if not ok then
          return
        end
      end
      local config_ok, config_err = pcall(plugin_info.config, plugin_info, opts)
      if not config_ok then
        pack_warn("pack config failed for " .. plugin_info.name .. ": " .. tostring(config_err))
      end
    elseif plugin_info.opts ~= nil then
      run_default_opts_setup(plugin_info)
    end
  end)

  loading_in_progress[plugin_info.name] = nil
end

-- Set up event listeners
function pack_loader:setup_event_loaders()
  local event_map = {
    VeryLazy = { event = "User", pattern = "VeryLazy" },
    InsertEnter = { event = "InsertEnter" },
    CmdlineEnter = { event = "CmdlineEnter" },
    CmdLineEnter = { event = "CmdlineEnter" },
    TextYankPost = { event = "TextYankPost" },
    CursorMoved = { event = "CursorMoved" },
    CursorMovedI = { event = "CursorMovedI" },
    CursorHold = { event = "CursorHold" },
    CursorHoldI = { event = "CursorHoldI" },
    BufReadPre = { event = "BufReadPre" },
    BufReadPost = { event = "BufReadPost" },
    BufWritePre = { event = "BufWritePre" },
    BufEnter = { event = "BufEnter" },
    FocusGained = { event = "FocusGained" },
    WinEnter = { event = "WinEnter" },
    WinScrolled = { event = "WinScrolled" },
    VimResized = { event = "VimResized" },
    LspAttach = { event = "LspAttach" },
  }

  for event_name, vim_event_config in pairs(event_map) do
    if plugins_by_event[event_name] then
      local autocmd_opts = {
        callback = function()
          for _, plugin in ipairs(plugins_by_event[event_name]) do
            self:ensure_loaded(plugin, "event: " .. event_name)
          end
          -- Clear this event to avoid repeated loading
          plugins_by_event[event_name] = nil
        end,
        once = true,
      }

      -- Add pattern if specified (for User events)
      if vim_event_config.pattern then
        autocmd_opts.pattern = vim_event_config.pattern
      end

      api.nvim_create_autocmd(vim_event_config.event, autocmd_opts)
    end
  end

  -- Fire VeryLazy event after startup
  vim.schedule(function()
    vim.cmd("doautocmd User VeryLazy")
  end)
end

-- Set up command handlers
function pack_loader:setup_command_loaders()
  for cmd, plugins_list in pairs(plugins_by_command) do
    -- Check if command already exists
    local cmd_exists = command_exists_exact(cmd)

    if not cmd_exists then
      api.nvim_create_user_command(cmd, function(args)
        pcall(api.nvim_del_user_command, cmd)
        for _, plugin in ipairs(plugins_list) do
          self:ensure_loaded(plugin, "command: " .. cmd)
        end
        -- After loading, execute the command again
        vim.schedule(function()
          local replay = cmd
          if args.bang then
            replay = replay .. "!"
          end
          if args.args ~= nil and args.args ~= "" then
            replay = replay .. " " .. args.args
          end
          vim.cmd(replay)
        end)
      end, { nargs = "*", bang = true, desc = "Load plugin for " .. cmd })
    else
      -- If command already exists, just load plugins on first use via autocmd
      local group = api.nvim_create_augroup("PackLoad_" .. cmd, { clear = true })
      api.nvim_create_autocmd("CmdUndefined", {
        group = group,
        pattern = cmd,
        callback = function()
          for _, plugin in ipairs(plugins_list) do
            self:ensure_loaded(plugin, "command: " .. cmd)
          end
        end,
        once = true,
      })
    end
  end
end

-- Set up filetype handlers
function pack_loader:setup_ft_loaders()
  api.nvim_create_autocmd("FileType", {
    callback = function(event)
      local ft = event.match
      if plugins_by_filetype[ft] then
        for _, plugin in ipairs(plugins_by_filetype[ft]) do
          self:ensure_loaded(plugin, "filetype: " .. ft)
        end
        plugins_by_filetype[ft] = nil
      end
    end,
  })
end

-- Set up module require interception
function pack_loader:setup_module_loaders()
  if next(plugins_by_module) then
    local original_require = require
    -- Override require to intercept module loading
    _G.require = function(module_name)
      if plugins_by_module[module_name] then
        local plugin = plugins_by_module[module_name]
        self:ensure_loaded(plugin, "module: " .. module_name)
        plugins_by_module[module_name] = nil
      end
      return original_require(module_name)
    end
  end
end

-- Load non-lazy plugins immediately
function pack_loader:load_start_plugins()
  for _, plugin in ipairs(self.plugins) do
    if not plugin.lazy or plugin.lazy == false then
      if cond_allows(plugin.cond, plugin.name) then
        self:ensure_loaded(plugin, "start")
      end
    end
  end
end

-- Initialize all loaders
function pack_loader:init()
  self:setup_module_loaders()
  self:load_start_plugins()
  self:setup_event_loaders()
  self:setup_command_loaders()
  self:setup_ft_loaders()
end

return pack_loader
