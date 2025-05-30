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
  local dev = _G.is_dev()
  local ts = require('modules.lang.treesitter')

  -- lang({ 'nvim-treesitter/nvim-treesitter', config = ts.treesitter, module = true })

  --
  --
  lang({
    'ray-x/guihua.lua',
    build = 'cd lua/fzy && make',
    dev = dev,
    module = true,
    opts = function()
      vim.ui.select = require('guihua.gui').select
      vim.ui.input = require('guihua.gui').input
      return {
        icons = {
          syntax = {
            namespace = '',
          },
        },
      }
    end,
  })
  if vim.wo.diff then
    lang({
      'nvim-treesitter/nvim-treesitter',
      event = { 'BufReadPre' },
      config = function()
        require('nvim-treesitter.configs').setup({
          highlight = {
            enable = true,
          },
          indent = {
            enable = true,
          },
        })
      end,
      module = true,
    })
    return
  end
  lang({
    'nvim-treesitter/nvim-treesitter',
    event = { 'VeryLazy' },
    config = ts.treesitter,
    module = true,
  })

  lang({
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter' },
    config = ts.treesitter_obj,
    -- module = true,
    event = { 'CursorHold', 'CursorHoldI' },
  })


  lang({
    'chrisgrieser/nvim-various-textobjs',
    event = { 'CursorHold', 'CursorHoldI' },
    opts = {
      keymap = {
        useDefault = true,
      },
      forwardLooking = {
        big = 10,
        small = 5,
      },
    },
  })

  lang({
    'andersevenrud/nvim_context_vt',
    cmd = { 'NvimContextVtToggle' },
    config = conf.context_vt,
  })

  local jsft =
  { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'html', 'js', 'jsx', 'ts', 'tsx' }


  if typecheck(jsft) then
    lang({
      'pmizio/typescript-tools.nvim',
      event = 'VeryLazy',
      ft = jsft,
      opts = {},
    })

    lang({
      'JoosepAlviste/nvim-ts-context-commentstring',
      ft = jsft,
      event = 'CursorHold',
      config = function()
        require('ts_context_commentstring').setup({
          enable = true,
          enable_autocmd = false,
        })
      end
    })

    lang({ 'yardnsm/vim-import-cost', ft = jsft, cmd = 'ImportCost' })
  end
  lang({
    'bennypowers/nvim-regexplainer',
    cmd = { 'RegexplainerToggle', 'RegexplainerShow' },
    config = conf.regexplainer,
  })

  lang({
    'Wansmer/symbol-usage.nvim', -- count symbol usage
    event = { 'BufReadPre', 'LspAttach' },
    config = conf.symbol_usage,
  })

  if typecheck({ 'python', 'javascript', 'py', 'ts', 'tsx', 'js', 'jsx' }) then
    lang({
      -- running code interactively with the jupyter kernel
      'benlubas/molten-nvim',
      ft = 'python',
      cmd = {
        'MoltenLoad',
        'MoltenInit',
        'MoltenInfo',
        'MoltenEvaluateVisual',
        'MoltenEvaluateLine',
        'MoltenReevaluateCell',
      },
    })
    lang({ 'metakirby5/codi.vim', ft = { 'python', 'javascript' }, cmd = { 'Codi', 'CodiNew' } })
    lang({ 'Vigemus/iron.nvim', ft = 'python', config = conf.iron })
  end

  lang({
    'mfussenegger/nvim-dap-python',
    ft = { 'python' },
    config = require('modules.lang.dap.py').config,
  })

  lang({
    'ray-x/go.nvim',
    dev = dev,
    -- lazy = false,
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
    ft = { 'go', 'gomod', 'gosum', 'gotmpl', 'gohtmltmpl', 'gotexttmpl' },
    event = { 'VeryLazy' },
    -- opts = conf.go,
    opts = conf.go,
  })

  lang({
    'ray-x/navigator.lua',
    dev = dev,
    opts = conf.navigator,
    module = true,
    event = { 'VeryLazy' },
  })

  lang({
    'ray-x/web-tools.nvim',
    dev = dev,
    ft = { 'html', 'javascript', 'hurl', 'http', 'svelte' },
    cmd = { 'HurlRun', 'BrowserOpen', 'Npm', 'Yarn', 'Prettier', 'ESLint', 'Tsc', 'TscWatch' },
    lazy = true,
    opts = { debug = true },
  })

  lang({ 'mfussenegger/nvim-dap', config = conf.dap })

  lang({
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
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

  -- lang({
  --   'michaelb/sniprun',
  --   build = 'bash install.sh',
  --   cmd = { 'SnipRun', 'SnipReset' },
  --   config = function()
  --     require('sniprun').setup({
  --       -- selected_interpreters = {},     --" use those instead of the default for the current filetype
  --       -- repl_enable = {},               --" enable REPL-like behavior for the given interpreters
  --       -- repl_disable = {},              --" disable REPL-like behavior for the given interpreters
  --       inline_messages = 1, --" inline_message (0/1) is a one-line way to display messages
  --       --" to workaround sniprun not being able to display anything
  --     })
  --     if require('core.global').is_windows then
  --       if vim.fn.executable('bash') == 0 then
  --         vim.notify('failed to install sniprun, bash is not installed')
  --       end
  --     end
  --   end,
  -- })
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
  lang({
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  })

  -- lang({ 'Bilal2453/luvit-meta', lazy = true })

  lang({
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter' },
    -- event = { 'WinScrolled', 'CmdlineEnter' },
    event = 'VeryLazy',
    opts = function()
      return {
        enable = true,        -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 2,        -- How many lines the window should span. Values <= 0 mean no limit.
        min_win_height = 0,   -- Minimum height of the window, content will be truncated if necessary.
        trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'topline',     -- Line used to calculate context. Choices: 'cursor', 'topline'
        patterns = {          -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
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
      }
    end,
  })

  lang({
    'hiphish/rainbow-delimiters.nvim',
    event = 'VeryLazy',
    config = function()
      local rainbow_delimiters = require('rainbow-delimiters')
      require('rainbow-delimiters.setup').setup({
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          -- vim = rainbow_delimiters.strategy['local'],
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
        blacklist = {
          'markdown',
          'help',
        },
      })
      vim.api.nvim_create_user_command('RainbowToggle', function()
        local bufnr = vim.api.nvim_get_current_buf()
        require('rainbow-delimiters').toggle(bufnr)
      end, {
        bar = true,
        nargs = 0,
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
    dependencies = {
      'nvimtools/none-ls-extras.nvim',
    },
    opts = require('modules.lang.null-ls').config,
    event = { 'BufWritePre', 'TextChanged', 'TextChangedI', 'CmdlineEnter' },
  })

  -- structural search and replace
  -- put to lang as it depends on treesitter
  lang({ 'cshuaimin/ssr.nvim', config = conf.ssr })

  lang({
    'p00f/clangd_extensions.nvim',
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'h', 'hpp' },
    opts = conf.clangd,
  })

  lang({
    'HiPhish/awk-ward.nvim',
    ft = 'awk',
    -- cmd = { 'AwkWard' },
  })

  -- if vim.bo.ft == 'csv' then
  -- it can not be lazy loaded
  -- if 'csv' == vim.fn.expand('%:e') then
  lang({
    'chrisbra/csv.vim',
    lazy = not 'csv' == vim.fn.expand('%:e'),
    init = function()
      -- vim.cmd('auto BufReadPost *.csv,*.tsv,*.dat,*.csv_pipe,*.dbout setlocal filetype=csv')
      vim.g.csv_delim_test = ',;|'
    end,
  })
  -- end
  lang({
    'mechatroner/rainbow_csv',
    ft = { 'csv', 'tsv', 'dat', 'csv_pipe', 'dbout' },
    cmd = { 'RainbowDelim', 'RainbowMultiDelim', 'Select', 'CSVLint' },
  })
  lang({
    'Bekaboo/dropbar.nvim',
    opts = {
      general = {
        enable = function(buf, win, _)
          if not vim.fn.has('nvim-0.10') then
            return false
          end
          return vim.fn.win_gettype(win) == ''
              and vim.wo[win].winbar == ''
              and vim.bo[buf].bt == ''
              and (not vim.tbl_contains({ 'help', 'guihua', 'terminal' }, vim.bo[buf].buftype))
              and (
                vim.bo[buf].ft == 'markdown'
                or (
                  buf
                  and vim.api.nvim_buf_is_valid(buf)
                  and (pcall(vim.treesitter.get_parser, buf, vim.bo[buf].ft))
                  and true
                  or false
                )
              )
        end,
        attach_events = {
          'OptionSet',
          'BufWinEnter',
          'BufWritePost',
          'WinScrolled',
        },
      },
    },
  })
end

-- lang({
--   'nanotee/sqls.nvim',
--   ft = { 'sql', 'pgsql', 'mysql' },
--   module = true,
-- })
-- if typecheck({ 'json', 'js', 'javascript', 'javascriptreact' }) then
--   lang({
--     'danymat/neogen',
--     lazy = true,
--     config = function()
--       require('neogen').setup({ snippet_engine = 'luasnip' })
--     end,
--     ft = { 'js', 'html', 'javascript', 'javascriptreact', 'json' },
--   })
-- end

-- -- lang({ 'ThePrimeagen/refactoring.nvim', config = conf.refactor })

-- -- Automatically convert strings to f-strings or template strings and back
-- -- lang({
-- --   'chrisgrieser/nvim-puppeteer',
-- --   lazy = true,
-- -- })
-- -- ipython

-- lang({
-- 'simrat39/rust-tools.nvim',
-- ft = { 'rust' },
-- config = function()
-- vim.defer_fn(function()
-- require('rust-tools').setup({
-- server = {
-- on_attach = function(c, b)
-- require('navigator.lspclient.mapping').setup({ client = c, bufnr = b })
-- end,
-- },
-- })
-- end, 200)
-- end,
-- })
