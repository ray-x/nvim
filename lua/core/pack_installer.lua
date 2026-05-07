-- Plugin installer for vim.pack
-- Downloads and manages plugins from GitHub
-- Supports parallel cloning for faster installation
local uv, fn = vim.uv, vim.fn
local helper = require('core.helper')
local global = require('core.global')
local sep = global.path_sep

local installer = {}

-- Maximum number of parallel git clone operations
local MAX_PARALLEL_CLONES = 8

local function pack_verbose()
  return vim.g.pack_verbose == 1 or vim.g.pack_verbose == true
end

local function pack_log(msg)
  if pack_verbose() then
    lprint(msg)
  end
end

local function pack_warn(msg)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.WARN)
  end)
end

local function shellescape(path)
  return '"' .. tostring(path):gsub('"', '\\"') .. '"'
end

local function build_marker_path(plugin_dir)
  return plugin_dir .. sep .. '.pack_build_done'
end

local function run_build_for_spec(spec, plugin_dir)
  local build = spec and spec.build
  if not build or fn.isdirectory(plugin_dir) ~= 1 then
    return true
  end

  local marker = build_marker_path(plugin_dir)
  if fn.filereadable(marker) == 1 then
    return true
  end

  local plugin_name = spec[1] and spec[1]:match('[^/]+$') or plugin_dir:match('[^' .. sep .. ']+$')
  pack_log('Running build for ' .. (plugin_name or plugin_dir))

  local ok = false
  local build_type = type(build)

  if build_type == 'function' then
    -- Make plugin modules available for build callbacks like require('fff.download').
    if plugin_name then
      pcall(function()
        vim.cmd('packadd ' .. plugin_name)
      end)
    end
    ok = pcall(build)
  elseif build_type == 'string' then
    if vim.startswith(build, ':') then
      local cmd = build:sub(2)
      ok = pcall(function()
        if plugin_name then
          vim.cmd('packadd ' .. plugin_name)
        end
        vim.cmd(cmd)
      end)
    else
      local shell_cmd = 'cd ' .. shellescape(plugin_dir) .. ' && ' .. build
      ok = os.execute(shell_cmd) == 0
    end
  elseif build_type == 'table' then
    ok = true
    for _, item in ipairs(build) do
      local item_ok = true
      if type(item) == 'string' then
        if vim.startswith(item, ':') then
          local cmd = item:sub(2)
          item_ok = pcall(function()
            if plugin_name then
              vim.cmd('packadd ' .. plugin_name)
            end
            vim.cmd(cmd)
          end)
        else
          local shell_cmd = 'cd ' .. shellescape(plugin_dir) .. ' && ' .. item
          item_ok = os.execute(shell_cmd) == 0
        end
      elseif type(item) == 'function' then
        if plugin_name then
          pcall(function()
            vim.cmd('packadd ' .. plugin_name)
          end)
        end
        item_ok = pcall(item)
      end
      if not item_ok then
        ok = false
        break
      end
    end
  end

  if ok then
    local fh = io.open(marker, 'w')
    if fh then
      fh:write(os.date('!%Y-%m-%dT%H:%M:%SZ'))
      fh:close()
    end
    pack_log('Build finished for ' .. (plugin_name or plugin_dir))
  else
    pack_warn('pack build failed: ' .. (plugin_name or plugin_dir))
  end

  return ok
end

