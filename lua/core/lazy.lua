local api = vim.api
local argc = vim.fn.argc() or 0

if argc > 0 then
  local arg = vim.fn.argv()
  for i = 1, argc do
    if arg[i] == '--headless' then
      return
    end
  end
  if arg[1] and vim.fn.isdirectory(arg[1]) == 1 then
    vim.defer_fn(function()
      require('telescope').extensions.file_browser.file_browser()
    end, 200)
  end
end

lprint('I am lazy begin', vim.loop.now() - require('core.global').start)
local loader = require('utils.helper').loader

-- Create cache dir and subs dir
local global = require('core.global')
-- load module but not init/config it
function setup(fsize)
  require('core.helper').init()
  local start = require('core.global').start

  lprint('lazy core plugins start', vim.loop.now() - start)
  lprint('I am lazy', vim.loop.now() - start)
  local disable_ft = {
    'NvimTree',
    'guihua',
    'neo-tree',
    'packer',
    'guihua_rust',
    'clap_input',
    'clap_spinner',
    'TelescopePrompt',
    'csv',
    'txt',
    'defx',
  }

  fsize = fsize or vim.fn.getfsize(vim.fn.expand('%:p:f'))
  if fsize == nil or fsize < 0 then
    fsize = 1
  end

  local syn_on = not vim.tbl_contains(disable_ft, vim.bo.filetype)

  -- local fname = vim.fn.expand("%:p:f")
  -- if fsize > 2 * 1024 * 1024 then
  --   lprint('syntax off')
  --   print('syntax off, enable it by :setlocal syntax=on')
  --   vim.cmd([[syntax off]])
  -- else
  --   if not syn_on then
  --     vim.cmd([[syntax manual]])
  --   end
  -- end
  lprint('syntax', vim.uv.now() - start)

  vim.g.vimsyn_embed = 'lPr'

  -- vim.cmd([[autocmd FileType vista,guihua,guihua_rust setlocal syntax=on]])
  -- vim.cmd(
  --   [[autocmd FileType * silent! lua if vim.fn.wordcount()['bytes'] > 2048000 then print("syntax off") vim.cmd("setlocal syntax=off") end]]
  -- )
  vim.cmd([[doautocmd User LoadLazyPlugin]])
  vim.cmd('tabdo windo set relativenumber')
  -- vim.cmd('highlight clear ColorColumn')
  -- vim.cmd("command! Gram lua require'modules.tools.config'.grammcheck()")
  lprint('lazy colorscheme loaded', vim.uv.now() - start)
end

local lazy_timer = 20

--

require('modules.ui.notify').setup()
-- vim.notify = require('notify')

if vim.fn.isdirectory(arg[1]) == 1 then
  loader('telescope.nvim')
  loader('telescope-file-browser.nvim')
end
-- lprint("all done", os.clock())
if vim.fn.executable(vim.g.python3_host_prog) == 0 then
  print('file not find, please update path setup', vim.g.python3_host_prog)
end
require('core.ab')

if plugin_folder() == [[~/github/ray-x/]] then
  -- it is my own box, setup fish
  if vim.o.shell ~= 'fish' and vim.fn.executable('fish') == 1 then
    if global.is_mac then
      vim.cmd([[set shell=/opt/homebrew/bin/fish]])
    elseif global.is_linux then
      vim.cmd([[set shell=/usr/bin/fish]])
    else
      vim.cmd([[set shell=sh ]])
    end
    vim.cmd([[command! GD term gd]])
  end
  -- vim.cmd([[set shell=/usr/bin/fish]])
end

vim.cmd('set runtimepath+=/usr/share/vim/vimfiles')
vim.cmd('runtime! plugin/fzf.vim')

vim.defer_fn(function()
  if vim.fn.empty(vim.fn.expand('%')) == 1 then
    local folder = vim.fn.getcwd()
    folder = require('utils.selfunc').convertPathToPercentString(folder) .. '.vim'
    lprint('auto-session load', folder)
    local r = require('mini.sessions').read
    pcall(r, folder)

    lprint('auto-session loaded', folder, vim.fn.empty(folder))
    if vim.fn.empty(vim.v.this_session) == 1 then
      lprint('no session folder found')
      lprint('save session to ' .. folder)
      require('mini.sessions').write(folder)
    end
  end
end, lazy_timer)
return { setup = setup }
