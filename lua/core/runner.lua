local uv, api = vim.loop, vim.api
-- run command with loop
local run = function(cmd, opts)

  _G.lprint = require('utils.log').lprint
  opts = opts or {}
  lprint(cmd, opts)
  if type(cmd) == 'string' then
    local split_pattern = '%s+'
    cmd = vim.split(cmd, split_pattern)
  end
  local cmd_str = vim.inspect(cmd)
  local job_options = vim.deepcopy(opts or {})
  job_options.args = job_options.args or {}
  local cmdargs = vim.list_slice(cmd, 2, #cmd) or {}

  vim.list_extend(cmdargs, job_options.args)
  job_options.args = cmdargs

  cmd = cmd[1]
  lprint(cmd, job_options.args)

  local stdin = uv.new_pipe(false)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)
  -- local file = api.nvim_buf_get_name(0)
  local handle = nil

  local output_buf = ''
  local output_stderr = ''
  local function update_chunk_fn(err, chunk)
    if err then
      vim.schedule(function()
        vim.notify('error ' .. tostring(err) .. vim.inspect(chunk or ''), vim.lprint.levels.WARN)
      end)
    end

    local lines = {}
    if chunk then
      for s in chunk:gmatch('[^\r\n]+') do
        table.insert(lines, s)
      end
      output_buf = output_buf .. '\n' .. table.concat(lines, '\n')
      lprint(lines)

      local cfixlines = vim.split(output_buf, '\n')
      local locopts = {
        title = vim.inspect(cmd),
        lines = cfixlines,
      }
      if opts.efm then
        locopts.efm = opts.efm
      end
      lprint(locopts)
      vim.schedule(function()
        vim.fn.setloclist(0, {}, ' ', locopts)
        vim.notify('run lopen to see output', vim.lprint.levels.INFO)
      end)
    end
    return lines
  end
  local update_chunk = function(err, chunk)
    lines = update_chunk_fn(err, chunk)
  end
  lprint('job:', cmd, job_options)
  handle, _ = uv.spawn(
    cmd,
    { stdio = { stdin, stdout, stderr }, args = job_options.args },
    function(code, signal) -- on exit()
      stdin:close()

      stdout:read_stop()
      stdout:close()

      stderr:read_stop()
      stderr:close()

      handle:close()
      lprint("spawn finished", code, signal)

      if output_stderr ~= '' then
        vim.schedule(function()
          vim.notify(output_stderr)
        end)
      end
      if opts and opts.on_exit then
        -- if on_exit hook is on the hook output is what we want to show in loc
        -- this avoid show samething in both on_exit and loc
        output_buf = opts.on_exit(code, signal, output_buf)
        if not output_buf then
          return
        end
      end
      if code > 1 then
        print('failed to run' .. tostring(code) .. vim.inspect(output_buf))

        output_buf = output_buf or ''

      end
      if output_buf ~= '' or output_stderr ~= '' then
        local lines = (output_buf or '') .. '\n' .. (output_stderr or '')
        lines = vim.trim(lines)

        local lines = vim.split(lines, '\n')
        local locopts = {
          title = vim.inspect(cmd),
          lines = lines,
        }
        if opts.efm then
          locopts.efm = opts.efm
        end
        lprint(locopts, lines)
        if #lines > 0 then
          vim.schedule(function()
            vim.fn.setloclist(0, {}, 'r', locopts)
          end)
        end
      end
    end
  )


  uv.read_start(stderr, function(err, data)
    if err then
      vim.notify('error ' .. tostring(err) .. tostring(data or ''), vim.lprint.levels.WARN)
    end
    if data ~= nil then
      lprint(data)
      output_stderr = output_stderr .. tostring(data)
    end
  end)
  stdout:read_start(update_chunk)
  return stdin, stdout, stderr
end


_G.test_or_run = function(debug)
  -- local function rot()
  local ft = vim.bo.filetype
  local fn = vim.fn.expand('%')
  fn = string.lower(fn)
  if ft == 'lua' then
    local f = string.find(fn, 'spec')
    if f == nil then
      -- let run lua test
      return '<CMD>luafile %<CR>'
    end
    return '<Plug>PlenaryTestFile'
  end
  if ft == 'go' then
    local f = string.find(fn, 'test.go')
    if f == nil then
      -- let run lua test
      if debug then
        return '<CMD>GoDebug <CR>'
      else
        return '<CMD>GoRun<CR>'
      end
    end

    if debug then
      return '<CMD>GoDebug -t<CR>'
    else
      return '<CMD>GoTestFunc -F<CR>'
    end
  end

  if ft == 'hurl' then
    return '<CMD>HurlRun<CR>'
  end

  if ft == 'rest' then
    return '<CMD>RestRun<CR>'
  end

  if fn:find('test') or fn:find('spec') then
    return require('neotest').run.run()
  end
  local m = vim.fn.mode()
  if m == 'n' or m == 'i' then
    if ft == 'python' then
      local file = vim.fn.expand('%')
      local cmd = 'python ' .. file
      run(cmd)
    end
    require('sniprun').run()
  else
    require('sniprun').run('v')
  end
end

return { run = run }
