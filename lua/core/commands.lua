local vim_path = require('core.global').vim_path
local path_sep = require('core.global').path_sep

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

vim.api.nvim_create_user_command('CompareDir', function(opts)
  -- for compareDir command
  local cmpdir_group = api.nvim_create_augroup('CompareDir', {})
  api.nvim_create_autocmd({ 'BufWinLeave' }, {
    group = cmpdir_group,
    pattern = { '*' },
    callback = function()
      local tabpage_number = vim.fn.tabpagenr() -- Get the current tab page number
      local is_set = vim.fn.haslocalvar("t:compare_mode", tabpage_number)

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
      local is_set = vim.fn.haslocalvar("t:compare_mode", tabpage_number)
      if is_set == 0 then return end

      if vim.bo.bt == '' then
        vim.api.nvim_buf_set_option(0, 'diff', true)
        vim.api.nvim_buf_set_option(0, 'cursorbind', true)
        vim.api.nvim_buf_set_option(0, 'scrollbind', true)
        vim.api.nvim_buf_set_option(0, 'foldmethod', 'diff')
        vim.api.nvim_buf_set_option(0, 'foldlevel', 0)
      else
        vim.api.nvim_buf_set_option(0, 'diff', false)
        vim.api.nvim_buf_set_option(0, 'cursorbind', false)
        vim.api.nvim_buf_set_option(0, 'scrollbind', false)
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
  vim.fn.feedkeys(":call <SID>Opsort()<CR>")

end, { nargs = '+', complete = 'dir' })