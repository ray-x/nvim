local rhs_options = {}

function rhs_options:new()
  local instance = {
    cmd = "",
    options = { noremap = false, silent = false, expr = false, nowait = false },
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function rhs_options:map_cmd(cmd_string)
  self.cmd = cmd_string
  return self
end

function rhs_options:map_cr(cmd_string)
  self.cmd = (":%s<CR>"):format(cmd_string)
  return self
end

function rhs_options:map_args(cmd_string)
  self.cmd = (":%s<Space>"):format(cmd_string)
  return self
end

function rhs_options:map_cu(cmd_string)
  self.cmd = (":<C-u>%s<CR>"):format(cmd_string)
  return self
end

function rhs_options:map_key(key_string)
  self.cmd = ("%s"):format(key_string)
  return self
end

function rhs_options:with_silent()
  self.options.silent = true
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

function pbind.map_cu(cmd_string)
  local ro = rhs_options:new()
  return ro:map_cu(cmd_string)
end

function pbind.map_key(keystr)
  local ro = rhs_options:new()
  return ro:map_key(keystr)
end

function pbind.map_args(cmd_string)
  local ro = rhs_options:new()
  return ro:map_args(cmd_string)
end

pbind.all_keys = {}
function pbind.nvim_load_mapping(mapping)
  for key, value in pairs(mapping) do
    local mode, keymap = key:match("([^|]*)|?(.*)")
    local opts
    for i = 1, #mode do
      if type(value) == "function" then
        if mapping.buffer then
          opts.buffer = {buffer = mapping.buffer}
        end
        vim.keymap.set(mode:sub(i,i), keymap, value, opts)
      end
      if type(value) == "table" then
        local rhs = value.cmd
        local options = value.options
        -- vim.api.nvim_set_keymap(mode:sub(i, i), keymap, rhs, options)

        vim.keymap.set(mode:sub(i,i), keymap, rhs, options)
        rhs = vim.trim(rhs, {}, 0)
        table.insert(pbind.all_keys, mode:sub(i, i) .. " | " .. keymap .. " : " .. rhs)
      elseif type(value) == "string" then
        -- vim.api.nvim_set_keymap(mode:sub(i, i), keymap, value, {})
        vim.keymap.set(mode:sub(i,i), keymap, value)
        value = vim.trim(value, {}, 0)
        table.insert(pbind.all_keys, mode:sub(i, i) .. " | " .. keymap .. " : " .. value)
      end
    end
  end
end

return pbind
