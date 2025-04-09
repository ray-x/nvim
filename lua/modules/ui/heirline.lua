local fn = vim.fn
local api = vim.api
local state = {disable_title_update = false}
local ts = ''
local uv = vim.uv
local treesitter_context = require('modules.lang.treesitter').context
local function set_title(str)
  -- lprint(str)
  -- io.stdout:write("\27]0;" .. str .. "\7")
  -- vim.cmd("set titlestring=%f%h%m%r%w")
  -- local titlestring = vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " - NVIM" -- vim.cmd("let &titlestring+=%{v:progname} ")
  -- vim.cmd("set title | let &titlestring='" .. titlestring .. "'")
  --   vim.cmd([[ set title titlestring=                               " completely reset titlestring
  local branches = {}
  local dir = vim.fn.getcwd()
  local home = vim.env.HOME
  if dir == home then
    return 'NVIM'
  end
  local titlestring = ''
  local _, i = dir:find(home .. '/', 1, true)
  if i then
    dir = dir:sub(i + 1)
  end
  local branch
  -- Some buffers are aasociated with a dir but not a branch: telescope, nvim-tree...
  -- We use the latest branch result for these
  if dir and not branch then
    branch = branches[dir]
  end
  if branch then
    titlestring = titlestring .. dir
    titlestring = titlestring .. ' - ' .. branch
    branches[dir] = branch
  end
  titlestring = titlestring .. ' ' .. str
  vim.opt.titlestring = titlestring
  return titlestring

  -- vim.cmd("set titlestring+=%{substitute(getcwd(), $HOME, '~', '')}")
end
local update_title = function(width)
  width = width or vim.o.columns
  if width < 50 then
    return ''
  end
  width = width * 0.8
  local ok
  ok, ts = pcall(treesitter_context, width)
  if not ok or not ts or string.len(ts) < 3 then
    return ''
  end

  -- cut of nerdfont+space in begining of the ts
  -- split ts with space
  local tslist = vim.split(ts, ' ')
  -- remove 1st element
  table.remove(tslist, 1)
  ts = table.concat(tslist, ' ')

  local path = fn.fnamemodify(fn.expand('%'), ':~:.')
  ts = path .. ' | ' .. string.gsub(ts, '[\n\r]+', ' ')
  set_title(ts)
end

local running = 1

local winwidth = function()
  -- body
  return vim.api.nvim_call_function('winwidth', { 0 })
end
local current_function = function()
  -- lprint('current_function width', width)
  local wwidth = winwidth()
  width = wwidth * 0.5
  local ok
  if running % 5 == 1 and not state.disable_title_update then
    ok, ts = pcall(treesitter_context, 400)
    if not ok or not ts or string.len(ts) < 3 then
      return ' '
    end
  end

  -- lprint(ts)
  ts = string.gsub(ts, '[\n\r]+', ' ')
  local path = fn.fnamemodify(fn.expand('%'), ':~:.')
  local title = path
  if ts and #ts > 1 then
    title = title .. '->' .. ts
  end

  if not state.disable_title_update and running % 5 == 1 then
    update_title()
  end
  running = running + 1
  -- split the contex with '->' and use different colors
  local parts = vim.split(ts, '->')
  local length = 0
  local result = { { '🥖', 'green' } }
  for i, part in ipairs(parts) do
    part = part:gsub('function', '󰡱')
    part = part:gsub('func', '󰡱')
    part = part:gsub('method', '')
    part = part:gsub('class', '')
    part = part:gsub('struct', '')
    part = part:gsub('string', '')
    part = part:gsub('int64', '󱂋')
    part = part:gsub('int', '󱂋')
    part = part:gsub('float64', '')
    part = part:gsub('float', '')
    part = part:gsub('error', '')
    part = part:gsub('interface', '')
    part = part:gsub('table', '󰠵')
    -- trim spaces on the left and right
    part = part:gsub('^%s*(.-)%s*$', '%1')
    length = length + #part

    if length >= width then
      local oldlen = length - #part
      local remain = width - oldlen + 4
      -- trim part longer than remain
      part = part:sub(1, remain)
    end
    if #result > 1 then
      result[#result + 1] = { '>', '#3354E9' }
    end

    result[#result + 1] = { part, '#339944' }
    if length > width then
      -- lprint(length, width)
      local truncate = length - width
      part = string.sub(part, 1, #result[#result] - truncate)
      result[#result] = { part, '#339944' }
      break
    end
  end
  -- lprint(result, width, parts, #lsp_label1, #lsp_label2)
  -- return string.sub(' ' .. ts, 1, width)
  -- lprint(result)
  return result
end

--- Creates a debounced version of a function.
--- When the returned function is called:
--- - If no timer is running, it immediately calls fn with the provided arguments,
---   returns its result, and starts a timer.
--- - If a timer is already running, the call returns nil.
---
--- @param fn function The function to debounce.
--- @param delay number The debounce delay in milliseconds.
--- @return function A debounced function.
local function debounce(fn, delay)
  -- Create a new timer
  local timer = uv.new_timer()
  -- Flag to indicate whether the timer is running.
  local waiting = false

  return function(...)
    local args = { ... }
    if not waiting then
      local result = fn(unpack(args))
      waiting = true

      -- Start the timer; when the delay expires, reset the waiting flag.
      timer:start(delay, 0, function()
        waiting = false
        timer:stop()
      end)
      return result
    else
      -- Timer is running; so ignore this call and return nil.
      return nil
    end
  end
end
local debounced_current_function = debounce(current_function, 200)

local current_signature = function(width)
  local ok, lsp_signature = pcall(require, 'lsp_signature')
  if not ok then
    return
  end
  local sig = lsp_signature.status_line(width)
  signature_length = #sig.label
  sig.label = sig.label:gsub('[\n\r]+', ' ')
  sig.hint = sig.hint:gsub('[\n\r]+', ' ')
  if sig.label == '' then
    return ''
  end

  return sig.label .. '🐼' .. sig.hint, sig
end

local debounced_signature = debounce(current_signature, 200)

local function split_lines(value)
  return vim.split(value, '\n', true)
end
local on_hover = function()
  local params
  local clients = vim.lsp.get_clients()
  local hoverProvider = false
  for _, client in ipairs(clients) do
    -- lprint(client.name, client.server_capabilities.hoverProvider)
    if
      client.server_capabilities.hoverProvider == true
      and client.name ~= 'null-ls'
      and client.name ~= 'GitHub'
    then
      -- lprint('hover enabled for ', client.name)
      hoverProvider = true
      params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    end
  end
  if hoverProvider == false or params == nil then
    return ''
  end
  vim.lsp.buf_request(0, 'textDocument/hover', params, function(err, result, ctx, config)
    config = config or {}
    if err then
      lprint(result, ctx, config)
      hover_info = nil
      return
    end
    config.focus_id = ctx.method
    if
      not (result and result.contents and result.contents.value and #result.contents.value > 0)
    then
      hover_info = nil
      return
    end
    -- lprint(result.contents)
    local cnt_kind = result.contents.kind
    local val = result.contents.value
    val = split_lines(val)
    if cnt_kind == 'markdown' then
      table.remove(val, #val)
      table.remove(val, 1)
    end
    for idx, value in ipairs(val) do
      val[idx] = vim.fn.trim(value)
      if val[idx]:find('^```') then
        val[idx] = val[idx]:gsub('^```', '')
      end
      if val[idx]:find('---') then
        val[idx] = val[idx]:gsub('---', '')
      end
      -- remove spaces
      val[idx] = val[idx]:gsub('^%s*(.-)%s*$', '%1')
    end
    if #val > 3 then
      -- truncate
      val = vim.list_slice(val, 1, 3)
    end
    val = vim.fn.join(val, ' ')
    if #val > 1 then
      hover_info = val
    end
    -- lprint(hover_info)
  end)
end

return function()
  local conditions = require('heirline.conditions')
  local utils = require('heirline.utils')
  local workdir = {
    provider = function()
      -- local icon = (vim.fn.haslocaldir(0) == 1 and 'l' or 'g') .. ' ' .. ' '
      local icon = ' '
      local cwd = vim.fn.getcwd(0)
      cwd = vim.fn.fnamemodify(cwd, ':~')
      if not conditions.width_percent_below(#cwd, 0.25) then
        cwd = vim.fn.pathshorten(cwd)
      end
      local trail = cwd:sub(-1) == '/' and '' or '/'
      return icon .. cwd .. trail
    end,
    hl = 'Directory',
  }
  local ViMode = {
    -- get vim current mode, this information will be required by the provider
    -- and the highlight functions, so we compute it only once per component
    -- evaluation and store it as a component attribute
    init = function(self)
      self.mode = vim.fn.mode(1) -- :h mode()
    end,
    -- Now we define some dictionaries to map the output of mode() to the
    -- corresponding string and color. We can put these into `static` to compute
    -- them at initialisation time.
    static = {
      mode_names = { -- change the strings if you like it vvvvverbose!
        n = 'N',
        no = 'N?',
        nov = 'N?',
        noV = 'N?',
        ['no\22'] = 'N?',
        niI = 'Ni',
        niR = 'Nr',
        niV = 'Nv',
        nt = 'Nt',
        v = 'V',
        vs = 'Vs',
        V = 'V_',
        Vs = 'Vs',
        ['\22'] = '^V',
        ['\22s'] = '^V',
        s = 'S',
        S = 'S_',
        ['\19'] = '^S',
        i = 'I',
        ic = 'Ic',
        ix = 'Ix',
        R = 'R',
        Rc = 'Rc',
        Rx = 'Rx',
        Rv = 'Rv',
        Rvc = 'Rv',
        Rvx = 'Rv',
        c = 'C',
        cv = 'Ex',
        r = '...',
        rm = 'M',
        ['r?'] = '?',
        ['!'] = '!',
        t = 'T',
      },
      mode_colors = {
        n = 'red',
        i = 'green',
        v = 'cyan',
        V = 'cyan',
        ['\22'] = 'cyan',
        c = 'orange',
        s = 'purple',
        S = 'purple',
        ['\19'] = 'purple',
        R = 'orange',
        r = 'orange',
        ['!'] = 'red',
        t = 'red',
      },
    },
    -- We can now access the value of mode() that, by now, would have been
    -- computed by `init()` and use it to index our strings dictionary.
    -- note how `static` fields become just regular attributes once the
    -- component is instantiated.
    -- To be extra meticulous, we can also add some vim statusline syntax to
    -- control the padding and make sure our string is always at least 2
    -- characters long. Plus a nice Icon.
    provider = function(self)
      return ' %2(' .. self.mode_names[self.mode] .. '%)'
    end,
    -- Same goes for the highlight. Now the foreground will change according to the current mode.
    hl = function(self)
      local mode = self.mode:sub(1, 1) -- get only the first mode character
      return { fg = self.mode_colors[mode], bold = true }
    end,
    -- Re-evaluate the component only on ModeChanged event!
    -- Also allows the statusline to be re-evaluated when entering operator-pending mode
    update = {
      'ModeChanged',
      pattern = '*:*',
      callback = vim.schedule_wrap(function()
        vim.cmd('redrawstatus')
      end),
    },
  }

  local disable_hover = false -- if signature is valid disable hover

  local hover = {
    condition = function()
      local width = api.nvim_win_get_width(0)
      if width < 80 then
        return false
      end
      if disable_hover then
        return false
      end
      return true
    end,
    init = function(self)
      api.nvim_create_autocmd(
        { 'CursorMoved', 'CursorMovedI', 'CursorHold' },
        {
          group = api.nvim_create_augroup('heirline_hover', { clear = true }),
          callback = function()
            local debouncer = require('core.timer').debounce_leading
            local debounce_hover = debouncer(on_hover, 200)
            debounce_hover()
          end,
        }
      )
    end,
    provider = function()
      return hover_info
    end,
    update = {'CursorMoved', 'CursorMovedI', 'CursorHold'},
  }
  local signature = {
    condition = function()
      local width = api.nvim_win_get_width(0)
      if width < 80 then
        return false
      end
      local ok = pcall(require, 'lsp_signature')
      return ok
    end,
    provider = function(self)
      local sig, sig_info = debounced_signature(40)
      if not sig then
        return ''
      end
      if #sig > 4 then
        hover_info = nil
        disable_hover = true
      else
        disable_hover = false
      end
      return sig
    end,
    update = {'CursorMoved', 'CursorMovedI', 'CursorHold'},
  }
  local current_func = {
    condition = function()
      local width = api.nvim_win_get_width(0)
      if width < 80 then
        return false
      end
      return true
    end,
    init = function(self)
      local curfun = debounced_current_function(200) or {}
      local children = {}
      for i, v in ipairs(curfun) do
        local child = {
          provider = v[1],
          hl = { fg = v[2], bg = 'bg' },
        }
        table.insert(children, child)
      end
      self.child = self:new(children, 1)
    end,
    provider = function(self)
      return self.child:eval()
      -- return current_function()
    end,
    hl = 'Keyword',
    update = {'CursorMoved', 'CursorMovedI', 'CursorHold'},
  }
  local lib = require('heirline-components.all')
  return {
    statusline = { -- UI statusbar
      hl = { fg = 'fg', bg = 'bg' },
      -- lib.component.mode({ mode_text = {} }),
      ViMode,
      lib.component.git_branch(),
      workdir,
      lib.component.file_info({
        filetype = false,
        filename = {},
        file_modified = false,
      }),
      lib.component.git_diff(),
      lib.component.diagnostics(),
      lib.component.fill(),
      utils.surround({ "", ">" }, "#448444", current_func),
      -- current_func,
      hover,
      signature,
      -- hover_info,
      -- lib.component.cmd_info(),
      lib.component.fill(),
      lib.component.lsp({
        lsp_client_names = false,
      }),
      -- lib.component.file_encoding({
    -- }),
      lib.component.compiler_state(),
      lib.component.virtual_env(),
      lib.component.nav(),
      lib.component.mode({ surround = { separator = 'right' } }),
    },
  }
end
