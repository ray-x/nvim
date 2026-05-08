-- deprecated and to be removed
local M = {}

local MAX_HISTORY_SCAN = 200
local MAX_VISIBLE_ITEMS = 12
if true then
  return M
end

local state = {
  buf = nil,
  win = nil,
  items = {},
  selected = 0,
  ns = vim.api.nvim_create_namespace('rayx.cmd_history'),
  cmdline_seq = 0,
  cmdtype = nil,
  sync_pending = false,
  sync_target_seq = nil,
  completion_active = false,
  seed_cmdline = nil,
  seed_cmdpos = nil,
  applying_item = false,
  accepting_item = false,
  suppress_update_once = false,
  previewing_item = false,
  refresh_token = 0,
  viewport_top = 1,
  setup_done = false,
}

local function ensure_flag(option, flag)
  local flags = vim.split(vim.o[option], ',', { trimempty = true })
  if not vim.tbl_contains(flags, flag) then
    table.insert(flags, flag)
    vim.o[option] = table.concat(flags, ',')
  end
end

local function popup_visible()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win) and #state.items > 0
end

local function clear_popup_state()
  state.items = {}
  state.selected = 0
  state.viewport_top = 1
end

local start_completion, refresh_items

local function reset_completion_state()
  state.completion_active = false
  state.seed_cmdline = nil
  state.seed_cmdpos = nil
  state.previewing_item = false
  state.refresh_token = state.refresh_token + 1
end

local function is_popup_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  if state.buf ~= nil and buf == state.buf then
    return true
  end

  return vim.bo[buf].filetype == 'nvim_cmd_history'
end

local function close_popup_window()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and is_popup_buffer(vim.api.nvim_win_get_buf(win)) then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
  state.win = nil
  state.buf = nil
  state.sync_pending = false
  state.sync_target_seq = nil
end

local function history_name(cmdtype)
  if cmdtype == ':' then
    return 'cmd'
  end

  if cmdtype == '/' or cmdtype == '?' then
    return 'search'
  end

  return nil
end

local function active_cmdtype()
  local cmdtype = vim.fn.getcmdtype()
  if cmdtype ~= '' then
    return cmdtype
  end

  return state.cmdtype
end

local function in_cmdline_mode()
  return vim.api.nvim_get_mode().mode:sub(1, 1) == 'c'
end

local function should_ignore_cmdline(cmdtype, cmdline)
  if cmdtype ~= ':' or cmdline == '' then
    return false
  end

  if cmdline:match('^call%s+wordmotion#motion%(') then
    return true
  end

  return false
end

local function casefold(text, query, ignore_case)
  if ignore_case then
    return text:lower(), query:lower()
  end

  return text, query
end

local function matches_prefix(text, query, ignore_case)
  if query == '' then
    return true
  end

  local haystack, needle = casefold(text, query, ignore_case)
  return haystack:find(needle, 1, true) == 1
end

