return function(lang)
  local conf = require('modules.lang.config')
  local dev = plugin_folder():find('github') ~= nil or plugin_folder():find('ray') ~= nil
  local ts = require('modules.lang.treesitter')

  lang({ 'nvim-treesitter/nvim-treesitter', config = ts.treesitter, module = true })

  lang({
    'nvim-treesitter/nvim-treesitter-textobjects',
    config = ts.treesitter_obj,
    module = true,
    lazy = true,
    event = { 'CursorMoved' },
  })

  lang({
    'RRethy/nvim-treesitter-textsubjects',
    lazy = true,
    config = ts.textsubjects,
    module = true,
    event = { 'CursorMoved' },
  })
  local jsft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' }
  if vim.tbl_contains(jsft, vim.bo.filetype) or vim.fn.argc() == 0 then
    lang({
      'jose-elias-alvarez/typescript.nvim',
      lazy = true,
      event = 'VeryLazy',
      config = function()
        require('typescript').setup({})
      end,
    })
  end
  lang({
    'bennypowers/nvim-regexplainer',
    lazy = true,
    cmd = { 'RegexplainerToggle', 'RegexplainerShow' },
    config = conf.regexplainer,
  })
  if vim.tbl_contains({ 'org', 'norg' }, vim.bo.filetype) then
    lang({
      'danymat/neogen',
      lazy = true,
      config = function()
        require('neogen').setup({ snippet_engine = 'luasnip' })
      end,
      ft = { 'norg' },
    })
  end

  lang({
    'haringsrob/nvim_context_vt',
    lazy = true,
    event = { 'CursorMoved' },
    config = conf.context_vt,
  })
  -- lang({ 'ThePrimeagen/refactoring.nvim', config = conf.refactor })

  lang({
    'nvim-treesitter/nvim-treesitter-refactor',
    config = ts.treesitter_ref, -- let the last loaded config treesitter
    lazy = true,
    event = { 'CursorMoved' },
  })

  -- Automatically convert strings to f-strings or template strings and back
  -- lang({
  --   'chrisgrieser/nvim-puppeteer',
  --   lazy = true,
  -- })
  -- ipython

  if vim.tbl_contains({ 'python', 'javascript' }, vim.bo.filetype) or vim.fn.argc() == 0 then
    lang({
      'dccsillag/magma-nvim',
      ft = 'python',
      build = 'UpdateRemotePlugins',
      lazy = false,
      cmd = {
        'MagmaRun',
        'MagmaRunCell',
        'MagmaRunCellAndMove',
        'MagmaRunCellAndStay',
        'MagmaRunCellAndInsert',
        'MagmaRunCel',
        'MagmaInit',
      },
      keys = {
        {
          '<leader>mi',
          '<cmd>MagmaInit python3<CR>',
          desc = 'This command initializes a runtime for the current buffer.',
        },
        {
          '<leader>mo',
          '<cmd>MagmaEvaluateOperator<CR>',
          desc = 'Evaluate the text given by some operator.',
        },
        { '<leader>ml', '<cmd>MagmaEvaluateLine<CR>', desc = 'Evaluate the current line.' },
        { '<leader>mv', '<cmd>MagmaEvaluateVisual<CR>', desc = 'Evaluate the selected text.' },
        {
          '<leader>mc',
          '<cmd>MagmaEvaluateOperator<CR>',
          desc = 'Reevaluate the currently selected cell.',
        },
        {
          '<leader>mr',
          '<cmd>MagmaRestart!<CR>',
          desc = 'Shuts down and restarts the current kernel.',
        },
        {
          '<leader>mx',
          '<cmd>MagmaInterrupt<CR>',
          desc = 'Interrupts the currently running cell and does nothing if not cell is running.',
        },
      },
    })
    lang({ 'metakirby5/codi.vim', ft = { 'python', 'javascript' }, cmd = { 'Codi', 'CodiNew' } })
    lang({ 'Vigemus/iron.nvim', ft = 'python', config = conf.iron })
    lang({ 'yardnsm/vim-import-cost', ft = { 'javascript' }, cmd = 'ImportCost' })
    lang({
      'mfussenegger/nvim-dap-python',
      config = require('modules.lang.dap.py').config,
      event = { 'CmdlineEnter' },
    })
  end

  -- lang['scalameta/nvim-metals'] = {dependencies = {"nvim-lua/plenary.nvim"}}
  -- lang { "lifepillar/pgsql.vim",ft = {"sql", "pgsql"}}

  lang({ 'nanotee/sqls.nvim', ft = { 'sql', 'pgsql' }, opts = {} })

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
    dev = dev,
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
    ft = { 'go', 'gomod' },
    config = conf.go,
  })

  lang({
    'ray-x/guihua.lua',
    build = 'cd lua/fzy && make',
    dev = dev,
    module = true,
    config = function()
      vim.ui.select = require('guihua.gui').select
      vim.ui.input = require('guihua.gui').input
    end,
  })

  lang({
    'ray-x/navigator.lua',
    dev = dev,
    config = conf.navigator,
    module = true,
    event = { 'VeryLazy' },
  })

  lang({
    'ray-x/web-tools.nvim',
    dev = dev,
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
    opts = {},
  })
  -- lang({
  --   'rafcamlet/nvim-luapad',
  --   lazy = true,
  --   cmd = { 'Lua', 'Luapad' },
  --   config = conf.luapad,
  -- })
  lang({ 'mfussenegger/nvim-dap', config = conf.dap })

  lang({ 'JoosepAlviste/nvim-ts-context-commentstring', event = 'VeryLazy' })

  lang({
    'rcarriga/nvim-dap-ui',
    -- dependencies = {"mfussenegger/nvim-dap"},
    config = conf.dapui,
    lazy = true,
    module = true,
  })

  lang({ 'theHamsta/nvim-dap-virtual-text', module = true })

  lang({
    'nvim-telescope/telescope-dap.nvim',
    config = conf.dap,
    -- cmd = "Telescope",
    event = { 'CmdlineEnter' },
  })

  lang({ 'mtdl9/vim-log-highlighting', ft = { 'text', 'txt', 'log' } })

  lang({
    'michaelb/sniprun',
    build = 'bash install.sh',
    cmd = { 'SnipRun', 'SnipReset' },
    config = function()
      require('sniprun').setup({
        -- selected_interpreters = {},     --" use those instead of the default for the current filetype
        -- repl_enable = {},               --" enable REPL-like behavior for the given interpreters
        -- repl_disable = {},              --" disable REPL-like behavior for the given interpreters
        inline_messages = 1, --" inline_message (0/1) is a one-line way to display messages
        --" to workaround sniprun not being able to display anything
      })
      if require('core.global').is_windows then
        if vim.fn.executable('bash') == 0 then
          vim.notify('failed to install sniprun, bash is not installed')
        end
      end
    end,
  })
  -- JqxList and JqxQuery json browsing, format
  lang({ 'gennaro-tedesco/nvim-jqx', cmd = { 'JqxList', 'JqxQuery' } })
  lang({
    'bfrg/vim-jqplay',
    ft = 'jq',
    cmd = { 'Jqplay', 'JqplayScratch', 'JqplayScratchNoInput' },
  })

  lang({
    'windwp/nvim-ts-autotag',
    lazy = true,
    config = function()
      require('nvim-treesitter.configs').setup({ autotag = { enable = true } })
    end,
    event = 'VeryLazy',
  })
  -- highlight your args with Treesitter
  lang({
    'm-demare/hlargs.nvim',
    lazy = true,
    event = { 'CursorMoved', 'CursorMovedI' },
    config = function()
      require('hlargs').setup({
        disable = function()
          excluded_filetype = {
            'TelescopePrompt',
            'guihua',
            'guihua_rust',
            'clap_input',
            'lua',
            'rust',
            'typescript',
            'typescriptreact',
            'javascript',
            'javascriptreact',
          }
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
  if vim.tbl_contains({ 'lua' }, vim.bo.filetype) or vim.fn.argc() == 0 then
    lang({
      'folke/neodev.nvim',
      ft = { 'lua' },
      event = 'VeryLazy',
      module = true,
      opts = {},
    })
  end

  lang({
    'nvim-treesitter/nvim-treesitter-context',
    lazy = true,
    event = { 'CursorHold', 'WinScrolled' },
    module = false,
    config = function()
      require('treesitter-context').setup({
        enable = false, -- Enable this plugin (Can be enabled/disabled later via commands)
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

  --   'HiPhish/nvim-ts-rainbow2',
  lang({
    'hiphish/rainbow-delimiters.nvim',
    event = 'VeryLazy',
    config = function()
      local rainbow_delimiters = require('rainbow-delimiters')
      require('rainbow-delimiters.setup').setup({
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
        },
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        },
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
    'nvimtools/none-ls.nvim',
    lazy = true,
    config = require('modules.lang.null-ls').config,
    event = 'VeryLazy',
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
