local utils = {}
utils.shell = function(command) --{{{
  local file = io.popen(command, 'r')
  local res = {}
  for line in file:lines() do
    table.insert(res, line)
  end
  return res
end --}}}

return utils
