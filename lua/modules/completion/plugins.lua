local conf = require('modules.completion.config')
local filetypes = {
  'html',
  'css',
  'javascript',
  'java',
  'javascriptreact',
  'vue',
  'typescript',
  'typescriptreact',
  'go',
  'lua',
  'cpp',
  'c',
  'markdown',
  'makefile',
  'python',
  'bash',
  'sh',
  'php',
  'yaml',
  'json',
  'sql',
  'vim',
  'sh',
}
return function(use)
  use({ 'neovim/nvim-lspconfig', config = conf.nvim_lsp, lazy = true })
  -- loading sequence LuaSnip -> nvim-cmp -> cmp_luasnip -> cmp-nvim-lua -> cmp-nvim-lsp ->cmp-buffer -> friendly-snippets
  use({
    'hrsh7th/nvim-cmp',
    module = false,
    -- lazy = true,
    event = "InsertEnter", -- InsertCharPre
    -- ft = {'lua', 'markdown',  'yaml', 'json', 'sql', 'vim', 'sh', 'sql', 'vim', 'sh'},
    after = { 'LuaSnip' },
    dependencies = {
      { 'hrsh7th/cmp-buffer', after = 'nvim-cmp', lazy = true },
      { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp', lazy = true },
      { 'hrsh7th/cmp-calc', after = 'nvim-cmp', lazy = true },
      { 'hrsh7th/cmp-path', after = 'nvim-cmp', lazy = true },
      { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp', lazy = true },
      -- { "tzachar/cmp-tabnine", after = "nvim-cmp", build = "./install.sh", lazy = true, config = conf.tabnine},
      { 'hrsh7th/cmp-copilot', after = 'nvim-cmp', lazy = true },
      { 'hrsh7th/cmp-emoji', after = 'nvim-cmp', lazy = true },
      { 'ray-x/cmp-treesitter', dev = true, after = 'nvim-cmp', lazy = true },
      { 'hrsh7th/cmp-nvim-lsp', after = 'nvim-cmp', lazy = true },
      { 'f3fora/cmp-spell', after = 'nvim-cmp', lazy = true },
      { 'octaltree/cmp-look', after = 'nvim-cmp', lazy = true },
      -- {"quangnguyen30192/cmp-nvim-ultisnips", event = "InsertCharPre", after = "nvim-cmp", opt=true },
      { 'saadparwaiz1/cmp_luasnip', after = { 'nvim-cmp', 'LuaSnip' } },
      -- {"tzachar/cmp-tabnine", lazy = true}
    },
    config = conf.nvim_cmp,
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
    event = 'InsertEnter',
    ft = { 'sql' },
    init = function()
      vim.cmd([[autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni]])
      -- vim.cmd([[autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-use' }} })]])
      -- body
    end,
  })

  use({
    'nvim-telescope/telescope.nvim',
    cmd = "Telescope",
    config = conf.telescope,
    init = conf.telescope_preload,
    dependencies = {
      { 'nvim-lua/plenary.nvim', lazy = true },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', lazy = true },
      { 'nvim-telescope/telescope-live-grep-args.nvim', lazy = true },
      { 'nvim-telescope/telescope-file-browser.nvim', lazy = true },
    },
    lazy = true,
  })

  use({
    'mattn/emmet-vim',
    event = 'InsertEnter',
    ft = {
      'html',
      'css',
      'javascript',
      'javascriptreact',
      'vue',
      'typescript',
      'typescriptreact',
      'scss',
      'sass',
      'less',
      'jade',
      'haml',
      'elm',
    },
    init = conf.emmet,
  })

  -- note: part of the code is used in navigator
  use({
    'ray-x/lsp_signature.nvim',
    dev = true,
    lazy = true,
    config = function()
      require('lsp_signature').setup({
        bind = true,
        -- doc_lines = 4,
        floating_window = true,
        floating_window_above_cur_line = true,
        hint_enable = true,
        fix_pos = false,
        -- floating_window_above_first = true,
        log_path = vim.fn.expand('$HOME') .. '/tmp/sig.log',
        debug = plugin_debug(),
        verbose = plugin_debug(),
        -- hi_parameter = "Search",
        zindex = 1002,
        timer_interval = 100,
        extra_trigger_chars = {},
        handler_opts = {
          border = 'rounded', -- "shadow", --{"╭", "─" ,"╮", "│", "╯", "─", "╰", "│" },
        },
        max_height = 4,
        toggle_key = [[<M-x>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
        -- select_signature_key = [[<M-n>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
        select_signature_key = [[<M-c>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
      })
    end,
  })

  use({
    'github/copilot.vim',
    lazy = true,
    event = 'InsertEnter',
    init = function()
      -- vim.api.nvim_set_keymap("n", "<C-=>", [[copilot#Accept("\<CR>")]], { silent = true, script = true, expr = true })
      -- vim.api.nvim_set_keymap("i", "<C-=>", [[copilot#Accept("\<CR>")]], { silent = true, script = true, expr = true })

      vim.g.copilot_filetypes = {
        ['*'] = true,
        gitcommit = false,
        NeogitCommitMessage = false,
      }
      vim.cmd([[
      imap <silent><script><expr> <C-j> copilot#Accept()
      let g:copilot_no_tab_map = v:true
      let g:copilot_assume_mapped = v:true
      let g:copilot_tab_fallback = ""
    ]])
    end,
  })
  use({
    'Exafunction/codeium.vim',
    lazy = true,
    -- event = 'InsertEnter',
  })
end
