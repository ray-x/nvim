return function(lang)
  local conf = require('modules.lang.config')
  local dev = _G.is_dev()
  local spec = require('modules.spec')
  local ts = require('modules.lang.treesitter')
  ts.treesitter()

  --
  --
  lang({
    _G.plugin_path('ray-x/guihua.lua'),
    build = 'cd lua/fzy && make',
    lazy = false,

    init = function()
      local configured = false

      local function ensure_guihua()
        if configured then
          return
        end
        configured = true
        -- pcall(vim.cmd, 'packadd guihua.lua')
        -- vim.pack.add({'guihua.lua'})
        require('guihua').setup({
          icons = {
            syntax = {
              namespace = '',
            },
          },
        })
      end

      vim.ui.select = function(...)
        ensure_guihua()
        return require('guihua.gui').select(...)
      end

      vim.ui.input = function(...)
        ensure_guihua()
        return require('guihua.gui').input(...)
      end
    end,
  })

  lang({
    'neovim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = ts.treesitter,
    dependencies = { 'neovim-treesitter/treesitter-parser-registry', lazy = false },
  })

  lang = spec.wrap_register(lang, spec.not_diff)
  if not spec.not_diff() then
    return
  end

  lang({
    'nvim-treesitter/nvim-treesitter-textobjects',
    -- dependencies = { 'nvim-treesitter' },
    config = ts.treesitter_obj,
    branch = 'main',
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

  local jsft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact', 'html', 'js', 'jsx', 'ts', 'tsx' }

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
    end,
  })

  lang({ 'yardnsm/vim-import-cost', ft = jsft, cmd = 'ImportCost' })

  lang({
    'Wansmer/symbol-usage.nvim', -- count symbol usage
    event = { 'BufReadPre', 'LspAttach' },
    config = conf.symbol_usage,
  })

  if false then
    -- python related live display values
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
    _G.plugin_path('ray-x/go.nvim'),

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
      'GoTool',
    },
    ft = { 'go', 'gomod', 'gosum', 'gotmpl', 'gohtmltmpl', 'gotexttmpl' },
    event = { 'VeryLazy' },
    opts = conf.go,
  })

  lang({
    _G.plugin_path('ray-x/navigator.lua'),

    dependencies = { _G.plugin_path('ray-x/guihua.lua') },
    opts = conf.navigator,
    module = true,
    event = { 'BufReadPre', 'BufNewFile', 'BufEnter', 'BufWinEnter' },
  })

  lang({
    _G.plugin_path('ray-x/web-tools.nvim'),

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

  lang({ 'mtdl9/vim-log-highlighting', ft = { 'text', 'txt', 'log' } })

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
    event = 'VeryLazy',
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
        -- local parsers = require('nvim-treesitter.parsers')
        -- local buflang = parsers.ft_to_lang(filetype)
        -- lprint(buflang, filetype,  vim.tbl_contains(excluded_filetype, buflang))
        -- return vim.tbl_contains(excluded_filetype, buflang)
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

  lang({
    'nvim-treesitter/nvim-treesitter-context',
    -- event = { 'WinScrolled', 'CmdlineEnter' },
    event = 'VeryLazy',
    opts = function()
      return {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 2, -- How many lines the window should span. Values <= 0 mean no limit.
        min_win_height = 0, -- Minimum height of the window, content will be truncated if necessary.
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
      }
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
    main = 'null-ls',
    dependencies = {
      'nvimtools/none-ls-extras.nvim',
    },
    opts = require('modules.lang.null-ls').config,
    event = { 'BufReadPre', 'BufNewFile', 'CmdlineEnter' },
  })

  -- structural search and replace
  -- put to lang as it depends on treesitter
  lang({ 'cshuaimin/ssr.nvim', config = conf.ssr })

  lang({
    'p00f/clangd_extensions.nvim',
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'h', 'hpp' },
    opts = conf.clangd,
  })

  if false then
    lang({
      'sheng-tse/jupynvim',
      build = function()
        local core = vim.fn.stdpath('data') .. '/lazy/jupynvim/core'
        vim.fn.system({
          'cargo',
          'build',
          '--release',
          '--manifest-path',
          core .. '/Cargo.toml',
        })
      end,
      opts = function()
        return {
          log_level = 'info',
          image_renderer = 'kitty', -- "placeholder", "kitty", or "chafa"
        }
      end,
    })
  end

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
  lang({
    'mechatroner/rainbow_csv',
    ft = { 'csv', 'tsv', 'dat', 'csv_pipe', 'dbout' },
    cmd = { 'RainbowDelim', 'RainbowMultiDelim', 'Select', 'CSVLint' },
  })
end

--[[
  lang({
    'Bekaboo/dropbar.nvim',
    opts = {
      general = {
        enable = function(buf, win, _)
          return vim.fn.win_gettype(win) == ''
            and vim.wo[win].winbar == ''
            and vim.bo[buf].bt == ''
            and (not vim.tbl_contains({ 'help', 'guihua', 'terminal' }, vim.bo[buf].buftype))
            and (vim.bo[buf].ft == 'markdown' or (buf and vim.api.nvim_buf_is_valid(buf) and (pcall(vim.treesitter.get_parser, buf, vim.bo[buf].ft)) and true or false))
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
]]
