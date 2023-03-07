local conf = require('modules.lang.config')
local ts = require('modules.lang.treesitter')
return function(lang)
  lang({ 'nvim-treesitter/nvim-treesitter', lazy = true, config = ts.treesitter, module = false })

  lang({
    'nvim-treesitter/nvim-treesitter-textobjects',
    config = ts.treesitter_obj,
    module = false,
    lazy = true,
  })

  lang({
    'RRethy/nvim-treesitter-textsubjects',
    lazy = true,
    config = ts.textsubjects,
    module = false,
  })
  lang({ 'mfussenegger/nvim-treehopper', lazy = true, config = ts.tshopper, module = false })

  -- lang['ziontee113/syntax-tree-surfer'] = {
  --   lazy = true,
  --   config = conf.surfer,
  -- }

  lang({
    'bennypowers/nvim-regexplainer',
    lazy = true,
    cmd = { 'RegexplainerToggle', 'RegexplainerShow' },
    config = conf.regexplainer,
  })

  lang({
    'danymat/neogen',
    lazy = true,
    config = function()
      require('neogen').setup({ snippet_engine = 'luasnip' })
    end,
  })

  lang({ 'ThePrimeagen/refactoring.nvim', lazy = true, config = conf.refactor })

  lang({
    'nvim-treesitter/nvim-treesitter-refactor',
    config = ts.treesitter_ref, -- let the last loaded config treesitter
    lazy = true,
  })

  lang({ 'yardnsm/vim-import-cost', cmd = 'ImportCost', lazy = true })

  -- lang['scalameta/nvim-metals'] = {dependencies = {"nvim-lua/plenary.nvim"}}
  -- lang { "lifepillar/pgsql.vim",ft = {"sql", "pgsql"}}

  lang({ 'nanotee/sqls.nvim', ft = { 'sql', 'pgsql' }, init = conf.sqls, lazy = true })

  lang({
    'simrat39/rust-tools.nvim',
    ft = { 'rust' },
    config = function()
      vim.defer_fn(function()
        require('rust-tools').setup({
          server = {
            on_attach = function(c, b)
              require('navigator.lspclient.mapping').setup({ client = c, bufnr = b })
            end,
          },
        })
      end, 200)
    end,
  })

  lang({
    'ray-x/go.nvim',
    dev = (plugin_folder():find('github') ~= nil),
    lazy = true,
    cmd = {
      'Go',
      'GoFmt',
      'GoBuild',
      'GoAlt',
      'GoBreakToggle',
      'GoImpl',
      'GoRun',
      'GoInstall',
      'GoTest',
      'GoTestFunc',
      'GoTestCompile',
      'GoCoverage',
      'GoCoverageToggle',
      'GoCoverag',
      'GoGet',
      'GoModifyTags',
    },
    -- event = { 'CmdwinEnter', 'CmdlineEnter' },
    config = conf.go,
  })

  lang({
    'ray-x/guihua.lua',
    build = 'cd lua/fzy && make',
    dev = (plugin_folder():find('github') ~= nil),
  })
  lang({
    'ray-x/navigator.lua',
    dev = (plugin_folder():find('github') ~= nil),
    config = conf.navigator,
    lazy = true,
  })

  lang({
    'ray-x/web-tools.nvim',
    dev = (plugin_folder():find('github') ~= nil),
    ft = { 'html', 'javascript', 'hurl', 'http' },
    cmd = { 'HurlRun', 'BrowserOpen' },
    lazy = true,
    config = function()
      require('web-tools').setup({ debug = true })
    end,
  })

  lang({
    'glepnir/lspsaga.nvim',
    lazy = true,
    cmd = {
      'Lspsaga',
    },
    config = function()
      local saga = require('lspsaga')

      saga.setup({
        border_style = 'rounded',
        code_action_lightbulb = {
          enable = false,
        },
      })
    end,
  })

  lang({
    'nvim-treesitter/playground',
    lazy = true,
    cmd = 'TSPlaygroundToggle',
    config = conf.playground,
  })

  lang({
    'simrat39/symbols-outline.nvim',
    lazy = true,
    cmd = { 'SymbolsOutline', 'SymbolsOutlineOpen' },
    config = conf.outline,
  })

  lang({
    'rafcamlet/nvim-luapad',
    lazy = true,
    cmd = { 'Lua', 'Luapad' },
    config = conf.luapad,
  })
  lang({ 'mfussenegger/nvim-dap', config = conf.dap, lazy = true })

  lang({ 'JoosepAlviste/nvim-ts-context-commentstring', lazy = true })

  lang({
    'rcarriga/nvim-dap-ui',
    -- dependencies = {"mfussenegger/nvim-dap"},
    config = conf.dapui,
    lazy = true,
  })

  lang({ 'theHamsta/nvim-dap-virtual-text', lazy = true })

  lang({
    'nvim-telescope/telescope-dap.nvim',
    config = conf.dap,
    -- cmd = "Telescope",
    lazy = true,
  })

  lang({
    'mfussenegger/nvim-dap-python',
    ft = { 'python' },
    config = require('modules.lang.dap.py').config,
  })

  lang({ 'mtdl9/vim-log-highlighting', ft = { 'text', 'txt', 'log' } })
  local cmd = 'bash install.sh'
  if require('core.global').is_windows then
    if vim.fn.executable('bash') == 0 then
      cmd = [[echo 'failed to install sniprun, bash is not installed']]
    end
  end
  lang({
    'michaelb/sniprun',
    build = cmd,
    lazy = true,
    cmd = { 'SnipRun', 'SnipReset' },
    config = function()
      require('sniprun').setup({
        -- selected_interpreters = {},     --" use those instead of the default for the current filetype
        -- repl_enable = {},               --" enable REPL-like behavior for the given interpreters
        -- repl_disable = {},              --" disable REPL-like behavior for the given interpreters
        inline_messages = 1, --" inline_message (0/1) is a one-line way to display messages
        --" to workaround sniprun not being able to display anything
      })
    end,
  })
  -- JqxList and JqxQuery json browsing, format
  lang({ 'gennaro-tedesco/nvim-jqx', lazy = true, cmd = { 'JqxList', 'JqxQuery' } })
  lang({
    'bfrg/vim-jqplay',
    ft = 'jq',
    cmd = { 'Jqplay', 'JqplayScratch', 'JqplayScratchNoInput' },
  })

  lang({
    'windwp/nvim-ts-autotag',
    lazy = true,
    -- config = function() require"nvim-treesitter.configs".setup {autotag = {enable = true}} end
  })
  -- highlight your args with Treesitter
  lang({
    'm-demare/hlargs.nvim',
    lazy = true,
    config = function()
      require('hlargs').setup({
        disable = function()
          excluded_filetype = { 'TelescopePrompt', 'guihua', 'guihua_rust', 'clap_input' }
          if vim.tbl_contains(excluded_filetype, vim.bo.filetype) then
            return true
          end

          local bufnr = vim.api.nvim_get_current_buf()
          local filetype = vim.fn.getbufvar(bufnr, '&filetype')
          if filetype == '' then
            return true
          end
          local parsers = require('nvim-treesitter.parsers')
          local buflang = parsers.ft_to_lang(filetype)
          -- lprint(buflang, filetype,  vim.tbl_contains(excluded_filetype, buflang))
          return vim.tbl_contains(excluded_filetype, buflang)
        end,
      })
    end,
  })

  lang({
    'folke/neodev.nvim',
    lazy = true,
    -- ft = {'lua'},
    config = conf.neodev,
  })

  lang({
    'nvim-treesitter/nvim-treesitter-context',
    lazy = true,
    -- event = { 'CursorHold', 'WinScrolled' },
    module = false,
    config = function()
      require('treesitter-context').setup({
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 2, -- How many lines the window should span. Values <= 0 mean no limit.
        trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'topline', -- Line used to calculate context. Choices: 'cursor', 'topline'
        patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          -- For all filetypes
          default = {
            'class',
            'function',
            'method',
            'for', -- These won't appear in the context
            'while',
            'if',
            'switch',
            -- 'case',
          },
        },
      })
    end,
  })

  lang({
    -- 'p00f/nvim-ts-rainbow',
    'HiPhish/nvim-ts-rainbow2',
    lazy = true,
    -- slow... disable it for now
    -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    -- cmd = "Rainbow",
    module = false,
    config = function()
      local fsize = vim.fn.getfsize(vim.fn.expand('%:p:f'))

      local enable = true
      if vim.fn.line('$') > 3000 or fsize > 100000 then
        lprint(' rainbow disabled', fsize)
        enable = false
        return
      end

      require('nvim-treesitter.configs').setup({
        rainbow = { enable = enable, extended_mode = enable },
      })
    end,
  })

  lang({
    'folke/trouble.nvim',
    cmd = { 'Trouble', 'TroubleToggle' },
    config = function()
      require('trouble').setup({})
    end,
  })

  lang({
    'hashivim/vim-terraform',
    ft = { 'terraform' },
    lazy = true,
    cmd = { 'Terraform', 'TerraformToggle' },
    -- config = conf.terraform,
  })

  lang({
    'jose-elias-alvarez/null-ls.nvim',
    lazy = true,
    config = require('modules.lang.null-ls').config,
  })

  lang({
    'j-hui/fidget.nvim',
    lazy = true,
    config = function()
      require('fidget').setup({
        sources = {
          ['null-ls'] = { ignore = true },
        },
      })
    end,
  })

  -- structural search and replace
  -- put to lang as it depends on treesitter
  lang({ 'cshuaimin/ssr.nvim', config = conf.ssr })

  lang({
    'p00f/clangd_extensions.nvim',
    lazy = true,
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'h', 'hpp' },
    config = conf.clangd,
  })

  lang({
    'HiPhish/awk-ward.nvim',
    ft = 'awk',
    lazy = true,
    -- cmd = { 'AwkWard' },
  })
  lang({
    'mechatroner/rainbow_csv',
    ft = { 'csv', 'tsv', 'dat' },
    lazy = true,
    cmd = { 'RainbowDelim', 'RainbowMultiDelim', 'Select', 'CSVLint' },
  })
end
