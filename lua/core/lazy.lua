-- local loader = require('utils.helper').loader
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
lprint('lazy')
local loader = require('utils.helper').loader
local start = vim.loop.now()
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
    global.cache_dir .. 'backup',
    global.cache_dir .. 'session',
    global.cache_dir .. 'swap',
    global.cache_dir .. 'tags',
    global.cache_dir .. 'undo',
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
    vim.cmd([[packadd nvim-treesitter]])
    require('nvim-treesitter.configs').setup({
      highlight = { enable = true, use_languagetree = false },
    })
  else
    vim.cmd([[syntax on]])
  end
  return
end
local colorscheme

-- load module but not init/config it
function Lazyload()
  -- vim.cmd([[packadd nvim-treesitter]])
  -- vim.cmd([[packadd nvim-lspconfig]])
  require('core.helper').init()

  lprint('lazy core plugins start', vim.loop.now() - start)
  -- loader('impatient.nvim')
  createdir()
  lprint('I am lazy')
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
  if not syn_on then
    vim.cmd([[syntax manual]])
  end

  local load_go = vim.tbl_contains({ 'go', 'gomod' }, vim.bo.filetype)
  if load_go then
    loader('go.nvim')
  end

  -- local fname = vim.fn.expand("%:p:f")
  if fsize > 2 * 1024 * 1024 then
    lprint('syntax off')
    print('syntax off, enable it by :setlocal syntax=on')
    load_lsp = false
    load_ts_plugins = false
    vim.cmd([[syntax off]])
  end
  -- if load_ts_plugins then
  --   lprint('loading treesitter')
  --   vim.defer_fn(function()
  --     loader('nvim-treesitter')
  --   end, 10)
  -- end

  lprint('lazy core ts plugins loaded', vim.loop.now() - start)
  local plugins = 'plenary.nvim'
  loader('plenary.nvim')

  if vim.bo.filetype == 'lua' then
    loader('neodev.nvim')
  end

  vim.g.vimsyn_embed = 'lPr'

  if load_lsp then
    loader('nvim-lspconfig')
    loader('lsp_signature.nvim')
  end

  loader('guihua.lua')
  if load_lsp or load_ts_plugins then
    loader('nvim-treesitter')
    loader('navigator.lua')
  end

  lprint('lazy core lsp plugins loaded', vim.loop.now() - start)
  if load_ts_plugins then
    lprint('loading treesitter related plugins')
    plugins =
      'nvim-treesitter-textobjects nvim-ts-autotag nvim-ts-context-commentstring nvim-treesitter-textsubjects nvim-treehopper nvim-treesitter-context'
    loader(plugins)
    -- lprint(plugins .. " loaded", os.clock())
    loader('neogen')
    loader('refactoring.nvim')
    loader('indent-blankline.nvim')
    loader('hlargs.nvim')
    if vim.fn.line('$') < 3000 then
      loader('nvim-ts-rainbow2')
    end

    lprint('ts loaded')
  end

  vim.cmd([[autocmd FileType vista,guihua,guihua_rust setlocal syntax=on]])
  vim.cmd(
    [[autocmd FileType * silent! lua if vim.fn.wordcount()['bytes'] > 2048000 then print("syntax off") vim.cmd("setlocal syntax=off") end]]
  )

  if load_lsp and use_nulls() then
    loader('null-ls.nvim')
  end

  loader('bufferline.nvim')
  -- lprint("LoadLazyPlugin finished", os.clock())

  lprint('lazy colorscheme loaded', vim.loop.now() - start)
end

local lazy_timer = 5

vim.defer_fn(function()
  Lazyload()
  vim.cmd([[doautocmd User LoadLazyPlugin]])
end, lazy_timer)

vim.defer_fn(function()
  lprint('lazy telescope start', vim.loop.now() - start)
  vim.cmd('tabdo windo set relativenumber')
  vim.cmd('highlight clear ColorColumn')
  loader('virtcolumn.nvim')
  require('vscripts.tools')
  vim.cmd("command! Gram lua require'modules.tools.config'.grammcheck()")

  loader('windline.nvim')
  require('modules.ui.eviline')
  lprint('lazy wlfloat loaded', vim.loop.now() - start)
end, lazy_timer + 5)
--
vim.defer_fn(function()
  require('overwrite')
  loader('telescope.nvim')
  -- load from
  -- loader("telescope-zoxide project.nvim nvim-neoclip.lua")
  loader('harpoon')
  -- loader('nvim-notify')
  require('modules.ui.notify').setup()
  -- vim.notify = require('notify')
  -- require("vscripts.cursorhold")

  local gitrepo = vim.fn.isdirectory('.git/index')
  loader('hydra.nvim')
  if gitrepo then
    loader('gitsigns.nvim') -- neogit
    loader('git-conflict.nvim')
    require('modules.editor.hydra').hydra_git()
  end

  loader('statuscol.nvim')
  -- lprint("all done", os.clock())
  if vim.fn.executable(vim.g.python3_host_prog) == 0 then
    print('file not find, please update path setup', vim.g.python3_host_prog)
  end
  lprint('lazy telescope loaded', vim.loop.now() - start)
  require('core.ab')
end, lazy_timer + 10)

if plugin_folder() == [[~/github/ray-x/]] then
  -- it is my own box, setup fish
  -- vim.cmd([[set shell=/usr/bin/fish]])
  vim.cmd([[command! GD term gd]])
end
require('core.colorscheme')
vim.defer_fn(function()
  loader('auto-session')
  -- require('mini.sessions').setup({
  -- autoread = true,
  -- Whether to write current session before quitting Neovim
  -- autowrite = true,
  -- })
  -- MiniSessions.on_vimenter()

  vim.cmd('set runtimepath+=/usr/share/vim/vimfiles')
  vim.cmd('runtime! plugin/fzf.vim')
end, 0)

vim.defer_fn(function()
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
end, 30)