-- Collect all plugins from plugin files
function installer.collect_all_plugins()
  local plugins = {}
  local modules_dir = helper.get_config_path() .. sep .. 'lua' .. sep .. 'modules'

  local plugins_list = {
    modules_dir .. sep .. 'completion' .. sep .. 'plugins.lua',
    modules_dir .. sep .. 'lang' .. sep .. 'plugins.lua',
    modules_dir .. sep .. 'ui' .. sep .. 'plugins.lua',
    modules_dir .. sep .. 'editor' .. sep .. 'plugins.lua',
    modules_dir .. sep .. 'tools' .. sep .. 'plugins.lua',
  }

  local collected = {}
  local function add_plugin_spec(spec)
    if type(spec) ~= 'table' or not spec[1] then
      return
    end

    if not collected[spec[1]] then
      collected[spec[1]] = spec
      table.insert(plugins, spec)
    end

    -- Also collect dependencies so they are installed and available for packadd.
    local deps = spec.dependencies
    if type(deps) == 'table' then
      for _, dep in ipairs(deps) do
        if type(dep) == 'string' then
          add_plugin_spec({ dep, lazy = true })
        elseif type(dep) == 'table' and dep[1] then
          add_plugin_spec(dep)
        end
      end
    elseif type(deps) == 'string' then
      add_plugin_spec({ deps, lazy = true })
    end
  end

  for _, plugin_file in ipairs(plugins_list) do
    if fn.filereadable(plugin_file) == 1 then
      -- Extract module name: modules/completion/plugins.lua -> modules.completion.plugins
      local mod_name = plugin_file:match('modules[/\\]([^/\\]+)[/\\]plugins')
      local module_plugins = require('modules.' .. mod_name .. '.plugins')
      module_plugins(add_plugin_spec)
    end
  end

  return plugins
end

-- Clone a single plugin repository
function installer.clone_plugin(repo, target_dir, dev_mode)
  if fn.isdirectory(target_dir) == 1 then
    return true, 'exists'
  end

  -- Create parent directory
  fn.mkdir(fn.fnamemodify(target_dir, ':h'), 'p')

  if dev_mode and string.find(repo, 'ray-x') then
    -- For dev plugins, use ~/github/ray-x instead of cloning
    local dev_path = vim.fn.expand('~/github/ray-x/' .. repo:match('[^/]+$'))
    if fn.isdirectory(dev_path) == 1 then
      -- Create symlink for dev mode
      local is_windows = global.is_windows
      local symlink_cmd
      if is_windows then
        -- Windows: use mklink /D (junction)
        symlink_cmd = 'mklink /D "' .. target_dir .. '" "' .. dev_path .. '"'
      else
        -- Unix: use ln -s
        symlink_cmd = 'ln -s "' .. dev_path .. '" "' .. target_dir .. '"'
      end
      os.execute(symlink_cmd)
      return true, 'dev'
    end
  end

  local clone_cmd = 'git clone --depth 1 https://github.com/' .. repo .. ' "' .. target_dir .. '"'
  local exit_code = os.execute(clone_cmd .. ' 2>/dev/null')
  
  if exit_code == 0 then
    return true, 'cloned'
  else
    return false, 'failed'
  end
end

