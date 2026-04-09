--
-- in ~/.config/nvim/lua/tools.lua
local M = {}
local loop = vim.uv
local api = vim.api
local results = {}
local function onread(err, data)
  if err then
    -- print('ERROR: ', err)
    -- TODO handle err
  end
  if data then
    local vals = vim.split(data, '\n')
    for _, d in pairs(vals) do
      if d == '' then
        goto continue
      end
      table.insert(results, d)
      ::continue::
    end
  end
end
function M.asyncGrep(term)
  local stdout = vim.uv.new_pipe(false)
  local stderr = vim.uv.new_pipe(false)
  local function setQF()
    print(vim.inspect(results))
    -- vim.fn.setqflist({}, 'r', {title = 'Search Results', lines = results})
    -- api.nvim_command('cwindow')
    -- local count = #results
    -- for i=0, count do results[i]=nil end -- clear the table for the next search
  end
  handle = vim.uv.spawn(
    'sh',
    {
      -- args = {'-p', term, '-l', 'lua', '--json', '|', 'jq', '-r', [['.[] | "\(.file):\((.range.start.line + 1)):\((.range.start.column + 1)):\(.lines)"']]},
      args = {
        '-c',
        [[sg -p 'loop' -l lua --json | jq -r '.[] | "\(.file):\((.range.start.line + 1)):\((.range.start.column + 1)):\(.lines)"']],
      },
      -- args = { '-c', 'echo $PATH' },
      -- args = {'-c', "jq"},
      stdio = { nil, stdout, stderr },
    },
    vim.schedule_wrap(function()
      stdout:read_stop()
      stderr:read_stop()
      stdout:close()
      stderr:close()
      handle:close()
      setQF()
    end)
  )
  vim.uv.read_start(stdout, onread)
  vim.uv.read_start(stderr, onread)
end