local function matches_substring(text, query, ignore_case)
  if query == '' then
    return true
  end

  local haystack, needle = casefold(text, query, ignore_case)
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
  local prefix = before:match('^(.*%s)') or ''
  local replace_before = before:sub(#prefix + 1)
  local replace_after = after:match('^(%S*)') or ''

  return {
    prefix = prefix,
    suffix = after:sub(#replace_after + 1),
    query = replace_before .. replace_after,
    replace_pos = #prefix + 1,
  }
end

local function history_label(entry)
  return entry
end

local function history_match_text(entry, ctx)
  if ctx.prefix == '' then
    return entry
  end

  if entry:sub(1, #ctx.prefix) ~= ctx.prefix then
    return nil
  end

  return entry:sub(#ctx.prefix + 1)
end

local function history_items(cmdtype, cmdline, cmdpos, ignore_case)
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
    if type(entry) == 'string' and entry ~= '' and not seen[entry] then
      seen[entry] = true
      local match_text = history_match_text(entry, ctx)

      if match_text ~= nil and matches_prefix(match_text, query, ignore_case) then
        table.insert(prefix, {
          word = entry,
          label = history_label(entry),
          kind = 'history',
          cmdpos = #entry + 1,
        })
      elseif match_text ~= nil and query ~= '' and matches_substring(match_text, query, ignore_case) then
        table.insert(substring, {
          word = entry,
          label = history_label(entry),
          kind = 'history',
          cmdpos = #entry + 1,
        })
      end
    end
  end

  local items = {}
  for _, item in ipairs(prefix) do
    table.insert(items, item)
  end

  if query == '' or #items > 0 then
    return items
  end

  for _, item in ipairs(substring) do
    table.insert(items, item)
  end

  return items
end

local function completion_items(cmdtype, cmdline, cmdpos, ignore_case)
  if cmdtype ~= ':' then
    return {}
  end

  local ctx = completion_context(cmdline, cmdpos)
  if ctx.query == '' then
    return {}
  end

  local source_cmdline = cmdline
  if ignore_case and ctx.query ~= '' then
    source_cmdline = ctx.prefix .. ctx.query:lower() .. ctx.suffix
  end

  local ok, matches = pcall(vim.fn.getcompletion, source_cmdline, 'cmdline')
  if not ok or type(matches) ~= 'table' then
    return {}
  end

  local items = {}
  for _, match in ipairs(matches) do
    if type(match) == 'string' and match ~= '' then
      table.insert(items, {
        word = ctx.prefix .. match .. ctx.suffix,
        label = match,
        kind = 'completion',
        cmdpos = ctx.replace_pos + #match,
      })
    end
  end

  return items
end

function M.collect_items(cmdtype, cmdline, cmdpos)
  local ctx = completion_context(cmdline, cmdpos)
  local function merge_groups(groups)
    local items = {}
    local seen = {}
    local non_empty_groups = {}

    for _, group in ipairs(groups) do
      if #group > 0 then
        table.insert(non_empty_groups, group)
      end
    end

    if #non_empty_groups == 0 then
      return items
    end

    for _, group in ipairs(non_empty_groups) do
      for _, item in ipairs(group) do
        if not seen[item.word] then
          table.insert(items, item)
          seen[item.word] = true
        end
      end
    end

    for _, group in ipairs(groups) do
      for _, item in ipairs(group) do
        if not seen[item.word] then
          table.insert(items, item)
          seen[item.word] = true
        end
      end
    end

    return items
  end

  local function item_groups(ignore_case)
    local completions = completion_items(cmdtype, cmdline, cmdpos, ignore_case)
    local histories = history_items(cmdtype, cmdline, cmdpos, ignore_case)

    if cmdtype == ':' and ctx.query ~= '' then
      return { completions, histories }
    end

    return { histories, completions }
  end

  local items = merge_groups(item_groups(false))
  if #items == 0 and ctx.query ~= '' then
    items = merge_groups(item_groups(true))
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
    local prefix = item.kind == 'history' and '[H] ' or '[C] '
    local line = prefix .. (item.label or item.word)
    table.insert(lines, line)
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end

  return lines, math.max(width, 12)
end

local function popup_max_height()
  local reserved_rows = vim.o.laststatus ~= 0 and 4 or 3
  return math.max(math.min(MAX_VISIBLE_ITEMS, vim.o.lines - reserved_rows), 1)
end

local function popup_view(items)
  local total = #items
  if total == 0 then
    return {}, 0
  end

  local height = math.min(total, popup_max_height())
  local selected = math.min(math.max(state.selected, 1), total)
  local top = math.min(math.max(state.viewport_top, 1), math.max(total - height + 1, 1))

  if selected < top then
    top = selected
  elseif selected >= top + height then
    top = selected - height + 1
  end

  state.viewport_top = top

  local bottom = math.min(top + height - 1, total)
  local view = {}
  for idx = top, bottom do
    table.insert(view, items[idx])
  end

  return view, selected - top + 1
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
  vim.bo[state.buf].bufhidden = 'wipe'
  vim.bo[state.buf].buftype = 'nofile'
  vim.bo[state.buf].filetype = 'rayx_cmd_history'
  vim.bo[state.buf].modifiable = false

  return state.buf
end

local function redraw_cmdline_popup()
  local ok = pcall(vim.api.nvim__redraw, { flush = true })
  if ok then
    return
  end

  pcall(vim.cmd, 'redraw')
end

local function render_popup()
  if #state.items == 0 then
    close_popup_window()
    return
  end

  if not in_cmdline_mode() then
    close_popup_window()
    return
  end

  local cmdtype = active_cmdtype()
  local cmdline = vim.fn.getcmdline()
  if history_name(cmdtype) == nil or should_ignore_cmdline(cmdtype, cmdline) then
    close_popup_window()
    return
  end

  local buf = ensure_buffer()
  local visible_items, selected_row = popup_view(state.items)
  local lines, width = popup_lines(visible_items)
  local height = #lines
  local row, col = popup_position(width, height)

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(buf, state.ns, 0, -1)
  if selected_row >= 1 and selected_row <= #visible_items then
    vim.api.nvim_buf_add_highlight(buf, state.ns, 'PmenuSel', selected_row - 1, 0, -1)
  end
  vim.bo[buf].modifiable = false

  local config = {
    relative = 'editor',
    row = row,
    col = col,
    width = math.min(width + 1, math.max(vim.o.columns - 2, 1)),
    height = height,
    style = 'minimal',
    border = 'rounded',
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
    vim.wo[state.win].winhighlight = 'NormalFloat:Pmenu,FloatBorder:Pmenu'
  end

  redraw_cmdline_popup()
end

local function queue_popup_render()
  state.sync_target_seq = state.cmdline_seq
  if state.sync_pending then
    return
  end

  state.sync_pending = true
  vim.schedule(function()
    state.sync_pending = false
    if state.sync_target_seq == nil then
      return
    end

    if state.sync_target_seq ~= state.cmdline_seq then
      queue_popup_render()
      return
    end

    request_popup_sync()
  end)
end

function request_popup_sync()
  state.sync_pending = false
  state.sync_target_seq = nil

  local ok, err = pcall(render_popup)
  if ok then
    return
  end

  if type(err) == 'string' and err:find('E565', 1, true) ~= nil then
    if state.buf ~= nil and vim.api.nvim_buf_is_valid(state.buf) then
      vim.bo[state.buf].modifiable = false
    end
    queue_popup_render()
    return
  end

  error(err)
end

local function close_popup(restore_seed)
  if restore_seed and state.seed_cmdline ~= nil and state.seed_cmdpos ~= nil then
    local seed_cmdline = state.seed_cmdline
    local seed_cmdpos = state.seed_cmdpos
    state.previewing_item = false
    state.suppress_update_once = true
    reset_completion_state()
    clear_popup_state()
    apply_cmdline(seed_cmdline, seed_cmdpos)
    request_popup_sync()
    return
  else
    state.applying_item = false
  end
  reset_completion_state()
  clear_popup_state()
  request_popup_sync()
end

refresh_items = function(cmdline, cmdpos)
  local cmdtype = active_cmdtype()
  state.items = M.collect_items(cmdtype, cmdline, cmdpos - 1)

  if #state.items == 0 then
    state.selected = 0
    close_popup()
    return false
  end

  state.selected = math.min(math.max(state.selected, 1), #state.items)

  request_popup_sync()
  return true
end

start_completion = function()
  if not in_cmdline_mode() then
    return false
  end

  local cmdtype = active_cmdtype()
  if history_name(cmdtype) == nil then
    return false
  end

  local cmdline = vim.fn.getcmdline()
  if should_ignore_cmdline(cmdtype, cmdline) then
    return false
  end

  state.completion_active = true
  state.seed_cmdline = cmdline
  state.seed_cmdpos = vim.fn.getcmdpos()
  return refresh_items(state.seed_cmdline, state.seed_cmdpos)
end

local function schedule_popup_update(seq, delay_ms)
  state.refresh_token = state.refresh_token + 1
  local token = state.refresh_token

  vim.defer_fn(function()
    if token ~= state.refresh_token or state.cmdline_seq ~= seq or not in_cmdline_mode() then
      return
    end

    if vim.fn.wildmenumode() ~= 0 then
      close_popup()
      return
    end

    local cmdtype = active_cmdtype()
    local cmdline = vim.fn.getcmdline()
    local cmdpos = vim.fn.getcmdpos()
    if history_name(cmdtype) == nil or should_ignore_cmdline(cmdtype, cmdline) then
      close_popup()
      return
    end

    if not state.completion_active then
      start_completion()
      return
    end

    state.seed_cmdline = cmdline
    state.seed_cmdpos = cmdpos
    refresh_items(cmdline, cmdpos)
  end, delay_ms)
end

local function schedule_initial_completion(seq)
  schedule_popup_update(seq, 120)
end

local function update_popup()
  if not in_cmdline_mode() then
    close_popup()
    return
  end

  if vim.fn.wildmenumode() ~= 0 then
    close_popup()
    return
  end

  local cmdtype = active_cmdtype()
  local cmdline = vim.fn.getcmdline()
  local cmdpos = vim.fn.getcmdpos()

  if state.applying_item then
    state.applying_item = false
    if state.accepting_item then
      state.accepting_item = false
      return
    end
    if state.suppress_update_once then
      state.suppress_update_once = false
      request_popup_sync()
      return
    end
    if state.previewing_item then
      local item = state.items[state.selected]
      if item ~= nil and cmdline == item.word and cmdpos == item.cmdpos then
        request_popup_sync()
        return
      end
      state.previewing_item = false
    end
  elseif state.previewing_item then
    local item = state.items[state.selected]
    if item ~= nil and cmdline == item.word and cmdpos == item.cmdpos then
      request_popup_sync()
      return
    end
    state.previewing_item = false
  end

  if history_name(cmdtype) == nil or should_ignore_cmdline(cmdtype, cmdline) then
    close_popup()
    return
  end

  schedule_popup_update(state.cmdline_seq, 50)
end

local function cycle_item(step)
  if not state.completion_active and not start_completion() then
    return false
  end

  local count = #state.items
  if count == 0 then
    return false
  end

  state.selected = ((state.selected - 1 + step) % count) + 1
  local item = state.items[state.selected]
  state.previewing_item = true
  apply_cmdline(item.word, item.cmdpos)
  request_popup_sync()
  return true
end

local function accept_item()
  if not popup_visible() then
    return false
  end

  local selected = state.selected
  if selected <= 0 then
    selected = 1
  end

  local item = state.items[selected]
  if item == nil then
    close_popup(true)
    return false
  end

  state.selected = selected
  state.previewing_item = false
  state.accepting_item = true
  apply_cmdline(item.word, item.cmdpos)
  reset_completion_state()
  clear_popup_state()
  request_popup_sync()
  return true
end

local function expr_map(lhs, rhs, callback, desc)
  vim.keymap.set('c', lhs, function()
    if callback() then
      return '<Ignore>'
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
  ensure_flag('wildoptions', 'pum')

  local group = vim.api.nvim_create_augroup('rayx.cmdline_history', { clear = true })

  vim.api.nvim_create_autocmd('CmdlineEnter', {
    group = group,
    pattern = { ':', '/', '?' },
    callback = function(ev)
      state.cmdline_seq = state.cmdline_seq + 1
      state.cmdtype = ev.match
      state.applying_item = false
      state.accepting_item = false
      reset_completion_state()
      clear_popup_state()
      schedule_initial_completion(state.cmdline_seq)
    end,
    desc = 'Reset command-line popup session',
  })

  vim.api.nvim_create_autocmd('CmdlineChanged', {
    group = group,
    pattern = { ':', '/', '?' },
    callback = update_popup,
    desc = 'Update command-line history completion popup',
  })

  vim.api.nvim_create_autocmd('CmdlineLeave', {
    group = group,
    callback = function()
      state.cmdtype = nil
      state.applying_item = false
      state.accepting_item = false
      reset_completion_state()
      clear_popup_state()
      request_popup_sync()
    end,
    desc = 'Close command-line history popup',
  })

  vim.api.nvim_create_autocmd('ModeChanged', {
    group = group,
    pattern = 'c:*',
    callback = function()
      if in_cmdline_mode() then
        return
      end

      state.cmdtype = nil
      state.applying_item = false
      state.accepting_item = false
      reset_completion_state()
      clear_popup_state()
      request_popup_sync()
    end,
    desc = 'Close command-line popup after leaving cmdline mode',
  })

  expr_map('<Down>', '<Down>', function()
    if not popup_visible() then
      return false
    end
    return cycle_item(1)
  end, 'Command-line popup next')

  expr_map('<Up>', '<Up>', function()
    if not popup_visible() then
      return false
    end
    return cycle_item(-1)
  end, 'Command-line popup previous')

  expr_map('<C-n>', '<C-n>', function()
    if not popup_visible() then
      return false
    end
    return cycle_item(1)
  end, 'Command-line popup next')

  expr_map('<C-p>', '<C-p>', function()
    if not popup_visible() then
      return false
    end
    return cycle_item(-1)
  end, 'Command-line popup previous')

  expr_map('<Right>', '<Right>', accept_item, 'Accept command-line popup item')
  expr_map('<C-y>', '<C-y>', accept_item, 'Accept command-line popup item')
  expr_map('<Esc>', '<C-c>', function()
    if popup_visible() then
      close_popup(true)
      return true
    end

    return false
  end, 'Close command-line popup')

  vim.keymap.set('c', '<CR>', function()
    accept_item()
    return '<CR>'
  end, { expr = true, desc = 'Accept command-line popup item and execute' })

  vim.keymap.set('c', '<C-e>', function()
    if popup_visible() then
      close_popup(true)
      return '<Ignore>'
    end

    return '<C-e>'
  end, { expr = true, desc = 'Close command-line popup' })
end

return M