-- Install all plugins with parallel cloning
function installer.install_all_plugins(pack_dir, dev_mode)
  local start_dir = pack_dir .. sep .. 'start'
  local opt_dir = pack_dir .. sep .. 'opt'

  -- Create directories
  fn.mkdir(start_dir, 'p')
  fn.mkdir(opt_dir, 'p')

  local plugins = installer.collect_all_plugins()
  local stats = { total = 0, installed = 0, skipped = 0, failed = 0, dev = 0, built = 0, build_failed = 0 }
  
  -- Separate plugins into those that need cloning and those that exist
  local to_clone = {}
  local spec_locations = {}
  
  for _, spec in ipairs(plugins) do
    stats.total = stats.total + 1
    local repo = spec[1]
    local plugin_name = repo:match('[^/]+$')

    -- Determine if plugin should be in start or opt
    local is_lazy = spec.lazy ~= false
    local should_disable = vim.g.disable_plugins and vim.tbl_contains(vim.g.disable_plugins, repo)

    local target_dir
    if is_lazy and not should_disable then
      target_dir = opt_dir .. sep .. plugin_name
    else
      target_dir = start_dir .. sep .. plugin_name
    end

    if fn.isdirectory(target_dir) == 1 then
      stats.skipped = stats.skipped + 1
      table.insert(spec_locations, { spec = spec, target_dir = target_dir })
    else
      local entry = {
        spec = spec,
        repo = repo,
        target_dir = target_dir,
        plugin_name = plugin_name,
        dev = dev_mode and string.find(repo, 'ray-x'),
      }
      table.insert(to_clone, entry)
      table.insert(spec_locations, { spec = spec, target_dir = target_dir })
    end
  end

  -- Create temp script for parallel cloning
  local function create_clone_script(items)
    local script = vim.fn.tempname() .. '.sh'
    local file = io.open(script, 'w')
    if not file then return nil end
    
    file:write('#!/bin/bash\n')
    file:write('set -e\n')
    file:write(string.format('MAX_JOBS=%d\n', MAX_PARALLEL_CLONES))
    file:write('ACTIVE_JOBS=0\n\n')
    
    for _, item in ipairs(items) do
      if not item.dev then
        file:write(string.format(
          'git clone --depth 1 https://github.com/%s "%s" 2>/dev/null & \n' ..
          'ACTIVE_JOBS=$((ACTIVE_JOBS + 1))\n' ..
          'if [ $ACTIVE_JOBS -ge $MAX_JOBS ]; then wait -n; ACTIVE_JOBS=$((ACTIVE_JOBS - 1)); fi\n\n',
          item.repo, item.target_dir
        ))
      end
    end
    
    file:write('wait\n')
    file:close()
    os.execute('chmod +x ' .. script)
    return script
  end

  -- Handle dev plugins first (fast, synchronous)
  for _, item in ipairs(to_clone) do
    if item.dev then
      local success, status = installer.clone_plugin(item.repo, item.target_dir, true)
      if success then
        stats.dev = stats.dev + 1
        pack_log('✓ ' .. item.plugin_name .. ' (dev symlink)')
      else
        stats.failed = stats.failed + 1
        pack_warn('pack dev symlink failed: ' .. item.plugin_name)
      end
    end
  end

  -- Clone regular plugins in parallel
  local git_clone_items = {}
  for _, item in ipairs(to_clone) do
    if not item.dev then
      table.insert(git_clone_items, item)
    end
  end

  if #git_clone_items > 0 then
    pack_log(string.format('⟳ Cloning %d plugins in parallel (max %d concurrent)...',
      #git_clone_items, MAX_PARALLEL_CLONES))

    local script = create_clone_script(git_clone_items)
    if script then
      os.execute('bash ' .. script)
      os.remove(script)
    end

    -- Count successful clones
    for _, item in ipairs(git_clone_items) do
      if fn.isdirectory(item.target_dir) == 1 then
        stats.installed = stats.installed + 1
        pack_log('✓ ' .. item.plugin_name)
      else
        stats.failed = stats.failed + 1
        pack_warn('pack clone failed: ' .. item.plugin_name)
      end
    end
  end

  -- Run build hooks (once per plugin via marker) for installed plugins.
  for _, item in ipairs(spec_locations) do
    local spec = item.spec
    if spec and spec.build and fn.isdirectory(item.target_dir) == 1 then
      if run_build_for_spec(spec, item.target_dir) then
        stats.built = stats.built + 1
      else
        stats.build_failed = stats.build_failed + 1
      end
    end
  end

  local changed = stats.installed > 0 or stats.dev > 0 or stats.built > 0
  local has_failures = stats.failed > 0 or stats.build_failed > 0
  if pack_verbose() and (changed or has_failures) then
    lprint(string.format('Installation summary: %d total, %d installed, %d dev, %d skipped, %d failed, %d built, %d build_failed',
      stats.total, stats.installed, stats.dev, stats.skipped, stats.failed, stats.built, stats.build_failed))
  end
  if has_failures then
    pack_warn(string.format('pack install issues: clone_failed=%d build_failed=%d', stats.failed, stats.build_failed))
  end
  return stats
end

return installer
