local rhs_options = {}

function rhs_options:new()
  local instance = {
    cmd = '',
    desc = '',
    options = { noremap = false, silent = false, expr = false, nowait = false },
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function rhs_options:map_cmd(cmd_string)
  self.cmd = '<cmd>' .. cmd_string .. '<CR>'
  return self
end

function rhs_options:map_func(func)
  self.cmd = func
  return self
end

function rhs_options:map_cr(cmd_string)
  self.cmd = (':%s<CR>'):format(cmd_string)
  return self
end

function rhs_options:map_plug(cmd_string)
  self.cmd = ('<Plug>(%s)'):format(cmd_string)
  return self
end

function rhs_options:map_cu(cmd_string)
  self.cmd = ('<C-u><Cmd>%s<CR>'):format(cmd_string)
  return self
end

function rhs_options:map_key(key_string)
  self.cmd = ('%s'):format(key_string)
  return self
end

function rhs_options:with_silent()
  self.options.silent = true
  return self
end

function rhs_options:with_args(...)
  self.args = { ... }
  return self
end

function rhs_options:with_desc(desc)
  self.desc = desc
  return self
end

function rhs_options:with_noremap()
  self.options.noremap = true
  return self
end

function rhs_options:with_expr()
  self.options.expr = true
  return self
end

function rhs_options:with_nowait()
  self.options.nowait = true
  return self
end

local pbind = {}

function pbind.map_cr(cmd_string)
  local ro = rhs_options:new()
  return ro:map_cr(cmd_string)
end

function pbind.map_cmd(cmd_string)
  local ro = rhs_options:new()
  return ro:map_cmd(cmd_string)
end

function pbind.map_func(func)
  local ro = rhs_options:new()
  return ro:map_func(func)
end

function pbind.map_cu(cmd_string)
  local ro = rhs_options:new()
  return ro:map_cu(cmd_string)
end

function pbind.map_plug(cmd_string)
  local ro = rhs_options:new()
  return ro:map_plug(cmd_string)
end

function pbind.map_key(keystr)
  local ro = rhs_options:new()
  return ro:map_key(keystr)
end

pbind.all_keys = {}
function pbind.nvim_load_mapping(mapping)
  for key, value in pairs(mapping) do
    local mode, keymap = key:match('([^|]*)|?(.*)')

    local models = {}
    if #mode > 1 then
      for i = 1, #mode do
        table.insert(models, mode:sub(i, i))
      end
    else
      models = { mode }
    end
    if type(value) == 'function' then
      local opts = {}
      if mapping.buffer then
        opts.buffer = { buffer = mapping.buffer }
      end
      vim.keymap.set(models, keymap, value, opts)
    elseif type(value) == 'table' then
      local rhs = value.cmd
      local opts = value.options or {}

      if rhs then
        vim.keymap.set(models, keymap, rhs, opts)
      end
      if type(rhs) == 'string' then
        rhs = vim.trim(rhs)
        table.insert(pbind.all_keys, mode .. ' | ' .. keymap .. ' : ' .. rhs)
      elseif type(rhs) == 'function' then
        opts.desc = value.desc or 'map lua func'
        -- lprint(opts, keymap, mode:sub(i,i))
        vim.keymap.set(models, keymap, rhs, opts)
        table.insert(pbind.all_keys, mode .. ' | ' .. keymap .. ' : ' .. (value.desc or ''))
      else
        table.insert(pbind.all_keys, mode .. ' | ' .. keymap .. ' : ' .. (value.desc or ''))
      end
    elseif type(value) == 'string' then
      vim.keymap.set(models, keymap, value)
      value = vim.trim(value)
      table.insert(pbind.all_keys, mode .. ' | ' .. keymap .. ' : ' .. value)
    else
      print('unsupported type?: ' .. type(value) .. ' ' .. keymap)
    end
  end
end

return pbind
