local vim_path = require('core.global').vim_path
local path_sep = require('core.global').path_sep
local api = vim.api

-- following command are capable of call with nvim +"Command args"
vim.api.nvim_create_user_command('DiffDir', function(opts)
  if vim.g.loaded_dirdiff then
    vim.cmd(string.format('DirDiff %s %s', opts.fargs[1], opts.fargs[2]))
  else
    local cmd = ' source ' .. vim_path .. path_sep .. 'scripts' .. path_sep .. 'diffdir.vim'
    lprint(cmd)
    vim.api.nvim_exec(cmd, false)
    vim.cmd(string.format('DirDiff %s %s', opts.fargs[1], opts.fargs[2]))
  end
end, { nargs = '+', complete = 'dir' })


-- Tmp is a command to create a temporary file
vim.api.nvim_create_user_command('Tmp', function(opts)
  local path = vim.fn.tempname()
  vim.cmd('e ' .. path)
  -- delete the file when the buffer is closed
  vim.cmd('au BufDelete <buffer> !rm -f ' .. path)
end, { nargs = '*' })

vim.api.nvim_create_user_command('CompareDir', function(opts)
  -- for compareDir command
  local cmpdir_group = api.nvim_create_augroup('CompareDir', {})
  api.nvim_create_autocmd({ 'BufWinLeave' }, {
    group = cmpdir_group,
    pattern = { '*' },
    callback = function()
      local tabpage_number = vim.fn.tabpagenr() -- Get the current tab page number
      local is_set = vim.fn.haslocalvar('t:compare_mode', tabpage_number)

      if is_set == 1 then
        -- The tab-local variable 'my_variable' is set
        vim.bo.diff = false
      end
    end,
  })

  api.nvim_create_autocmd({ 'BufEnter' }, {
    group = cmpdir_group,
    pattern = { '*' },
    callback = function()
      local tabpage_number = vim.fn.tabpagenr() -- Get the current tab page number
      local is_set = vim.fn.haslocalvar('t:compare_mode', tabpage_number)
      if is_set == 0 then
        return
      end
      local bufnr = vim.api.nvim_get_current_buf()

      if vim.bo.bt == '' then
        vim.api.nvim_set_option_value('diff', true, {buf = bufnr})
        vim.api.nvim_set_option_value('cursorbind', true, {buf = bufnr})
        vim.api.nvim_set_option_value('scrollbind', true, {buf = bufnr})
        vim.api.nvim_set_option_value('foldmethod', 'diff', {buf = bufnr})
        vim.api.nvim_set_option_value('foldlevel', 0, {buf = bufnr})
      else
        vim.api.nvim_set_option_value('diff', false, {buf = bufnr})
        vim.api.nvim_set_option_value('cursorbind', false, {buf = bufnr})
        vim.api.nvim_set_option_value('scrollbind', false, {buf = bufnr})
      end
    end,
  })

  local paths = opts.fargs

  -- Create a new tab
  vim.cmd('tabnew')
  vim.cmd('let t:compare_mode = 1')

  -- Open a vertical split
  vim.cmd('vsp')

  -- Set the current working directory for the first and second window
  vim.cmd('1windo lcd ' .. paths[1])
  vim.cmd('2windo lcd ' .. paths[2])

  -- Change the current working directory for all windows to getcwd()
  vim.cmd('windo exe "exe \\"edit \\" . getcwd()"')
end, { nargs = '+', complete = 'dir' })

vim.api.nvim_create_user_command('Opsort', function()
  if not vim.g.loaded_opsort then
    local cmd = ' source ' .. vim_path .. path_sep .. 'scripts' .. path_sep .. 'sort.vim'
    vim.cmd(cmd)
  end
  vim.cmd([[command! -nargs=* Sort execute 'normal! <Plug>Opsort']])
  vim.fn.feedkeys(':call <SID>Opsort()<CR>')
end, { nargs = '+', complete = 'dir' })

vim.api.nvim_create_user_command('IndentEnable', function()
  require('ibl').setup_buffer(0, {
    enabled = true,
  })
end, {})

