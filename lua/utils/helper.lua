-- retreives data form file
-- and line to highlight
-- first wrote by https://github.com/RishabhRD/nvim-lsputils

local M = {
  log_path = vim.lsp.get_log_path(),
}
function M.loader(modules)
  -- lazy loading
  -- assuming lazy.nvim is used
  local lazy = require('lazy')
  if type(modules) == 'string' then
    modules = vim.fn.split(modules, ' ')
  end
  lazy.load({ plugins = modules })
end
function M.get_data_from_file(filename, startLine)
  local displayLine
  if startLine < 3 then
    displayLine = startLine
    startLine = 0
  else
    startLine = startLine - 2
    displayLine = 2
  end
  local uri = 'file://' .. filename
  local bufnr = vim.uri_to_bufnr(uri)
  vim.fn.bufload(bufnr)
  local data = vim.api.nvim_buf_get_lines(bufnr, startLine, startLine + 8, false)
  if data == nil or vim.tbl_isempty(data) then
    startLine = nil
  else
    local len = #data
    startLine = startLine + 1
    for i = 1, len, 1 do
      data[i] = startLine .. ' ' .. data[i]
      startLine = startLine + 1
    end
  end
  return {
    data = data,
    line = displayLine,
  }
end

function M.get_base(path)
  local len = #path
  for i = len, 1, -1 do
    if path:sub(i, i) == '/' then
      local ret = path:sub(i + 1, len)
      return ret
    end
  end
end

function M.getDirectores(path)
  local data = {}
  local len = #path
  if len <= 1 then
    return nil
  end
  local last_index = 1
  for i = 2, len do
    local cur_char = path:sub(i, i)
    if cur_char == '/' then
      local my_data = path:sub(last_index + 1, i - 1)
      table.insert(data, my_data)
      last_index = i
    end
  end
  return data
end

function M.get_relative_path(base_path, my_path)
  local base_data = M.getDirectores(base_path)
  local my_data = M.getDirectores(my_path)
  local base_len = #base_data
  local my_len = #my_data

  if base_len > my_len then
    return my_path
  end

  if base_data[1] ~= my_data[1] then
    return my_path
  end

  local cur = 0
  for i = 1, base_len do
    if base_data[i] ~= my_data[i] then
      break
    end
    cur = i
  end
  local data = ''
  for i = cur + 1, my_len do
    data = data .. my_data[i] .. '/'
  end
  data = data .. M.get_base(my_path)
  return data
end

function M.handleGlobalVariable(var, opts)
  if var == nil then
    return
  end
  opts.mode = var.mode or opts.mode
  opts.height = var.height or opts.height
  if opts.height == 0 then
    if opts.mode == 'editor' then
      opts.height = nil
    elseif opts.mode == 'split' then
      opts.height = 12
    end
  end
  opts.width = var.width
  if var.keymaps then
    if not opts.keymaps then
      opts.keymaps = {}
    end
    if var.keymaps.i then
      if not opts.keymaps.i then
        opts.keymaps.i = {}
      end
      for k, v in pairs(var.keymaps.i) do
        opts.keymaps.i[k] = v
      end
    end
    if var.keymaps.n then
      if not opts.keymaps.n then
        opts.keymaps.n = {}
      end
      for k, v in pairs(var.keymaps.n) do
        opts.keymaps.n[k] = v
      end
    end
  end
  if var.list then
    if not (var.list.numbering == nil) then
      opts.list.numbering = var.list.numbering
    end
    if not (var.list.border == nil) then
      opts.list.border = var.list.border
    end
    opts.list.title = var.list.title or opts.list.title
    opts.list.border_chars = var.list.border_chars
  end
  if var.preview and opts.preview then
    if not (var.preview.numbering == nil) then
      opts.preview.numbering = var.preview.numbering
    end
    if not (var.preview.border == nil) then
      opts.preview.border = var.preview.border
    end
    opts.preview.title = var.preview.title or opts.preview.title
    opts.preview.border_chars = var.preview.border_chars
  end
  if var.prompt then
    opts.prompt = {
      border_chars = var.prompt.border_chars,
      coloring = var.prompt.coloring,
      prompt_text = 'Symbols',
      search_type = 'plain',
      border = true,
    }
    if var.prompt.border == false or var.prompt.border == true then
      opts.prompt.border = var.prompt.border
    end
  end
