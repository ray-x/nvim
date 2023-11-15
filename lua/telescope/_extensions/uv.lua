-- local uv = vim.loop
-- local stdin = uv.new_pipe()
-- local stdout = uv.new_pipe()
-- local stderr = uv.new_pipe()
--
-- print("stdin", stdin)
-- print("stdout", stdout)
-- print("stderr", stderr)
--
-- local handle, pid = uv.spawn("rg", {
--   stdio = {stdin, stdout, stderr},
--   args = { "stdout"}
-- }, function(code, signal) -- on exit
--   print("exit code", code)
--   print("exit signal", signal)
-- end)
--
-- print("process opened", handle, pid)
--
-- uv.read_start(stdout, function(err, data)
--   assert(not err, err)
--   if data then
--     print("stdout chunk", stdout, data)
--   else
--     print("stdout end", stdout)
--   end
-- end)
--
-- uv.read_start(stderr, function(err, data)
--   assert(not err, err)
--   if data then
--     print("stderr chunk", stderr, data)
--   else
--     print("stderr end", stderr)
--   end
-- end)
--
-- -- uv.write(stdin, "Hello World")
--
-- uv.shutdown(stdin, function()
--   print("stdin shutdown", stdin)
--   uv.close(handle, function()
--     print("process closed", handle, pid)
--   end)
-- end)
--
--
-- in ~/.config/nvim/lua/tools.lua
local M = {}
local loop = vim.loop
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
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)
  local function setQF()
    print(vim.inspect(results))
    -- vim.fn.setqflist({}, 'r', {title = 'Search Results', lines = results})
    -- api.nvim_command('cwindow')
    -- local count = #results
    -- for i=0, count do results[i]=nil end -- clear the table for the next search
  end
  handle = vim.loop.spawn(
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
  vim.loop.read_start(stdout, onread)
  vim.loop.read_start(stderr, onread)
end

-- Note: The functions used here will be upstreamed eventually.
--
-- local uv = vim.uv
-- local throttle = function(fn, duration)
--   local timer = uv.new_timer()
--   local function inner(...)
--     print(timer:is_active())
--     if not timer:is_active() then
--       timer:start(duration, 0, function() end)
--       pcall(vim.schedule_wrap(fn), select(1, ...))
--     end
--   end
--
--   local group = vim.api.nvim_create_augroup('gonvim__CleanupLuvTimers', {})
--   vim.api.nvim_create_autocmd('VimLeavePre', {
--     group = group,
--     pattern = '*',
--     callback = function()
--       if timer then
--         if timer:has_ref() then
--           timer:stop()
--           if not timer:is_closing() then
--             timer:close()
--           end
--         end
--         timer = nil
--       end
--     end,
--   })
--
--   return inner, timer
-- end
--
-- local debounce_wrap = function(func, ms)
--   local timer = uv.new_timer()
--   local function inner(...)
--     local argv = { ... }
--     -- print(vim.inspect(argv))
--     if not timer:is_active() then
--       timer:start(ms, 0, function()
--         timer:stop()
--         pcall(vim.schedule_wrap(func), unpack(argv))
--       end)
--     end
--   end
--   return inner, timer
-- end
--
-- local function test_defer(ms)
--   local timeout = ms or 2000
--
--   local bounced = debounce_wrap(function(i, j, k, l)
--     vim.cmd('echom "' .. ': ' .. i .. j .. k .. l .. '"')
--   end, timeout)
--
--   for i, _ in ipairs({ 1, 2, 3, 4, 5 }) do
--     bounced(i, 'a', 'b', 'hello')
--     vim.schedule(function()
--       vim.cmd('echom ' .. i)
--     end)
--     vim.fn.call('wait', { 1000, 'v:false' })
--   end
-- end
--
-- -- test_defer(3000)
