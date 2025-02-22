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
local dev = (plugin_folder() ~= '')
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
      'ray-x/navigator.lua',
      dev = dev,
      module = true,
      event = { 'VeryLazy' },
      opts = {
        width = 0.7,
        lsp = {
          diagnostic = { enable = true },
          rename = { style = 'floating-preview' },
        },
      },
    },
    {
      'ray-x/lsp_signature.nvim',
      dev = dev,
      event = { 'InsertEnter' },
      opts = {
        bind = true,
        -- doc_lines = 4,
        floating_window = true,
        -- floating_window_above_cur_line = false,
        hint_enable = true,
        fix_pos = false,
        -- floating_window_above_first = true,
        log_path = vim.fn.expand('$HOME') .. '/tmp/sig.log',
        -- hi_parameter = "Search",
        zindex = 1002,
        timer_interval = 100,
        extra_trigger_chars = {},
        handler_opts = {
          border = 'rounded', -- "shadow", --{"╭", "─" ,"╮", "│", "╯", "─", "╰", "│" },
        },
        max_height = 4,
        toggle_key = [[<M-x>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
        select_signature_key = [[<M-c>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
        move_cursor_key = [[<M-n>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
        move_signature_window_key = { '<M-Up>', '<M-Down>' },
      },
      {
        'ray-x/aurora',

        dev = dev,
        lazy = true,
        init = function()
          vim.g.aurora_italic = 1
          vim.g.aurora_transparent = 1
          vim.g.aurora_bold = 1
        end,
      },
      {
        'ray-x/go.nvim',
        dev = dev,
        -- dev = true,
        ft = { 'go', 'gomod' },
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
                ['textDocument/hover'] = vim.lsp.with(
                  vim.lsp.handlers.hover,
                  { border = 'double' }
                ),
                ['textDocument/signatureHelp'] = vim.lsp.with(
                  vim.lsp.handlers.signature_help,
                  { border = 'round' }
                ),
              },
            }, -- false: do nothing
          })
        end,
      },
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
