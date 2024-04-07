local config = {}
local wezterm = {}
local pid = vim.fn.getpid()
local ns = vim.api.nvim_create_namespace('user-wezterm')

local group = vim.api.nvim_create_augroup('user-wezterm', { clear = true })

local has_wezterm
local function has_support()
  if has_wezterm ~= nil then
    return has_wezterm
  end
  local wezterm_str = os.getenv('TERM_PROGRAM') or os.getenv('TERM') or 'term'
  if wezterm_str:find('WezTerm') then
    has_wezterm = true
    return true
  end
  if require('core.global').is_windows then
    has_wezterm = false
    return false
  end
end
if has_wezterm == nil then
  if has_support() == false then
    return { change_bg = function(...) end }
  end
end

local fn = vim.fn
vim.g.ORIGINAL_WEZTERM_BG_COLOR = nil

local split = function(str)
  local tokens = {}
  if not str then
    return
  end
  for s in string.gmatch(str, '%S+') do
    table.insert(tokens, s)
  end

  return tokens
end

local function get_color(hlgp, attr)
  return fn.synIDattr(fn.synIDtrans(fn.hlID(hlgp)), attr)
end

local autocmd = vim.api.nvim_create_autocmd
local autogroup = vim.api.nvim_create_augroup

local change_background = function(color)
  if not has_support() then
    return ''
  end
  vim.g.ORIGINAL_WEZTERM_BG_COLOR = '#1e1e2e'  -- hardcode for now
  -- control code "\033]11;#000000\007"
  -- change bg inside neovim :  call chansend(v:stderr, "\x1b]11;?\x07")
  local c = string.format("\x1b]11;%s\x07", color)
  local cmd = string.format([[call chansend(v:stderr, "%s")]], c)
  vim.cmd(cmd)
end


local function on_leave(color)
  autocmd('VimLeavePre', {
    callback = function()
      local cl = color or vim.g.ORIGINAL_WEZTERM_BG_COLOR
      if cl then
        change_background(cl)
      end
    end,
    group = autogroup('BackgroundRestore', { clear = true }),
  })
end

wezterm.change_bg = function(color)
  change_background(color)
  on_leave()
end

local pid
wezterm.set_title_on_active = function(title)
  if not has_support() then
    return ''
  end
  local win_id = vim.fn.expand('$WEZTERM_WINDOW_ID') -- environ()['KITTY_WINDOW_ID']
  pid = tostring(vim.loop.os_getppid())

  local jq =
    "kitty @ls | jq '.[0].tabs.[] | select (.is_focused).windows[].foreground_processes[].pid'"
  local function on_event(job_id, data, event)
    if event == 'exit' then
      -- lprint("get active win exit", data, event)
      return
    end

    if vim.fn.empty(data) == 1 then
      return
    end
    if vim.tbl_contains(data, pid) then
      -- lprint(data, title)
      -- lprint('found pid', pid, title)
      wezterm.set_title(title)
    end
  end
  vim.fn.jobstart(jq, {
    on_stdout = on_event,
    on_stderr = on_event,
    on_exit = on_event,
  })
end

wezterm.set_title = function(title)
  if not has_support() then
    return ''
  end
  -- lprint('set_title', title)
  local cmd = { 'kitty', '@', 'set-window-title' }
  if title then
    table.insert(cmd, title)
  end
  vim.fn.jobstart(cmd, { on_exit = function(_, _) end })
end

vim.api.nvim_create_user_command('SetWezTermBg', function(opts)
  if not has_support() then
    return ''
  end

  local weztermcfg = require('wezterm')
  wezterm.get_kitty_background()
  local color = get_color('Normal', 'bg')
  if opts.fargs ~= nil then
    color = opts.fargs[1]
  end
  if color == nil then
    return
  end
  wezterm.change_background(color)
  autocmd('VimLeavePre', {
    callback = function()
      if vim.g.ORIGINAL_WEZTERM_BG_COLOR ~= nil then
        wezterm.change_background(vim.g.ORIGINAL_WEZTERM_BG_COLOR)
      end
    end,
    group = autogroup('BackgroundRestore', { clear = true }),
  })
end, { nargs = '*' })

vim.api.nvim_create_user_command('WezTermBg', function(opts)
  wezterm.change_bg(opts.fargs[1])
end, { nargs = '*' })

-- kitty @ get-colors | grep -w "background" | sed "s/   */:/g" | cut -d : -f 2
return wezterm