end

function M.setFiletype(buffer, type)
  vim.api.nvim_buf_set_option(buffer, 'filetype', type)
end

-- add log to you lsp.log
function M.log(...)
  local arg = { ... }
  if vim.g.codeagent_verbose == true then
    local str = '[CAT]'
    for i, v in ipairs(arg) do
      if v ~= nil then
        str = str .. ' | ' .. vim.inspect(v) .. '\n'
      else
        str = str .. ' | ' .. 'nil'
      end
    end
    if #str > 5 then
      if #M.log_path > 3 then
        local f = io.open(M.log_path, 'a+')
        io.output(f)
        io.write(str)
        io.close(f)
      end
    end
    print(str)
  end
end

function M.split(inputstr, sep)
  if sep == nil then
    sep = '%s'
  end
  local t = {}
  for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
    table.insert(t, str)
  end
  return t
end

function M.getArgs(inputstr)
  local sep = '%s'
  local t = {}
  local cmd
  for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
    if not cmd then
      cmd = str
    else
      table.insert(t, str)
    end
  end
  return cmd, t
end

function M.p(t)
  print(vim.inspect(t))
end

function M.printError(msg)
  vim.cmd('echohl ErrorMsg')
  vim.cmd(string.format([[echomsg '%s']], msg))
  vim.cmd('echohl None')
end

function M.reload()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
  vim.cmd([[edit]])
end

function M.open_log()
  local path = vim.lsp.get_log_path()
  vim.cmd('edit ' .. path)
end

function M.exists(var)
  for k, _ in pairs(_G) do
    if k == var then
      return true
    end
  end
end

function M.P(v)
  print(vim.inspect(v))
end

function M.newbinsource(cmd)
  return function()
    local file = io.popen(cmd)
    local output = file:read('*all')
    file:close()
    output = vim.split(output, '\n')
    return output
  end
end

function M.x86()
  local arch = vim.fn.system('uname -m')
  if arch == 'i386' or arch == 'x86_64' then
    return 'x86'
  else
    return 'arm'
  end
end

function M.calculate_selection(append)
  local selection = M.get_visual_text()
  local result = vim.fn.eval(selection)
  print(result)
  if append then
    local line = vim.fn.getline('.')
    if not line:match('=%s*$') then
      result = ' = ' .. result
    end
    vim.fn.setline('.', line .. result)
  end
end

function M.get_visual_text()
  local s, e = vim.fn.getpos("'<"), vim.fn.getpos("'>")
  local n = math.abs(e[2] - s[2]) + 1
  -- print(vim.inspect(s), vim.inspect(e), n)
  local lines = vim.api.nvim_buf_get_lines(0, s[2] - 1, e[2], false)
  lines[1] = string.sub(lines[1], s[3], -1)
  if n == 1 then
    lines[n] = string.sub(lines[n], 1, e[3] - s[3] + 1)
  else
    lines[n] = string.sub(lines[n], 1, e[3])
  end

  return table.concat(lines, '\n'), n
end

function M.getword()
  local w, l
  if vim.fn.mode() == 'v' or vim.fn.mode() == 'x' then
    w, l = M.get_visual_text()
  end
  if not l or l > 1 then
    w = vim.fn.expand('<cword>')
  end
  return w
end

function M.substitute(from, to, style)
  from = vim.fn.expand('<cword>')
  style = style or 's'
  local cmd

  if vim.fn.mode() == 'v' or vim.fn.mode() == 'x' then
    local w, l = M.get_visual_text()
    -- lprint(l)
    if l == 1 then
      from = w
      to = to or from
      cmd = string.format(':%%%s/%s/%s/g', style, from, to)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'x', true)
    else -- a range specified
      from = vim.fn.getreg('"')
      to = to or from
      lprint(from, to)
      cmd = string.format(':%%%s/%s/%s/g', style, from, to)
    end
  else
    to = to or from
    cmd = string.format(':%%%s/%s/%s/', style, from, to)
  end

  cmd = vim.api.nvim_replace_termcodes(cmd, true, false, true)
  return cmd
end
vim.keymap.set({ 'n', 'x' }, '<leader>s', function()
  vim.api.nvim_feedkeys(M.substitute(), 'mi', true)
end, { silent = true, expr = true })

return M
