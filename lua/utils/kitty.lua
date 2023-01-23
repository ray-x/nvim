-- https://blog.dkendal.com/pages/capture-paths-kitty-neovim/
-- @alias Process { pid: number }
---@alias KittyWindow { id: number, is_focused: boolean, is_self: boolean, foreground_processes: Process }
---@alias KittyTab { id: number, is_focused: boolean, windows: KittyWindow[] }
---@alias KittyWM { id: number, is_focused: boolean, tabs: KittyTab[] }
---@alias KittyState KittyWM[]

local config = {}
local kitty = {}
local pid = vim.fn.getpid()
local ns = vim.api.nvim_create_namespace("user-kitty")

local group = vim.api.nvim_create_augroup("user-kitty", { clear = true })

local function has_support()
  if os.getenv("TERM_PROGRAM"):find("kitty") or os.getenv("TERM"):find("kitty") then
    return true
  end
  -- return vim.fn.executable("kitty") and vim.fn.system("kitty @ ls > /dev/null && printf 'ok'") == "ok"
end

---@param window KittyWindow
local function kitty_is_current_window(window)
  for _, ps in ipairs(window.foreground_processes) do
    if ps.pid == pid then
      return true
    end
  end
  return false
end

---@param state KittyState
---@return KittyTab
local function kitty_get_current_tab(state)
  for _, wm in ipairs(state) do
    for _, tab in ipairs(wm.tabs) do
      for _, window in ipairs(tab.windows) do
        if kitty_is_current_window(window) then
          return tab
        end
      end
    end
  end
end

---@return KittyState
local function kitty_get_state()
  local txt = vim.fn.system("kitty @ ls")

  if txt == nil then
    return
  end
  return vim.fn.json_decode(txt)
end

---@param id number
---@param opts {}
---@return string[]
local function kitty_get_text(id, opts)
  return vim.fn.systemlist("kitty @ get-text --match id:" .. id)
end

local function callback()
  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  local state = kitty_get_state()
  local tab = kitty_get_current_tab(state)

  for _, window in ipairs(tab.windows) do
    if not kitty_is_current_window(window) then
      local lines = kitty_get_text(window.id, {})

      for _, line in ipairs(lines) do
        local pattern = "(%S+%.%S+):(%d+):(%d+):"
        local path, lnum, col = string.match(line, pattern)

        if path then
          local bufnr = vim.fn.bufnr(path)

          if bufnr then
            vim.api.nvim_buf_set_extmark(bufnr, ns, tonumber(lnum) - 1, tonumber(col) - 1, {
              hl_group = "Search",
              virt_text = { { "🐱", "Search" } },
              virt_text_pos = "eol",
              strict = false,
            })
          end
        end
      end
    end
  end
end

local function init()
  if not has_support() then
    -- vim.notify("Kitty remote control is not enabled or supported, hint: check the output of `kitty @ ls`")
    lprint("Kitty remote control is not enabled or supported, hint: check the output of `kitty @ ls`")
    return
  end

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    -- Tweak the pattern to enable whatever filetypes you want to support
    pattern = { "*.lua" },
    group = group,
    callback = callback,
  })
end
local fn = vim.fn
vim.g.ORIGINAL_KITTY_BG_COLOR = nil

local split = function(str)
  local tokens = {}
  if not str then
    return
  end
  for s in string.gmatch(str, "%S+") do
    table.insert(tokens, s)
  end

  return tokens
end

kitty.get_kitty_background = function(opts)
  local color
  vim.fn.jobstart({ "kitty", "@", "get-colors" }, {
    cwd = "/usr/bin/",
    on_exit = function(j, data, event)
      lprint("kitty get color on exit", code, data, event)
      if opts then
        opts.callback(opts.color)
      end
    end,
    on_stdout = function(code, data, event)
      if #data < 4 then
        return
      end
      local color = split(data[4])[2]
      lprint("kitty get color on stdout", color)
      vim.g.ORIGINAL_KITTY_BG_COLOR = color
    end,
  })
end

local function get_color(hlgp, attr)
  return fn.synIDattr(fn.synIDtrans(fn.hlID(hlgp)), attr)
end

local autocmd = vim.api.nvim_create_autocmd
local autogroup = vim.api.nvim_create_augroup
local change_background = function(color)
  lprint("change_background", color)
  if color and color ~= "NONE" then
    local arg = 'background="' .. color .. '"'
    local command = "kitty @ set-colors " .. arg
    local handle = io.popen(command)
    if handle ~= nil then
      handle:close()
    end
  end
end
local function on_leave(color)
  autocmd("VimLeavePre", {
    callback = function()
      local cl = color or vim.g.ORIGINAL_KITTY_BG_COLOR
      if cl then
        change_background(cl)
      end
    end,
    group = autogroup("BackgroundRestore", { clear = true }),
  })
end

kitty.change_bg = function(color)
  kitty.get_kitty_background({
    color = color,
    callback = function(c)
      change_background(c)
    end,
  })
  on_leave()
end

local pid
kitty.set_title_on_active = function(title)
  local win_id = vim.fn.expand("$KITTY_WINDOW_ID") -- environ()['KITTY_WINDOW_ID']
  pid = tostring(vim.loop.os_getppid())

  local jq = "kitty @ls | jq '.[0].tabs.[] | select (.is_focused).windows[].foreground_processes[].pid'"
  local function on_event(job_id, data, event)
    if event == "exit" then
      lprint("get active win exit", data, event)
      return
    end

    if vim.fn.empty(data) == 1 then
      return
    end
    if vim.tbl_contains(data, pid) then
      -- lprint(data, title)
      lprint('found pid', pid, title)
      kitty.set_title(title)
    end
  end
  vim.fn.jobstart(jq, {
    on_stdout = on_event,
    on_stderr = on_event,
    on_exit = on_event,
  })
end

kitty.set_title = function(title)
  lprint('set_title', title)
  local cmd = { "kitty", "@", "set-window-title"}
  if title then
    table.insert(cmd, title)
  end
  vim.fn.jobstart(cmd, { on_exit = function(_, _) lprint('set title', title) end })
end

vim.api.nvim_create_user_command("SetKittyBg", function(opts)
  kitty.get_kitty_background()
  local color = get_color("Normal", "bg")
  if opts.fargs ~= nil then
    color = opts.fargs[1]
  end
  if color == nil then
    return
  end
  kitty.change_background(color)
  autocmd("VimLeavePre", {
    callback = function()
      if vim.g.ORIGINAL_KITTY_BG_COLOR ~= nil then
        kitty.change_background(vim.g.ORIGINAL_KITTY_BG_COLOR)
      end
    end,
    group = autogroup("BackgroundRestore", { clear = true }),
  })
end, { nargs = "*" })

vim.api.nvim_create_user_command("KittyBg", function(opts)
  kitty.change_bg(opts.fargs[1])
end, { nargs = "*" })

-- kitty @ get-colors | grep -w "background" | sed "s/   */:/g" | cut -d : -f 2
return kitty
