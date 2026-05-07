local M = {}

local MAX_ITEMS = 12
local MAX_HISTORY_SCAN = 200

local state = {
  buf = nil,
  win = nil,
  items = {},
  selected = 0,
  ns = vim.api.nvim_create_namespace("rayx.cmd_history"),
  cmdline_seq = 0,
  sync_pending = false,
  sync_target_seq = nil,
  completion_active = false,
  seed_cmdline = nil,
  seed_cmdpos = nil,
  applying_item = false,
  setup_done = false,
}

local function ensure_flag(option, flag)
  local flags = vim.split(vim.o[option], ",", { trimempty = true })
  if not vim.tbl_contains(flags, flag) then
    table.insert(flags, flag)
    vim.o[option] = table.concat(flags, ",")
  end
end

local function popup_visible()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win) and #state.items > 0
end

local function clear_popup_state()
  state.items = {}
  state.selected = 0
end

local function reset_completion_state()
  state.completion_active = false
  state.seed_cmdline = nil
  state.seed_cmdpos = nil
end

local function close_popup_window()
  if state.win ~= nil and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end

  state.win = nil
end

local function history_name(cmdtype)
  if cmdtype == ":" then
    return "cmd"
  end

  if cmdtype == "/" or cmdtype == "?" then
    return "search"
  end

  return nil
end

local function casefold(text, query)
  if vim.o.ignorecase and not query:find("%u") then
    return text:lower(), query:lower()
  end

  return text, query
end

local function matches_prefix(text, query)
  if query == "" then
    return true
  end

  local haystack, needle = casefold(text, query)
  return haystack:find(needle, 1, true) == 1
end

local function matches_substring(text, query)
  if query == "" then
    return true
  end

  local haystack, needle = casefold(text, query)
  return haystack:find(needle, 1, true) ~= nil
end

