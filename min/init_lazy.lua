vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.cmd([[set packpath=/tmp/nvim/lazy]])

local package_root = '/tmp/nvim/lazy'
local plugin_folder = function()
  local host = os.getenv('HOST_NAME')
  if host and (host:find('Ray') or host:find('ray')) then
    return [[~/github/ray-x]] -- vim.fn.expand("$HOME") .. '/github/'
  else
    return ''
  end
end

local lazypath = package_root .. '/lazy.nvim'
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
    { 'neovim/nvim-lspconfig' },
    {
      'nvim-treesitter/playground',
      lazy = true,
      cmd = 'TSPlaygroundToggle',
      config = function()
        require('nvim-treesitter.configs').setup({
          playground = {
            enable = true,
            disable = {},
            updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
            persist_queries = false, -- Whether the query persists across vim sessions
            keybindings = {
              toggle_query_editor = 'o',
              toggle_hl_groups = 'i',
              toggle_injected_languages = 't',
              toggle_anonymous_nodes = 'a',
              toggle_language_display = 'I',
              focus_language = 'f',
              unfocus_language = 'F',
              update = 'R',
              goto_node = '<cr>',
              show_help = '?',
            },
          },
        })
      end,
    },
    {
      'ray-x/go.nvim',
      dev = (plugin_folder() ~= ''),
      -- dev = true,
      ft = 'go',
      dependencies = {
        'mfussenegger/nvim-dap', -- Debug Adapter Protocol
        'rcarriga/nvim-dap-ui',
        'theHamsta/nvim-dap-virtual-text',
        'ray-x/guihua.lua',
      },
      config = function()
        require('go').setup({
          verbose = true,
          lsp_cfg = {
            handlers = {
              ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'double' }),
              ['textDocument/signatureHelp'] = vim.lsp.with(
                vim.lsp.handlers.signature_help,
                { border = 'round' }
              ),
            },
          }, -- false: do nothing
        })
      end,
    },
  }
end

local opts = {
  root = package_root, -- directory where plugins will be installed
  default = { lazy = true },
  dev = {
    -- directory where you store your local plugin projects
    path = plugin_folder(),
  },
}

require('lazy').setup(load_plugins(), opts)

vim.cmd('colorscheme murphy')
