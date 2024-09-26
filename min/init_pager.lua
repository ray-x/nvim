-- used for pager, e.g. pgsql output

local plugin_folder = function()
  local host = os.getenv('HOST_NAME')
  if host and (host:find('Ray') or host:find('ray')) then
    return [[~/github/ray-x]] -- vim.fn.expand("$HOME") .. '/github/'
  else
    return ''
  end
end
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
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
      'nvim-treesitter/nvim-treesitter',
      config = function()
        require('nvim-treesitter.configs').setup({
          ensure_installed = { 'go' },
          highlight = { enable = true },
        })
      end,
      build = ':TSUpdate',
    },
    {
      'ray-x/aurora',
      dev = (plugin_folder() ~= ''),
      lazy = true,
      init = function()
        vim.g.aurora_italic = 1
        vim.g.aurora_transparent = 1
        vim.g.aurora_bold = 1
      end,
    },
    {
      'mechatroner/rainbow_csv',
      ft = { 'csv', 'tsv', 'dat' },
      cmd = { 'RainbowDelim', 'RainbowMultiDelim', 'Select', 'CSVLint' },
    },
  }
end

local opts = {
  default = { lazy = true },
  dev = {
    -- directory where you store your local plugin projects
    path = plugin_folder(),
  },
}

require('lazy').setup(load_plugins(), opts)
require('pager')
vim.g.csv_delim_test = ',;|'