local function completion_context(cmdline, cmdpos)
  local cursor = cmdpos
  if cursor == nil then
    cursor = math.max(vim.fn.getcmdpos() - 1, 0)
  end

  cursor = math.min(cursor, #cmdline)

  local before = cmdline:sub(1, cursor)
  local after = cmdline:sub(cursor + 1)
  local prefix = before:match("^(.*%s)") or ""
  local replace_before = before:sub(#prefix + 1)
  local replace_after = after:match("^(%S*)") or ""

  return {
    prefix = prefix,
    suffix = after:sub(#replace_after + 1),
    query = replace_before .. replace_after,
    replace_pos = #prefix + 1,
  }
end

local function history_label(entry, ctx)
  if ctx.prefix ~= "" and entry:sub(1, #ctx.prefix) == ctx.prefix then
    return entry:sub(#ctx.prefix + 1)
  end

  return entry
end

local function history_items(cmdtype, cmdline, cmdpos)
  local hist = history_name(cmdtype)
  if hist == nil then
    return {}
  end

  local ctx = completion_context(cmdline, cmdpos)
  local query = ctx.query
  local newest = vim.fn.histnr(hist)
  local oldest = math.max(1, newest - MAX_HISTORY_SCAN + 1)
  local seen = {}
  local prefix = {}
  local substring = {}

  for idx = newest, oldest, -1 do
    local entry = vim.fn.histget(hist, idx)
    if type(entry) == "string" and entry ~= "" and not seen[entry] then
      seen[entry] = true

      if matches_prefix(entry, query) then
        table.insert(prefix, {
          word = entry,
          label = history_label(entry, ctx),
          kind = "history",
          cmdpos = #entry + 1,
        })
      elseif query ~= "" and matches_substring(entry, query) then
        table.insert(substring, {
          word = entry,
          label = history_label(entry, ctx),
          kind = "history",
          cmdpos = #entry + 1,
        })
      end
    end
  end

  local items = {}
  for _, item in ipairs(prefix) do
    table.insert(items, item)
    if #items >= MAX_ITEMS then
      return items
    end
  end

  for _, item in ipairs(substring) do
    table.insert(items, item)
    if #items >= MAX_ITEMS then
      break
    end
  end

  return items
end

local function completion_items(cmdtype, cmdline, cmdpos)
  if cmdtype ~= ":" then
    return {}
  end

  local ctx = completion_context(cmdline, cmdpos)
  local ok, matches = pcall(vim.fn.getcompletion, cmdline, "cmdline")
  if not ok or type(matches) ~= "table" then
    return {}
  end

  local items = {}
  for _, match in ipairs(matches) do
    if type(match) == "string" and match ~= "" then
      table.insert(items, {
        word = ctx.prefix .. match .. ctx.suffix,
        label = match,
        kind = "completion",
        cmdpos = ctx.replace_pos + #match,
      })
      if #items >= MAX_ITEMS then
        break
      end
    end
  end

  return items
end

function M.collect_items(cmdtype, cmdline, cmdpos)
  local items = history_items(cmdtype, cmdline, cmdpos)
  local seen = {}

  for _, item in ipairs(items) do
    seen[item.word] = true
  end

  for _, item in ipairs(completion_items(cmdtype, cmdline, cmdpos)) do
    if not seen[item.word] then
      table.insert(items, item)
      seen[item.word] = true
      if #items >= MAX_ITEMS then
        break
      end
    end
  end

  return items
end

local function apply_cmdline(word, cmdpos)
  state.applying_item = true
  vim.fn.setcmdline(word)
  vim.fn.setcmdpos(cmdpos or (#word + 1))
end

local function popup_lines(items)
  local lines = {}
  local width = 0

  for _, item in ipairs(items) do
    local prefix = item.kind == "history" and "[H] " or "[C] "
    local line = prefix .. (item.label or item.word)
    table.insert(lines, line)
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end

  return lines, math.max(width, 12)
end

local function popup_position(width, height)
  local col = math.max(vim.fn.getcmdscreenpos() - vim.fn.getcmdpos(), 1) - 1
  local row = vim.o.lines - height - 2

  if vim.o.laststatus ~= 0 then
    row = row - 1
  end

  row = math.max(row, 0)
  col = math.min(col, math.max(vim.o.columns - width - 2, 0))

  return row, col
end

local function ensure_buffer()
  if state.buf ~= nil and vim.api.nvim_buf_is_valid(state.buf) then
    return state.buf
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = "wipe"
  vim.bo[state.buf].buftype = "nofile"
  vim.bo[state.buf].filetype = "rayx_cmd_history"
  vim.bo[state.buf].modifiable = false

  return state.buf
end

local function render_popup()
  if #state.items == 0 then
    close_popup_window()
    return
  end

  if vim.fn.getcmdtype() == "" then
    close_popup_window()
    return
  end

  local buf = ensure_buffer()
  local lines, width = popup_lines(state.items)
  local height = #lines
  local row, col = popup_position(width, height)

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(buf, state.ns, 0, -1)
  if state.selected >= 1 and state.selected <= #state.items then
    vim.api.nvim_buf_add_highlight(buf, state.ns, "PmenuSel", state.selected - 1, 0, -1)
  end
  vim.bo[buf].modifiable = false

  local config = {
    relative = "editor",
    row = row,
    col = col,
    width = math.min(width + 1, math.max(vim.o.columns - 2, 1)),
    height = height,
    style = "minimal",
    border = "rounded",
    focusable = false,
    noautocmd = true,
    zindex = 250,
  }

  if popup_visible() then
    vim.api.nvim_win_set_config(state.win, config)
  else
    state.win = vim.api.nvim_open_win(buf, false, config)
    vim.wo[state.win].winblend = vim.o.pumblend
    vim.wo[state.win].wrap = false
    vim.wo[state.win].cursorline = false
    vim.wo[state.win].winhighlight = "NormalFloat:Pmenu,FloatBorder:Pmenu"
  end
end

local function request_popup_sync()
  state.sync_target_seq = state.cmdline_seq
  if state.sync_pending then
    return
  end

  state.sync_pending = true
  local seq = state.sync_target_seq
  vim.schedule(function()
    state.sync_pending = false
    if state.sync_target_seq == seq and state.cmdline_seq == seq then
      state.sync_target_seq = nil
      render_popup()
    end

    if state.sync_target_seq ~= nil then
      request_popup_sync()
    end
  end)
end

local function close_popup(restore_seed)
  if restore_seed and state.seed_cmdline ~= nil and state.seed_cmdpos ~= nil then
    apply_cmdline(state.seed_cmdline, state.seed_cmdpos)
  else
    state.applying_item = false
  end
  reset_completion_state()
  clear_popup_state()
  request_popup_sync()
end

local function refresh_items(cmdline, cmdpos)
  local cmdtype = vim.fn.getcmdtype()
  state.items = M.collect_items(cmdtype, cmdline, cmdpos - 1)
  state.selected = 0

  if #state.items == 0 then
    close_popup()
    return false
  end

  request_popup_sync()
  return true
end

local function update_popup()
  if state.applying_item then
    state.applying_item = false
    request_popup_sync()
    return
  end

  if vim.fn.wildmenumode() ~= 0 then
    close_popup()
    return
  end

  local cmdtype = vim.fn.getcmdtype()
  local cmdline = vim.fn.getcmdline()
  if history_name(cmdtype) == nil then
    close_popup()
    return
  end

  if not state.completion_active then
    close_popup()
    return
  end

  local cmdpos = vim.fn.getcmdpos()
  state.seed_cmdline = cmdline
  state.seed_cmdpos = cmdpos
  refresh_items(cmdline, cmdpos)
end

local function start_completion()
  local cmdtype = vim.fn.getcmdtype()
  if history_name(cmdtype) == nil then
    return false
  end

  state.completion_active = true
  state.seed_cmdline = vim.fn.getcmdline()
  state.seed_cmdpos = vim.fn.getcmdpos()
  return refresh_items(state.seed_cmdline, state.seed_cmdpos)
end

local function cycle_item(step)
  if not state.completion_active and not start_completion() then
    return false
  end

  local count = #state.items
  if count == 0 then
    return false
  end

  state.selected = (state.selected + step) % (count + 1)
  if state.selected == 0 then
    apply_cmdline(state.seed_cmdline, state.seed_cmdpos)
  else
    local item = state.items[state.selected]
    apply_cmdline(item.word, item.cmdpos)
  end
  request_popup_sync()
  return true
end

local function accept_item()
  if not popup_visible() then
    return false
  end

  if state.selected == 0 then
    close_popup()
    return false
  end

  close_popup()
  return true
end

local function close_for_native_key()
  if popup_visible() then
    close_popup()
  end
  return false
end

local function expr_map(lhs, rhs, callback, desc)
  vim.keymap.set("c", lhs, function()
    if callback() then
      return "<Ignore>"
    end

    return rhs
  end, { expr = true, desc = desc })
end

function M.setup()
  if state.setup_done then
    return
  end
  state.setup_done = true

  vim.opt.wildmenu = true
  ensure_flag("wildoptions", "pum")

  local group = vim.api.nvim_create_augroup("rayx.cmdline_history", { clear = true })

  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = group,
    pattern = { ":", "/", "?" },
    callback = function()
      state.cmdline_seq = state.cmdline_seq + 1
      state.applying_item = false
      reset_completion_state()
      clear_popup_state()
      request_popup_sync()
    end,
    desc = "Reset command-line popup session",
  })

  vim.api.nvim_create_autocmd("CmdlineChanged", {
    group = group,
    pattern = { ":", "/", "?" },
    callback = update_popup,
    desc = "Update command-line history completion popup",
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = group,
    callback = function()
      state.applying_item = false
      reset_completion_state()
      clear_popup_state()
      request_popup_sync()
    end,
    desc = "Close command-line history popup",
  })

  expr_map("<Down>", "<Down>", function()
    return close_for_native_key()
  end, "Command-line history next")

  expr_map("<Up>", "<Up>", function()
    return close_for_native_key()
  end, "Command-line history previous")

  expr_map("<C-n>", "<C-n>", function()
    if not state.completion_active then
      return false
    end
    return cycle_item(1)
  end, "Command-line popup next")

  expr_map("<C-p>", "<C-p>", function()
    if not state.completion_active then
      return false
    end
    return cycle_item(-1)
  end, "Command-line popup previous")

  expr_map("<Tab>", "<Tab>", function()
    return cycle_item(1)
  end, "Command-line popup next")

  expr_map("<S-Tab>", "<S-Tab>", function()
    return cycle_item(-1)
  end, "Command-line popup previous")

  expr_map("<Right>", "<Right>", accept_item, "Accept command-line popup item")
  expr_map("<C-y>", "<C-y>", accept_item, "Accept command-line popup item")
  expr_map("<Esc>", "<Esc>", function()
    if popup_visible() then
      close_popup(true)
      return true
    end

    return false
  end, "Close command-line popup")

  vim.keymap.set("c", "<CR>", function()
    accept_item()
    return "<CR>"
  end, { expr = true, desc = "Accept command-line popup item and execute" })

  vim.keymap.set("c", "<C-e>", function()
    if popup_visible() then
      close_popup(true)
      return "<Ignore>"
    end

    return "<C-e>"
  end, { expr = true, desc = "Close command-line popup" })
end

return M
