-- used for nvim as pager

local plugin_folder = function()
  local host = os.getenv('HOST_NAME')
  if host and (host:find('Ray') or host:find('ray')) then
    return [[~/github/ray-x]] -- vim.fn.expand("$HOME") .. '/github/'
  else
    return ''
  end
end
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
local function load_plugins()
  return {
    {
      'neovim-treesitter/nvim-treesitter',
      lazy = false,
      build = ':TSUpdate',
      dependencies = { 'neovim-treesitter/treesitter-parser-registry', lazy = false },
    },
    {
      'mechatroner/rainbow_csv',
      ft = { 'csv', 'tsv', 'dat', 'csv_pipe' },
      cmd = { 'RainbowDelim', 'RainbowMultiDelim', 'Select', 'CSVLint' },
      -- config = function()
      --   vim.cmd('set ft=csv_pipe')
      -- end,
    },
    {
      'chrisbra/csv.vim',
      lazy = false,
      init = function()
        vim.cmd('auto BufReadPost *.csv,*.tsv,*.dat,*.csv_pipe,*.dbout setlocal filetype=csv')
        vim.g.csv_delim_test = ',;|'
      end,
    },
  }
end

local opts = {
  -- default = { lazy = true },
  dev = {
    -- directory where you store your local plugin projects
    path = plugin_folder(),
  },
}
require('lazy').setup(load_plugins(), opts)
require('pager').stage1()
require('pager').stage2()

-- color
-- require('modules.ui.galaxy').shine()

vim.api.nvim_set_hl(0, 'Normal', { fg = 'None' })
