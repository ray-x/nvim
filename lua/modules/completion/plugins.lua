-- stylua: ignore start
local filetypes = { 'html', 'css', 'javascript', 'java', 'javascriptreact', 'vue', 'typescript', 'typescriptreact', 'go', 'lua', 'cpp', 'c', 'markdown', 'makefile', 'python', 'bash', 'sh', 'php', 'yaml', 'json', 'sql', 'vim', 'sh',
}
-- stylua: ignore end

return function(use)
  local dev = _G.is_dev()
  use({
    'neovim/nvim-lspconfig',
    config = function()
      local conf = require('modules.completion.config')
      conf.nvim_lsp()
    end,
    lazy = true,
  })

  if vim.wo.diff then
    return
  end
  -- loading sequence LuaSnip -> nvim-cmp -> cmp_luasnip -> cmp-nvim-lua -> cmp-nvim-lsp ->cmp-buffer -> friendly-snippets
  use({
    'hrsh7th/nvim-cmp',
    module = true,
    -- lazy = true,
    event = { 'InsertEnter', 'CmdlineEnter' }, -- InsertCharPre
    -- ft = {'lua', 'markdown',  'yaml', 'json', 'sql', 'vim', 'sh', 'sql', 'vim', 'sh'},
    -- stylua: ignore start
    dependencies = {
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'hrsh7th/cmp-path' },
      { 'f3fora/cmp-spell' },
      { 'hrsh7th/cmp-cmdline' },
      { 'dmitmel/cmp-cmdline-history' },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol', event = 'CmdLineEnter'},
      -- { 'hrsh7th/cmp-copilot' },
      { 'ray-x/cmp-treesitter', dev = _G.is_dev() },
      { 'ray-x/cmp-sql', dev = _G.is_dev(), ft = {'sql', 'psql'} },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'kdheepak/cmp-latex-symbols', ft = {'markdown'} },
      { 'hrsh7th/cmp-emoji' },
      { 'windwp/nvim-autopairs', event = 'InsertEnter', module = true, config = function()  require('modules.completion.config').autopairs() end },
    },
    -- stylua: ignore end
    config = function()
      local conf = require('modules.completion.config')
      conf.nvim_cmp()
    end,
  })

  -- can not lazyload, it is also slow...
  use({
    'L3MON4D3/LuaSnip', -- need to be the first to load
    event = 'InsertEnter',
    dependencies = { 'rafamadriz/friendly-snippets', module = false, event = 'InsertEnter' }, -- , event = "InsertEnter"
    module = true,
    config = function()
      require('modules.completion.luasnip')
    end,
  })
  use({
    'kristijanhusak/vim-dadbod-completion',
    -- event = 'InsertEnter',
    ft = { 'sql' },
    init = function()
      -- vim.cmd([[autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni]])
      -- vim.cmd(
      --   [[autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }, {name = 'buffer'}, {name = 'treesitter'}} })]]
      -- )
    end,
  })

  use({
    'mattn/emmet-vim',
    event = 'InsertEnter',
    -- stylua: ignore start
    ft = { 'html', 'css', 'javascript', 'javascriptreact', 'vue', 'typescript', 'typescriptreact',
      'scss', 'sass', 'less', 'jade', 'haml', 'elm', },
    -- stylua: ignore end
    init = function()
      local conf = require('modules.completion.config')
      conf.emmet()
    end,
  })
  -- note: part of the code is used in navigator
  use({
    'ray-x/lsp_signature.nvim',
    dev = dev,
    event = { 'InsertEnter' },
    opts = {
      debug = plugin_debug(), -- log output
      verbose = plugin_debug(), -- log verbose
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
      -- hint_prefix = {
      --   inlay = '',
      --   above = '↙ ', -- when the hint is on the line above the current line
      --   current = '← ', -- when the hint is on the same line
      --   below = '↖ ', -- when the hint is on the line below the current line
      -- },
      -- hint_inline = function()
      --   if vim.fn.has('nvim-0.10') == 1 then
      --     return 'inline'
      --   else
      --     return false
      --   end
      -- end,
      max_height = 4,
      toggle_key = [[<M-x>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
      -- select_signature_key = [[<M-n>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
      select_signature_key = [[<M-c>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
      move_cursor_key = [[<M-n>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
    },
  })

  vim.g.copilot_filetypes = {
    ['dap-repl'] = false,
    -- gitcommit = false,
  }
  use({
    'github/copilot.vim',
    lazy = true,
    event = 'InsertEnter',
    init = function()
      -- vim.api.nvim_set_keymap("n", "<C-=>", [[copilot#Accept("\<CR>")]], { silent = true, script = true, expr = true })
      -- vim.api.nvim_set_keymap("i", "<C-=>", [[copilot#Accept("\<CR>")]], { silent = true, script = true, expr = true })
      vim.g.copilot_filetypes = {
        ['dap-repl'] = false,
        -- NeogitCommitMessage = false,
        -- gitcommit = false,
      }
      vim.cmd([[imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")]])
      -- vim.keymap.set('i', '<C-J>', function()
      --   vim.fn['copilot#Accept']('<CR>')
      -- end, { desc = 'copilot accept', replace_keycodes = false })
      -- vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
      --     expr = true,
      --     replace_keycodes = false
      --   })
      vim.g.copilot_no_tab_map = true
    end,
  })
  -- use({
  --   'hinell/lsp-timeout.nvim', -- reset lsp from time to time
  --   dependencies = { 'neovim/nvim-lspconfig' },
  --   event = 'InsertEnter',
  -- })
end

