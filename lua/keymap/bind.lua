local pbind = {}

local DEFAULT_OPTS = {
  -- Keep legacy remap behavior unless overridden per mapping.
  noremap = false,
  silent = true,
  expr = false,
  nowait = false,
}

local Builder = {}
Builder.__index = Builder

local function new_builder(rhs)
  return setmetatable({
    cmd = rhs,
    desc = '',
    args = nil,
    options = vim.deepcopy(DEFAULT_OPTS),
  }, Builder)
end

function Builder:with_silent()
  self.options.silent = true
  return self
end

function Builder:with_args(...)
  -- Kept for backward compatibility.
  self.args = { ... }
  return self
end

function Builder:with_desc(desc)
  self.desc = desc
  return self
end

function Builder:with_noremap()
  self.options.noremap = true
  return self
end

function Builder:with_remap()
  self.options.noremap = false
  return self
end

function Builder:with_expr()
  self.options.expr = true
  return self
end

function Builder:with_nowait()
  self.options.nowait = true
  return self
end

function pbind.map_cr(cmd)
  return new_builder((':%s<CR>'):format(cmd))
end

function pbind.map_cmd(cmd)
  return new_builder('<cmd>' .. cmd .. '<CR>')
end

function pbind.map_func(fn)
  return new_builder(fn)
end

function pbind.map_cu(cmd)
  return new_builder(('<C-u><Cmd>%s<CR>'):format(cmd))
end

function pbind.map_plug(name)
  return new_builder(('<Plug>(%s)'):format(name))
end

function pbind.map_key(keys)
  return new_builder(tostring(keys))
end

pbind.all_keys = {}

local function split_modes(mode)
  if type(mode) ~= 'string' or mode == '' then
    return { 'n' }
  end
  if #mode == 1 then
    return { mode }
  end

  local modes = {}
  for i = 1, #mode do
    modes[#modes + 1] = mode:sub(i, i)
  end
  return modes
end

local function normalize_rhs(value)
  local t = type(value)
  if t == 'function' or t == 'string' then
    return { cmd = value, options = {}, desc = '' }
  end
  if t == 'table' then
    return {
      cmd = value.cmd,
      options = value.options or {},
      desc = value.desc or '',
    }
  end
  return nil
end

local function apply_one(mode, lhs, rhs_def, base_opts)
  if not rhs_def then
    return
  end

  local rhs = rhs_def.cmd
  local opts = vim.tbl_deep_extend('force', {}, base_opts, rhs_def.options)
  if rhs_def.desc ~= '' then
    opts.desc = rhs_def.desc
  end

  if rhs ~= nil then
    vim.keymap.set(split_modes(mode), lhs, rhs, opts)
  end

  local rhs_type = type(rhs)
  local rhs_text = ''
  if rhs_type == 'string' then
    rhs_text = vim.trim(rhs)
  elseif rhs_type == 'function' then
    rhs_text = rhs_def.desc ~= '' and rhs_def.desc or 'lua func'
  else
    rhs_text = rhs_def.desc or ''
  end
  pbind.all_keys[#pbind.all_keys + 1] = mode .. ' | ' .. lhs .. ' : ' .. rhs_text
end

function pbind.nvim_load_mapping(mapping)
  local base_opts = {}
  if mapping.buffer then
    base_opts.buffer = mapping.buffer
  end

  for key, value in pairs(mapping) do
    local mode, lhs = key:match('([^|]*)|?(.*)')
    local rhs_def = normalize_rhs(value)
    if rhs_def then
      apply_one(mode, lhs, rhs_def, base_opts)
    else
      vim.notify('Unsupported keymap type: ' .. type(value) .. ' for ' .. key, vim.log.levels.WARN)
    end
  end
end

return pbind
