local function typecheck(types)
  if vim.tbl_contains(types, vim.bo.filetype) or vim.fn.argc() == 0 then
    return true
  end
  -- vim.fn.argv[1]:find('lua')
  for _, v in ipairs(types) do
    if vim.fn.argv()[1]:find(v) then
      return true
    end
  end
end

return function(lang)
  local conf = require('modules.lang.config')
  local dev = plugin_folder():find('github') ~= nil or plugin_folder():find('ray') ~= nil
  local ts = require('modules.lang.treesitter')

  lang({ 'nvim-treesitter/nvim-treesitter', config = ts.treesitter, module = true })
  --
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
  if vim.wo.diff then return end
  lang({
    'nvim-treesitter/nvim-treesitter-textobjects',
    config = ts.treesitter_obj,
    -- module = true,
    event = { 'CursorHold' },
  })

  -- -- use flash.nvim
  -- -- lang({
  -- --   'RRethy/nvim-treesitter-textsubjects',
  -- --   config = ts.textsubjects,
  -- --   -- module = true,
  -- --   event = { 'CursorHold' },
  -- -- })

  lang({
    'andersevenrud/nvim_context_vt',
    cmd = { 'NvimContextVtToggle', 'NvimContextVtEnable' },
    config = conf.context_vt,
  })

  lang({
    'nvim-treesitter/nvim-treesitter-refactor',
    config = ts.treesitter_ref, -- let the last loaded config treesitter
    event = { 'CursorHold' },
  })

  local jsft =
    { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'js', 'jsx', 'ts', 'tsx' }
  if typecheck(jsft) then
    lang({
      'jose-elias-alvarez/typescript.nvim',
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
  if typecheck({ 'md', 'org', 'norg' }) then
    lang({
      'danymat/neogen',
      lazy = true,
      config = function()
        require('neogen').setup({ snippet_engine = 'luasnip' })
      end,
      ft = { 'norg' },
    })
  end

  -- -- lang({ 'ThePrimeagen/refactoring.nvim', config = conf.refactor })

  -- -- Automatically convert strings to f-strings or template strings and back
  -- -- lang({
  -- --   'chrisgrieser/nvim-puppeteer',
  -- --   lazy = true,
  -- -- })
  -- -- ipython

  if typecheck({ 'python', 'javascript', 'py', 'ts', 'tsx', 'js', 'jsx' }) then
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
      'GoModInit',
      'GoModTidy',
      'GoNew',
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
  -- if vim.fn.has('nvim-0.11') == 1 then
  --   lang({
  --     'Bekaboo/dropbar.nvim',
  --     -- optional, but required for fuzzy finder support
  --     dependencies = {
  --       'nvim-telescope/telescope-fzf-native.nvim',
  --     },
  --     event = { 'WinScrolled' },
  --     opts = {
  --       ---@type boolean|fun(buf: integer, win: integer, info: table?): boolean
  --       enable = function(buf, win, _)
  --         return not vim.api.nvim_win_get_config(win).zindex
  --           and not vim.bo[buf].buftype == ''
  --           and (not vim.tbl_contains(
  --             { 'help', 'guihua', 'terminal', 'markdown' },
  --             vim.bo[buf].buftype
  --           ))
  --           and vim.api.nvim_buf_get_name(buf) ~= ''
  --           and not vim.wo[win].diff
  --       end,
  --       attach_events = {
  --         'OptionSet',
  --         'BufWinEnter',
  --         'BufWritePost',
  --         'WinScrolled',
  --       },
  --     },
  --   })
  -- end
  lang({
    'glepnir/lspsaga.nvim',
    lazy = true,
    cmd = {
      'Lspsaga',
    },
    opts = {
        border_style = 'rounded',
        code_action_lightbulb = {
          enable = false,
        },
  }})

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

  lang({ 'JoosepAlviste/nvim-ts-context-commentstring', event = 'CursorHold' })

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
    config = function()
      require('nvim-ts-autotag').setup({
        filetypes = { 'html', 'javascript' },
      })
    end,
    -- event = 'VeryLazy',
    ft = { 'javascript', 'html' },
  })
  -- highlight your args with Treesitter
  lang({
    'm-demare/hlargs.nvim',
    lazy = true,
    event = { 'CursorMoved', 'CursorMovedI' },
    opts = {
      disable = function()
        local excluded_filetype = {
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
    },
  })
  if typecheck({ 'lua' }) then
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
    dependencies = { 'nvim-treesitter' },
    event = { 'WinScrolled', 'CmdlineEnter' },
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
            'case',
          },
        },
      })

      vim.keymap.set('n', '[C', function()
        require('treesitter-context').go_to_context()
      end, { silent = true })
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
    cmd = { 'Terraform', 'TerraformToggle' },
    -- config = conf.terraform,
  })

  lang({
    'nvimtools/none-ls.nvim',
    config = require('modules.lang.null-ls').config,
    event = { 'BufWritePre', 'TextChanged', 'TextChangedI', 'CmdlineEnter' },
  })

  -- structural search and replace
  -- put to lang as it depends on treesitter
  lang({ 'cshuaimin/ssr.nvim', config = conf.ssr })

  lang({
    'p00f/clangd_extensions.nvim',
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'h', 'hpp' },
    config = conf.clangd,
  })

  lang({
    'HiPhish/awk-ward.nvim',
    ft = 'awk',
    -- cmd = { 'AwkWard' },
  })
  lang({
    'mechatroner/rainbow_csv',
    ft = { 'csv', 'tsv', 'dat' },
    cmd = { 'RainbowDelim', 'RainbowMultiDelim', 'Select', 'CSVLint' },
  })
end
