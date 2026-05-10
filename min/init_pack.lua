vim.cmd([[set runtimepath=$VIMRUNTIME]])

-- Keep mini profile self-contained when used via: nvim -u min/init_pack.lua
local this_file = debug.getinfo(1, 'S').source:sub(2)
local config_root = vim.fn.fnamemodify(this_file, ':p:h:h')
vim.opt.runtimepath:prepend(config_root)

local function plugin_folder()
  local host = os.getenv('HOST_NAME')
  if host and (host:find('Ray') or host:find('ray')) then
    return vim.fn.expand('~/github/ray-x')
  end
  return ''
end

local dev = plugin_folder() ~= ''

local function load_plugins()
  return {
    {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      build = ':TSUpdate',
      config = function()
        require('nvim-treesitter.configs').setup({
          ensure_installed = { 'go', 'gomod', 'lua' },
          highlight = { enable = true },
        })
      end,
    },
    {
      'neovim/nvim-lspconfig',
      lazy = false,
    },
    {
      'ray-x/guihua.lua',
      dev = dev,
      lazy = true,
    },
    {
      'ray-x/navigator.lua',
      dev = dev,
      event = 'VeryLazy',
      dependencies = {
        'ray-x/guihua.lua',
        'neovim/nvim-lspconfig',
      },
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
      event = 'InsertEnter',
      opts = {
        bind = true,
        floating_window = true,
        hint_enable = true,
        fix_pos = false,
        log_path = vim.fn.expand('$HOME') .. '/tmp/sig.log',
        zindex = 1002,
        timer_interval = 100,
        extra_trigger_chars = {},
        handler_opts = { border = 'rounded' },
        max_height = 4,
        toggle_key = '<M-x>',
        select_signature_key = '<M-c>',
        move_cursor_key = '<M-n>',
        move_signature_window_key = { '<M-Up>', '<M-Down>' },
      },
    },
    {
      'ray-x/aurora',
      dev = dev,
      lazy = false,
      init = function()
        vim.g.aurora_italic = 1
        vim.g.aurora_transparent = 1
        vim.g.aurora_bold = 1
      end,
    },
    {
      'ray-x/go.nvim',
      dev = dev,
      ft = { 'go', 'gomod' },
      dependencies = {
        'mfussenegger/nvim-dap',
        'rcarriga/nvim-dap-ui',
        'theHamsta/nvim-dap-virtual-text',
      },
      opts = {},
    },
  }
end

local pack_loader = require('core.pack_loader'):new()
pack_loader:create_directories()

for _, spec in ipairs(load_plugins()) do
  pack_loader:register_plugin(spec)
end

require('core.pack_installer').install_all_plugins(pack_loader.pack_dir, dev)
pack_loader:init()

vim.schedule(function()
  pcall(vim.cmd.colorscheme, 'aurora')
end)
