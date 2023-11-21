local global = require('core.global')
local log_path = global.log_path
local uv = vim.uv or vim.loop

local function fs_write(path, data)
  uv.fs_open(path, 'a', tonumber('644', 8), function(err, fd)
    if err then
      print('Error opening file: ' .. err)
      return err
    end
    uv.fs_write(fd, data, -1, function(e2, _)
      assert(not e2, e2)
      uv.fs_close(fd, function(e3)
        assert(not e3, e3)
      end)
    end)
  end)
end

local log = function(...)
  local arg = { ... }
  local str = 'שׁ '
  local lineinfo = ''

  local info = debug.getinfo(2, 'Sl')
  lineinfo = info.short_src .. ':' .. info.currentline
  str = string.format('%s %s %s:', str, lineinfo, os.date('%H:%M:%S'))

  for i, v in ipairs(arg) do
    if type(v) == 'table' then
      str = str .. ' |' .. tostring(i) .. ': ' .. vim.inspect(v) .. '\n'
    else
      str = str .. ' |' .. tostring(i) .. ': ' .. tostring(v or 'nil') .. '\n'
    end
  end
  if #str > 2 then
    if log_path ~= nil and #log_path > 3 then
      fs_write(log_path, str)
    else
      print(str .. '\n')
    end
  end
end

return { lprint = log, log = log }