vim.api.nvim_create_user_command('IndentToggle', function()
  require('ibl').setup_buffer(0, {
    enabled = not require('ibl.config').get_config(0).enabled,
  })
end, {})

vim.cmd([[command! -nargs=*  DebugOpen lua require"modules.lang.dap".prepare()]])
vim.cmd([[command! -nargs=*  Format lua vim.lsp.buf.format({async=true}) ]])
vim.cmd([[command! -nargs=*  HarpoonClear lua require"harpoon.mark".clear_all()]])
vim.cmd([[command! -nargs=*  HarpoonOpen lua require"harpoon.mark".clear_all()]])

-- bind.nvim_load_mapping(plugmap)

vim.api.nvim_create_user_command('Keymaps', function()
  local ListView = require('guihua.listview')
  return ListView:new({
    loc = 'top_center',
    border = 'none',
    prompt = true,
    enter = true,
    rect = { height = 20, width = 90 },
    data = require('keymap.bind').all_keys,
  })
end, {})

vim.api.nvim_create_user_command('Jsonfmt', function(opts)
  if vim.fn.executable('jq') == 0 then
    lprint('jq not found')
    return vim.cmd([[%!python -m json.tool]])
  end
  vim.cmd('%!jq')
end, { nargs = '*' })

-- with file name or bang
vim.api.nvim_create_user_command('NewOrg', function(opts)
  local fn
  if vim.fn.empty(opts.fargs) == 0 then
    fn = opts.fargs[1]
  end
  local path = vim.fn.expand('~/Library/CloudStorage/Dropbox/Logseq')
  local j = opts.bang or fn
  if j then
    -- this is a page
    path = path .. '/pages/'
  else
    path = path .. '/journals/'
    fn = vim.fn.strftime('%Y_%m_%d') .. '.org'
  end

  vim.cmd('e ' .. path .. fn)
  -- check if file existed
  if vim.fn.filereadable(vim.fn.expand(path .. fn)) == 1 then
    return
  end
  if j then
    vim.api.nvim_buf_set_lines(0, 0, 1, false, { '* TODO' })
  else
    -- stylua: ignore
    vim.api.nvim_buf_set_lines( 0, 0, 6, false, { '#+TITLE: ', '#+AUTHER: Ray', '#+Date: ' .. vim.fn.strftime('%c'), '', '* 1st', '* 2nd' }
    )
  end
end, { nargs = '*', bang = true })

vim.api.nvim_create_user_command('Flg', 'Flog -date=short', { nargs = '*' })
vim.api.nvim_create_user_command('Flgs', 'Flogsplit -date=short', {})
vim.api.nvim_create_user_command('SessionSave', function(_)
  local m = require('mini.sessions')
  local folder = _G.FindRoot()
  folder = require('utils.selfunc').convertPathToPercentString(folder) .. '.vim'
  -- lprint(folder)
  m.write(folder)
end, {})

vim.api.nvim_create_user_command('SessionLoad', function(_)
  local m = require('mini.sessions')
  local folder = _G.FindRoot()
  folder = require('utils.selfunc').convertPathToPercentString(folder) .. '.vim'
  -- lprint('load session', folder)
  m.read(folder)
end, {})

vim.api.nvim_create_user_command('SessionSelect', function(_)
  local m = require('mini.sessions')
  m.select()
end, {})
vim.api.nvim_create_user_command('SessionDelete', function(_)
  local m = require('mini.sessions')
  local folder = require('utils.selfunc').convertPathToPercentString(_G.FindRoot()) .. '.vim'
  m.delete(folder, { force = true })
end, {})
vim.api.nvim_create_user_command('ResetWorkspace', function(opts)
  local folder = opts.fargs[1] or vim.fn.expand('%:p:h')
  local workspaces = vim.lsp.buf.list_workspace_folders()
  for _, v in ipairs(workspaces) do
    if v ~= folder or vim.fn.isdirectory(v) == 0 then
      vim.lsp.buf.remove_workspace_folder(v)
    end
  end
end, { nargs = '*', bang = true })
