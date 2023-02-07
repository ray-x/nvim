local uv, api, fn = vim.loop, vim.api, vim.fn
local helper = require("core.helper")

local pack = {}
pack.__index = pack

function pack:load_modules_packages()
  local modules_dir = helper.get_config_path() .. '/lua/modules'
  self.repos = {}

  local list = vim.fs.find('plugins.lua', { path = modules_dir, type = 'file', limit = 10 })
  if #list == 0 then
    return
  end

  local disable_modules = {}

  if fn.exists('g:disable_modules') == 1 then
    disable_modules = vim.split(vim.g.disable_modules, ',')
  end

  for _, f in pairs(list) do
    local _, pos = f:find(modules_dir)
    f = f:sub(pos - 6, #f - 4)
    if not vim.tbl_contains(disable_modules, f) then
      require(f)
    end
  end
end

-- function pack:load_modules_packages()
--   local modules_dir = helper.get_config_path() .. "/lua/modules"
--   self.plug = {}
--
--   local list = vim.fs.find("plugins.lua", { path = modules_dir, type = "file", limit = 10 })
--   if #list == 0 then
--     return
--   end
--
--   local disable_modules = {}
--
--   if fn.exists("g:disable_modules") == 1 then
--     disable_modules = vim.split(vim.g.disable_modules, ",")
--   end
--   if self.plug == nil then
--     self.plug = {}
--   end
--
--   for _, f in pairs(list) do
--     local _, pos = f:find(modules_dir)
--     f = f:sub(pos - 6, #f - 4)
--     if not vim.tbl_contains(disable_modules, f) then
--       local modules = require(f)
--       for k, repo in pairs(modules) do
--         if k:find("ray") then
--           table.insert(self.plug, { dir = k, unpack(repo) })
--         else
--           table.insert(self.plug, { k, unpack(repo) })
--         end
--       end
--     end
--   end
-- end

function pack:boot_strap()
  local lazy_path = string.format("%s/lazy/lazy.nvim", helper.get_data_path())
  local state = uv.fs_stat(lazy_path)
  if not state then
    local cmd = "!git clone https://github.com/folke/lazy.nvim " .. lazy_path
    api.nvim_command(cmd)
  end
  vim.opt.runtimepath:prepend(lazy_path)
  local lazy = require("lazy")
  local opts = {
    lockfile = helper.get_data_path() .. "/lazy-lock.json",
    dev = { path = "~/github/ray-x" },
  }
  self:load_modules_packages()
  lazy.setup(self.plug, opts)
end

function pack.plug_add(repo)
  if not pack.plug then
    pack.plug = {}
  end
  table.insert(pack.plug, repo)
end

return pack