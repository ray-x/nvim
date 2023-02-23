local global = require('core.global')
local log_path = global.log_path

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
      str = str .. ' |' .. tostring(i) .. ': ' .. tostring(v or 'nil')
    end
  end
  if #str > 2 then
    if log_path ~= nil and #log_path > 3 then
      local f = io.open(log_path, 'a+')
      if f == nil then
        print('not found ', log_path)
        return
      end
      io.output(f)
      io.write(str .. '\n')
      io.close(f)
    else
      print(str .. '\n')
    end
  end
end

return { lprint = log }
