local conf = require('modules.tools.config')
local spec = require('modules.spec')
local cond = function()
  return not vim.g.vscode and not vim.wo.diff
end
return function(tools)
  local is_win = require('core.global').is_windows
  -- local gitrepo = vim.fn.isdirectory('.git/index')

  local dev = _G.is_dev()

  tools({
    'esmuellert/codediff.nvim',
    cmd = {
      'CodeDiff',
      'CodeDiffOpen',
      'CodeDiffClose',
    },
    config = conf.codediff,
  })

  tools({
    'lewis6991/gitsigns.nvim',
    cond = cond,
    opts = conf.gitsigns,
    -- keys = {']c', '[c'},  -- load by lazy.lua
    event = { 'CmdlineEnter' },
    lazy = false,
  })

  tools({
    _G.plugin_path('ray-x/forgit.nvim'),

    cmd = { 'Ga', 'Gaa', 'Gd', 'Glo', 'Gs', 'Gc', 'Gpl', 'Gps' },
    event = { 'CmdwinEnter', 'CmdlineEnter' },
    dependencies = {
      { 'junegunn/fzf', build = './install --bin' },
    },
    opts = {
      debug = true,
      log_path = vim.fn.expand('$HOME') .. '/.cache/nvim/forgit.log',
      vsplit = false,
      height_ratio = 0.8,
    },
  })

  if true then
    tools({
      'dmtrKovalenko/fff.nvim',
      build = function()
        -- downloads a prebuilt binary or falls back to cargo build
        require('fff.download').download_or_build_binary()
      end,
      -- for nixos:
      -- build = "nix run .#release",
      opts = {
        debug = {
          enabled = true,
          show_scores = true,
        },
      },
      lazy = false, -- the plugin lazy-initialises itself
      keys = {
        {
          'ff',
          function()
            require('fff').find_files()
          end,
          desc = 'FFFind files',
        },
        {
          'fg',
          function()
            require('fff').live_grep()
          end,
          desc = 'LiFFFe grep',
        },
        {
          'fz',
          function()
            require('fff').live_grep({ grep = { modes = { 'fuzzy', 'plain' } } })
          end,
          desc = 'Live fffuzy grep',
        },
        {
          'fc',
          function()
            require('fff').live_grep({ query = vim.fn.expand('<cword>') })
          end,
          desc = 'Search current word',
        },
      },
    })
  end
  tools({
    'rbong/vim-flog',
    cmd = { 'Flog', 'Flogsplit', 'Flg', 'Flgs' },
    event = { 'FuncUndefined' },
    dependencies = {
      {
        'tpope/vim-rhubarb',
        cmd = { 'GBrowse' },
        config = function()
          vim.api.nvim_create_user_command('Browse', function(opts)
            local url = opts.fargs[1]
            -- for github append #Llinenumber
            if url:find('github') then
              url = url .. '#L' .. vim.fn.line('.')
            end
            vim.ui.open(url)
          end, { nargs = 1 })
          vim.keymap.set({ 'n' }, '<leader>gb', '<Cmd>Browse<CR>', { noremap = true, silent = true })
          vim.keymap.set({ 'x' }, 'gy', [['<,'>GBrowse!<CR>]], { noremap = true, silent = true })
        end,
      },
      {
        'tpope/vim-fugitive',
        event = { 'CmdwinEnter', 'CmdlineEnter' },
      },
    },
  })

  tools = spec.wrap_register(tools, spec.not_diff)

  tools({
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    event = { 'CmdlineEnter', 'CursorHold' },
    config = function()
      require('utils.telescope').setup()
    end,
    cond = cond,
    dependencies = {
      { 'nvim-lua/plenary.nvim', lazy = true, module = true },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-telescope/telescope-live-grep-args.nvim' },
      { _G.plugin_path('ray-x/telescope-ast-grep.nvim'), dev = _G.is_dev() },
      { _G.plugin_path('ray-x/shell-history.nvim'), dev = _G.is_dev() },
    },
    module = true,
  })
  tools({
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = cond,
    event = { 'CmdlineEnter', 'CursorHold' },
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
    },
  })
  tools({
    'crispgm/telescope-heading.nvim',
    cond = cond,
    event = { 'CmdlineEnter', 'CursorHold' },
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
    },
  })

  tools({
    _G.plugin_path('ray-x/mkdn.nvim'),
    dev = _G.is_dev(),
    ft = { 'markdown', 'md' },
    cmd = { 'MkdnNew', 'MkdnDaily', 'MkdnNewDaily', 'GtdStart' },
    -- module = true,
    cond = function()
      return not vim.wo.diff
    end,
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
      {
        'HakonHarnes/img-clip.nvim',
        module = true,
        command = { 'PasteImage' },
        opts = {
          relative_to_current_file = true,
          copy_images = true,
          download_images = true,
          filetypes = {
            markdown = {
              download_images = true, ---@type boolean
            },
          },
        },
      },
    },
    opts = {
      debug = true,
      paste_link = function()
        vim.keymap.set({ 'n', 'x' }, '<leader>p', function()
          if not require('mkdn.lnk').fetch_and_paste_url() then
            -- paste image contents
            require('img-clip').paste_image()
          end
        end, {
          noremap = true,
          desc = 'Fetch the title of the URL under the cursor and paste it as a Markdown link',
        })
      end,
      internal_features = true,
      notes_root = os.getenv('HOME') .. '/Library/CloudStorage/Dropbox/obsidian',
      templates = {
        daily = {
          path = 'journal/2025',
        },
      },
    },
  })

  tools({
    'nvim-telescope/telescope-live-grep-args.nvim',
    cond = cond,
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
    },
    module = true,
  })

  tools({
    _G.plugin_path('ray-x/telescope-ast-grep.nvim'),
    cond = cond,

    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
    },
    event = { 'CmdlineEnter' },
  })

  vim.g.db_ui_save_location = '~/data/db_ui_queries'
  tools({
    'kristijanhusak/vim-dadbod-ui',
    cond = cond,
    cmd = {
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUI',
    },
    config = conf.vim_dadbod_ui,
    dependencies = {
      { 'tpope/vim-dadbod', ft = { 'sql' } },
    },
    init = function()
      vim.g.db_ui_default_query = 'select * from "{table}" limit 20'
      -- vim.g.db_ui_save_location = require('core.global').home .. '/.cache/vim/db_ui_queries'
      -- vim.g.db_ui_save_location = vim.fn.getcwd() .. sep .. 'db'
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.dbs = { local_pg = 'postgres://postgres:postgres@localhost:5432/postgres' }
      vim.g.db_ui_use_nerd_fonts = 1
      -- vim.g.catalog = os.getenv('$CATALOGUE_DATABASE_URL')
      -- vim.g.history = os.getenv('$HISTORY_DATABASE_URL')
      -- vim.g.rec = os.getenv('$RECENGINE_DATABASE_URL')
    end,
  })
  -- tools({ 'mattn/webapi-vim', lazy = true })
  tools({ 'nvim-lua/plenary.nvim', module = true })
  tools({
    cond = cond,
    'edluffy/hologram.nvim',
    config = conf.hologram,
    ft = { 'markdown', 'md', 'norg', 'org' },
  })

  tools({
    cond = cond,
    'folke/which-key.nvim',
    event = { 'CmdlineEnter', 'ModeChanged', 'TextYankPost' },
    module = false,
    config = function()
      require('modules.tools.which_key').init()
    end,
  })

  -- tools({ 'will133/vim-dirdiff', cmd = { 'DirDiff' } })

  tools({
    'editorconfig/editorconfig-vim',
    cmd = { 'EditorConfigReload' },
    -- ft = { 'go','typescript','javascript','vim','rust','zig','c','cpp' }
  })

  tools({
    'kamykn/spelunker.vim',
    cmd = { 'Spell' },
    init = conf.spelunker,
    config = conf.spellcheck,
  })

  local cmd = [[sh -c "cd app && yarn install"]]
  if is_win then
    cmd = 'cd app && yarn install'
  end

  tools({
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown', 'pandoc.markdown', 'rmd' },
    cmd = { 'MarkdownPreview' },
    cond = cond,
    init = conf.mkdp,
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  })

  tools({
    'OXY2DEV/markview.nvim',
    lazy = true,
  })

  -- Note mini has similar function but lacking features
  --[[
    :BDelete! hidden
    :BDelete nameless
    :BDelete this
    :BDelete 1
    :BDelete regex='.*[.].md'

    :BWipeout! all
    :BWipeout other
    :BWipeout hidden glob=*.lua

  tools({
    'kazhala/close-buffers.nvim',
    cmd = { 'BDelete', 'BWipeout', 'Bd' },
    config = conf.close_buffers,
  })
  ]]
  --

  -- nvim-toggleterm.lua ?
  tools({
    'akinsho/toggleterm.nvim',
    cond = cond,
    cmd = { 'ToggleTerm', 'TermExec' },
    event = { 'CmdwinEnter', 'CmdlineEnter' },
    config = conf.floaterm,
  })

  -- cmd = 'bash install.sh'

  tools({
    _G.plugin_path('ray-x/sad.nvim'),

    cond = cond,
    cmd = { 'Sad' },
    opts = {
      debug = true,
      log_path = vim.fn.expand('$HOME') .. '/.cache/nvim/nvim_debug.log',
      vsplit = false,
      height_ratio = 0.8,
      autoclose = false,
    },
  })

  tools({
    _G.plugin_path('ray-x/viewdoc.nvim'),

    cmd = { 'Viewdoc' },
    cond = cond,
    config = function()
      require('viewdoc').setup({
        debug = true,
        log_path = vim.fn.expand('$HOME') .. '/.cache/nvim/nvim_debug.log',
      })
    end,
  })
  tools({
    'kevinhwang91/nvim-bqf',
    event = { 'CmdlineEnter', 'QuickfixCmdPre' },
    config = conf.bqf,
  })

  tools({
    'voldikss/vim-translator',
    keys = { '<Plug>TranslateW', '<Plug>TranslateWV' },
    init = function()
      vim.api.nvim_set_keymap('n', '<Leader>ts', '<Plug>TranslateW', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('v', '<Leader>ts', '<Plug>TranslateWV', { noremap = true, silent = true })
    end,
  })
  --The linediff plugin provides a simple command, :Linediff, which is used to diff two separate blocks of text.
  tools({ 'AndrewRadev/linediff.vim', cmd = { 'Linediff' } }) -- , "'<,'>Linediff"
  --

  tools({
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^4.0.0', -- pin major version, include fixes and features that do not have breaking changes
    opts = {},
  })
end

--[[

tools({ -- spend hours but still failed to get it work, can not set sources dynamically, also seems the repo is not maintained for months
  'kndndrj/nvim-dbee',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  event = { 'CmdlineEnter' },
  ft = 'sql',
  build = function()
    require('dbee').install()
  end,
  config = function()
    if vim.fn.empty(vim.g.connections) == 1 then
      require('utils.database').load_dbs()
    end
    vim.env.DBEE_CONNECTIONS = vim.inspect(vim.g.connections)
    require('dbee').setup()
  end,
})

tools({
  'rickhowe/diffchar.vim',
  cond = function()
    return vim.wo.diff
  end,
  init = function()
    -- vim.g.DiffColors=3
    vim.g.DiffUnit = 'Char'
  end,
  event = { 'BufEnter' },
  cmd = { 'DiffviewOpen' },
})
tools({
  'ThePrimeagen/git-worktree.nvim',
  event = { 'VeryLazy' },
  cond = cond,
  config = conf.worktree,
})
  tools({
    'ThePrimeagen/harpoon',
    cmd = { 'HarpoonTerm', 'HarpoonSend', 'HarpoonSendLine' },
    event = { 'CmdlineEnter' },
    cond = cond,
    module = true,
    opts = {
      excluded_filetypes = { 'harpoon', 'guihua', 'term' },
    },
  })

  tools({
    'akinsho/git-conflict.nvim',
    cmd = {
      'GitConflictListQf',
      'GitConflictChooseOurs',
      'GitConflictChooseTheirs',
      'GitConflictChooseBoth',
      'GitConflictNextConflict',
    },
    config = conf.git_conflict,
  })
  tools({
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'Oil' },
  })
  ]]
--
