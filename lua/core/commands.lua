local vim_path = require('core.global').vim_path
local path_sep = require('core.global').path_sep

-- following command are capable of call with nvim +"Command args"
vim.api.nvim_create_user_command('DiffDir', function(opts)
  if vim.g.loaded_dirdiff then
    vim.cmd(string.format('DirDiff %s %s', opts.fargs[1], opts.fargs[2]))
  else
    cmd = ' source ' .. vim_path .. path_sep .. 'scripts' .. path_sep .. 'diffdir.vim'
    lprint(cmd)
    vim.api.nvim_exec(cmd, false)
    vim.cmd(string.format('DirDiff %s %s', opts.fargs[1], opts.fargs[2]))
  end
end, { nargs = '+', complete = 'dir' })

