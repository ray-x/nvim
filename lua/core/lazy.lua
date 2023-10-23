local api = vim.api
local argc = vim.fn.argc() or 0

if argc > 0 then
  local arg = vim.fn.argv()
  for i = 1, argc do
    if arg[i] == '--headless' then
      return
    end
  end
  if vim.fn.isdirectory(arg[1]) == 1 then
    vim.cmd('NeoTreeFloat')
  end
end

lprint('I am lazy begin', vim.loop.now() - require('core.global').start)
local loader = require('utils.helper').loader

local fsize = vim.fn.getfsize(vim.fn.expand('%:p:f'))
if fsize == nil or fsize < 0 then
  fsize = 1
end

local load_ts_plugins = true
local load_lsp = true

if fsize > 1024 * 1024 then
  load_ts_plugins = false
  load_lsp = false
end

-- Create cache dir and subs dir
local createdir = function()
  local global = require('core.global')
  local data_dir = {
    global.cache_dir .. global.path_sep .. 'backup',
    global.cache_dir .. global.path_sep .. 'sessions',
    global.cache_dir .. global.path_sep .. 'swap',
    global.cache_dir .. global.path_sep .. 'tags',
    global.cache_dir .. global.path_sep .. 'undo',
  }
  -- There only check once that If cache_dir exists
  -- Then I don't want to check subs dir exists
  if vim.fn.isdirectory(global.cache_dir) == 0 then
    os.execute('mkdir -p ' .. global.cache_dir)
    for _, v in pairs(data_dir) do
      if vim.fn.isdirectory(v) == 0 then
        os.execute('mkdir -p ' .. v)
      end
    end
  end
end

if vim.wo.diff then
  -- loader(plugins)
  if load_ts_plugins then
    loader('nvim-treesitter')
    require('nvim-treesitter.configs').setup({
      highlight = { enable = true, use_languagetree = false },
    })
  else
    vim.cmd([[syntax on]])
  end
  return
end

-- load module but not init/config it
function setup()
  require('core.helper').init()
  local start = require('core.global').start

  lprint('lazy core plugins start', vim.loop.now() - start)
  createdir()
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

  local syn_on = not vim.tbl_contains(disable_ft, vim.bo.filetype)


  -- local fname = vim.fn.expand("%:p:f")
  if fsize > 2 * 1024 * 1024 then
    lprint('syntax off')
    print('syntax off, enable it by :setlocal syntax=on')
    load_lsp = false
    load_ts_plugins = false
    vim.cmd([[syntax off]])
  else
    if not syn_on then
      vim.cmd([[syntax manual]])
    end
  end
  lprint('syntax', vim.loop.now() - start)

  vim.g.vimsyn_embed = 'lPr'

  -- if load_lsp then
  --   loader('nvim-lspconfig')
  --   loader('lsp_signature.nvim')
  -- end

  -- loader('guihua.lua')

  vim.cmd([[autocmd FileType vista,guihua,guihua_rust setlocal syntax=on]])
  vim.cmd(
    [[autocmd FileType * silent! lua if vim.fn.wordcount()['bytes'] > 2048000 then print("syntax off") vim.cmd("setlocal syntax=off") end]]
  )
  vim.cmd([[doautocmd User LoadLazyPlugin]])
  vim.cmd('tabdo windo set relativenumber')
  vim.cmd('highlight clear ColorColumn')
  vim.cmd("command! Gram lua require'modules.tools.config'.grammcheck()")
  lprint('lazy colorscheme loaded', vim.loop.now() - start)
end

local lazy_timer = 5
setup()

--

require('overwrite')
-- loader('telescope.nvim')
-- loader('harpoon')
-- loader('nvim-notify')
require('modules.ui.notify').setup()
-- vim.notify = require('notify')

-- lprint("all done", os.clock())
if vim.fn.executable(vim.g.python3_host_prog) == 0 then
  print('file not find, please update path setup', vim.g.python3_host_prog)
end
require('core.ab')

if plugin_folder() == [[~/github/ray-x/]] then
  -- it is my own box, setup fish
  -- vim.cmd([[set shell=/usr/bin/fish]])
  vim.cmd([[command! GD term gd]])
end

vim.cmd('set runtimepath+=/usr/share/vim/vimfiles')
vim.cmd('runtime! plugin/fzf.vim')

vim.defer_fn(function()
  -- vim.cmd('source /home/ray/.local/share/nvim/sessions/nvim.vim')
  local start = vim.loop.now()
  if vim.fn.empty(vim.fn.expand('%')) == 1 then
    local bufnr = vim.fn.bufnr()
    require('auto-session').RestoreSession()
    -- close nameless buffers
    if api.nvim_buf_is_valid(bufnr) then
      api.nvim_buf_delete(bufnr, { force = true })
    end
  end
  lprint('auto-session loaded', vim.loop.now() - start)
end, lazy_timer)
