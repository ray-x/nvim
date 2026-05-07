local cli = {}
local helper = require('core.helper')

function cli:env_init()
  self.module_path = self.config_path .. '/lua/modules'
  local data_dir = helper.get_data_path()
  self.pack_site_dir = data_dir .. '/site/pack/ray-x'
  self.pack_legacy_dir = data_dir .. '/pack/ray-x'

  package.path = package.path
    .. ';'
    .. self.rtp
    .. '/lua/vim/?.lua;'
    .. self.module_path
    .. '/?.lua;'
  local shared = assert(loadfile(self.rtp .. '/lua/vim/shared.lua'))
  _G.vim = shared()
end

function cli:get_all_repos()
  local installer = require('core.pack_installer')
  return installer.collect_all_plugins()
end

function cli.sync()
  local installer = require('core.pack_installer')
  local pack_loader = require('core.pack_loader'):new()
  pack_loader:create_directories()
  helper.magenta('🔸 Sync plugins with vim.pack...')
  local stats = installer.install_all_plugins(pack_loader.pack_dir, _G.is_dev and _G.is_dev() or false)
  helper.green(string.format('🎉 Sync done. installed=%d dev=%d skipped=%d failed=%d',
    stats.installed or 0, stats.dev or 0, stats.skipped or 0, stats.failed or 0))
end

function cli.clean()
  os.execute('rm -rf ' .. cli.pack_site_dir)
  os.execute('rm -rf ' .. cli.pack_legacy_dir)
end

function cli.doctor()
  local load_keyword = {
    'keys',
    'ft',
    'cmd',
    'event',
    'lazy',
  }

  local function generate_node(tbl, list)
    local node = tbl[1]
    list[node] = {}
    list[node].type = tbl.dev and 'Local Plugin' or 'Remote Plugin'

    local check_lazy = function(t, data)
      vim.tbl_filter(function(k)
        if vim.tbl_contains(load_keyword, k) then
          data.load = type(t[k]) == 'table' and table.concat(t[k], ',') or t[k]
          return true
        end
        return false
      end, vim.tbl_keys(t))
    end

    check_lazy(tbl, list[node])

    if tbl.dependencies then
      for _, v in pairs(tbl.dependencies) do
        if type(v) == 'string' then
          v = { v }
        end

        list[v[1]] = {
          from_depend = true,
          load_after = node,
        }

        list[v[1]].type = v.dev and 'Local Plugin' or 'Remote Plugin'
        check_lazy(v, list[v[1]])
      end
    end
  end

  local all_repos = cli:get_all_repos()
  local list = {}
  for _, data in pairs(all_repos or {}) do
    if type(data) == 'string' then
      data = { data }
    end
    generate_node(data, list)
  end

  helper.magenta('Total: ' .. vim.tbl_count(list) .. ' Plugins')
  for k, v in pairs(list) do
    local msg = k .. ' ' .. v.type
    if v.load then
      msg = msg .. ' Load By: ' .. v.load
    end

    if v.from_depend then
      msg = msg .. ' Depend on: ' .. v.load_after
    end
    helper.green(msg)
  end
end

function cli:meta(arg)
  return function()
    self[arg]()
  end
end

return cli
