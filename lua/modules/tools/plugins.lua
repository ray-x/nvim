local conf = require('modules.tools.config')
return function(tools)
  local is_win = require('core.global').is_windows
  local gitrepo = vim.fn.isdirectory('.git/index')
  tools({
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    config = function()
      require('utils.telescope').setup()
    end,
    init = function()
      require('utils.helper').loader({ 'plenary.nvim' })
    end,
    dependencies = {
      { 'nvim-lua/plenary.nvim', lazy = true },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', lazy = true, event = { 'CmdlineEnter', 'CursorHold' },},
      { 'nvim-telescope/telescope-live-grep-args.nvim', lazy = true, event = { 'CmdlineEnter', 'CursorHold' }, },
      { 'nvim-telescope/telescope-file-browser.nvim', lazy = true, event = { 'CmdlineEnter', 'CursorHold' }, },
    },
    lazy = true,
  })
  tools({
    'kristijanhusak/vim-dadbod-ui',
    cmd = {
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUI',
      'DBUIFindBuffer',
      'DBUIRenameBuffer',
      'DB',
    },
    config = conf.vim_dadbod_ui,
    dependencies = { 'tpope/vim-dadbod', ft = { 'sql' } },
    lazy = true,
    init = function()
      vim.g.dbs = {
        eraser = 'postgres://postgres:password@localhost:5432/eraser_local',
        staging = 'postgres://postgres:password@localhost:5432/my-staging-db',
        wp = 'mysql://root@localhost/wp_awesome',
      }
    end,
  })
  tools({ 'mattn/webapi-vim', lazy = true })
  tools({ 'nvim-lua/plenary.nvim', lazy = true })
  tools({
    'edluffy/hologram.nvim',
    config = conf.hologram,
    lazy = true,
    ft = { 'markdown', 'md', 'norg', 'org' },
  })

  tools({
    'vim-test/vim-test',
    cmd = { 'TestNearest', 'TestFile', 'TestSuite' },
    init = conf.vim_test,
  })
  tools({
    'folke/which-key.nvim',
    cmd = { 'WhichKey' },
    module = false,
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
      require('which-key').setup({
        key_labels = {
          ['<space>'] = '󱁐',
          ['telescope'] = ' ',
          ['Telescope'] = ' ',
          ['operator'] = '',
        },
        window = {
          margin = { 0, 0, 0, 0 }, -- extra window margin [top, right, bottom, left]
          padding = { 0, 0, 0, 0 }, -- extra window padding etop, right, bottom, lefte
          winblend = 20,
        },
        layout = {
          height = { min = 1, max = 4 }, -- min and max height of the columns
          spacing = 3, -- spacing between columns
          width = { min = 12, max = 40 }, -- min and max width of the columns
          align = 'left', -- align columns left, center or right
        },
        hidden = {
          '<silent>',
          '<cmd>',
          '<Cmd>',
          '<CR>',
          'call',
          'lua',
          '^:',
          '^ ',
          'require',
          'escope',
          'erator',
          '"',
        }, --
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  })

  tools({
    'nvim-neotest/neotest',
    dependencies = {
      {
        'haydenmeade/neotest-jest',
        config = conf.neotest_jest,
      },
      { 'nvim-neotest/neotest-plenary' },
      { 'nvim-neotest/neotest-python' },
    },
    config = conf.neotest,
    cmd = { 'Neotest', 'NeotestFile', 'NeoResult' },
  })

  tools({ 'nvim-neotest/neotest-plenary', lazy = true })
  tools({ 'will133/vim-dirdiff', cmd = { 'DirDiff' } })

  tools({
    'editorconfig/editorconfig-vim',
    lazy = true,
    cmd = { 'EditorConfigReload' },
    -- ft = { 'go','typescript','javascript','vim','rust','zig','c','cpp' }
  })

  -- tools({
  --   'ThePrimeagen/harpoon',
  --   -- lazy = true,
  --   event = { 'InsertEnter' },
  --   config = function()
  --     require('harpoon').setup({
  --       global_settings = {
  --         save_on_toggle = false,
  --         save_on_change = true,
  --         tmux_autoclose_windows = false,
  --         excluded_filetypes = { 'harpoon' },
  --       },
  --     })
  --     require('telescope').load_extension('harpoon')
  --   end,
  -- })

  tools({
    'kamykn/spelunker.vim',
    cmd = { 'Spell' },
    init = conf.spelunker,
    config = conf.spellcheck,
  })
  tools({
    'rhysd/vim-grammarous',
    cmd = { 'GrammarousCheck' },
    ft = { 'markdown', 'txt' },
    init = conf.grammarous,
  })

  tools({
    'plasticboy/vim-markdown',
    ft = 'markdown',
    dependencies = { 'godlygeek/tabular' },
    cmd = { 'Toc' },
    init = conf.markdown,
  })

  local cmd = [[sh -c "cd app && yarn install"]]
  if is_win then
    cmd = 'cd app && yarn install'
  end

  tools({
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown', 'pandoc.markdown', 'rmd' },
    cmd = { 'MarkdownPreview' },
    init = conf.mkdp,
    build = cmd,
  })

  tools({
    'kazhala/close-buffers.nvim',
    cmd = { 'Kwbd', 'BDelete', 'BWipeout', 'Bd' },
    config = conf.close_buffers,
  })

  -- nvim-toggleterm.lua ?
  tools({
    'akinsho/toggleterm.nvim',
    cmd = { 'ToggleTerm', 'TermExec' },
    event = { 'CmdwinEnter', 'CmdlineEnter' },
    config = conf.floaterm,
  })

  tools({
    'NTBBloodbath/rest.nvim',
    lazy = true,
    ft = { 'http', 'rest' },
    keys = { '<Plug>RestNvim', '<Plug>RestNvimPreview', '<Plug>RestNvimLast' },
    cmd = { 'RestRun', 'RestPreview', 'RestLast' },
    config = conf.rest,
  })
  --
  tools({ 'nanotee/zoxide.vim', cmd = { 'Z', 'Lz', 'Zi' } })

  cmd = 'bash install.sh'
  -- if is_win then
  --   cmd = ':Clap install-binary'
  -- end
  -- tools({
  --   'liuchengxu/vim-clap',
  --   cmd = { 'Clap' },
  --   build = cmd,
  --   init = conf.clap,
  --   config = conf.clap_after,
  -- })
  --
  tools({
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewOpen',
      'DiffviewFilepistory',
      'DiffviewFocusFiles',
      'DiffviewToggleFiles',
      'DiffviewRefresh',
    },
    config = conf.diffview,
  })


  tools({
    'ray-x/sad.nvim',
    dev = (plugin_folder():find('github') ~= nil),
    cmd = { 'Sad' },
    lazy = true,
    config = function()
      require('sad').setup({
        debug = true,
        log_path = vim.fn.expand('$HOME') .. '/.cache/nvim/nvim_debug.log',
        vsplit = false,
        height_ratio = 0.8,
        autoclose = false,
      })
    end,
  })

  tools({
    'ray-x/viewdoc.nvim',
    dev = (plugin_folder():find('github') ~= nil),
    cmd = { 'Viewdoc' },
    lazy = true,
    config = function()
      require('viewdoc').setup({
        debug = true,
        log_path = vim.fn.expand('$HOME') .. '/.cache/nvim/nvim_debug.log',
      })
    end,
  })
  if gitrepo then
    tools({
      'lewis6991/gitsigns.nvim',
      config = conf.gitsigns,
      -- keys = {']c', '[c'},  -- load by lazy.lua
      event = {'VeryLazy'},
      lazy = false,
    })

    tools({ 'TimUntersberger/neogit', cmd = { 'Neogit' }, config = conf.neogit })

    tools({
      'ThePrimeagen/git-worktree.nvim',
      event = {'VeryLazy'},
      config = conf.worktree,
    })
    tools({
      'ray-x/forgit.nvim',
      dev = (plugin_folder():find('github') ~= nil),
      lazy = true,
      cmd = { 'Ga', 'Gaa', 'Gd', 'Glo', 'Gs', 'Gc', 'Gpl', 'Gps' },
      event = { 'CmdwinEnter', 'CmdlineEnter' },
      config = function()
        require('forgit').setup({
          debug = true,
          log_path = vim.fn.expand('$HOME') .. '/.cache/nvim/nvim_debug.log',
          vsplit = false,
          height_ratio = 0.8,
        })
      end,
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
      lazy = true,
      config = conf.git_conflict,
    })


    tools({
      'rbong/vim-flog',
      cmd = { 'Flog', 'Flogsplit', 'Flg', 'Flgs' },
      lazy = true,
      event = { 'FuncUndefined' },
      dependencies = {
        'tpope/vim-fugitive',
        cmd = {
          'Gvsplit',
          'G',
          'Gread',
          'Git',
          'Gedit',
          'Gstatus',
          'Gdiffsplit',
          'Gvdiffsplit',
        },
        event = { 'CmdwinEnter', 'CmdlineEnter' },
        -- fn = { 'FugitiveIsGitDir' },
        lazy = true,
      },
    })
  end
  tools({ 'rmagatti/auto-session', config = conf.session, lazy = true })

  tools({
    'rmagatti/session-lens',
    lazy = true,
    -- cmd = "SearchSession",
    -- after = { "telescope.nvim" },
    config = function()
      require('utils.helper').loader('telescope.nvim')
      require('telescope').load_extension('session-lens')
      require('session-lens').setup({
        path_display = { 'shorten' },
        theme_conf = { border = true },
        previewer = true,
      })
    end,
  })

  tools({
    'kevinhwang91/nvim-bqf',
    lazy = true,
    event = { 'CmdlineEnter', 'QuickfixCmdPre' },
    config = conf.bqf,
  })

  -- lua require'telescope'.extensions.project.project{ display_type = 'full' }
  tools({
    'ahmedkhalf/project.nvim',
    lazy = true,
    config = conf.project,
    event = { 'CmdlineEnter' }
  })

  tools({
    'jvgrootveld/telescope-zoxide',
    lazy = true,
    config = function()
      local ok, telescope = pcall(require, 'telescope')
      if not ok then return end
      require('utils.telescope')
      require('telescope').load_extension('zoxide')
    end,
    event = { 'CmdlineEnter', 'CursorHold' },
  })


  if not require('core.global').is_windows then
    tools({
      'AckslD/nvim-neoclip.lua',
      lazy = true,
      dependencies = { 'kkharji/sqlite.lua' },
      event = { 'CmdlineEnter' },
      config = function()
        require('utils.telescope')
        require('neoclip').setup({
          db_path = vim.fn.stdpath('data') .. '/databases/neoclip.sqlite3',
        })
        require('telescope').load_extension('neoclip')
      end,
    })
    tools({
      'nvim-telescope/telescope-frecency.nvim',
      -- cmd = {'Telescope'},
      dependencies = { 'kkharji/sqlite.lua', lazy = true },
      event = { 'CmdlineEnter', 'CursorHold' },
      lazy = true,
      config = function()
        local telescope = require('telescope')
        telescope.load_extension('frecency')
        telescope.setup({
          extensions = {
            frecency = {
              default_workspace = 'CWD',
              show_scores = false,
              show_unindexed = true,
              ignore_patterns = { '*.git/*', '*/tmp/*' },
              disable_devicons = false,
              workspaces = {
                -- ["conf"] = "/home/my_username/.config",
                -- ["data"] = "/home/my_username/.local/share",
                -- ["project"] = "/home/my_username/projects",
                -- ["wiki"] = "/home/my_username/wiki"
              },
            },
          },
        })
        -- vim.api.nvim_set_keymap("n", "<leader><leader>p", "<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>", {noremap = true, silent = true})
      end,
    })
  end

  tools({
    'voldikss/vim-translator',
    lazy = true,
    keys = { '<Plug>TranslateW', '<Plug>TranslateWV' },
    init = function()
      vim.api.nvim_set_keymap(
        'n',
        '<Leader>ts',
        '<Plug>TranslateW',
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        'v',
        '<Leader>ts',
        '<Plug>TranslateWV',
        { noremap = true, silent = true }
      )
    end,
  })
  tools({
    'joaomsa/telescope-orgmode.nvim',
    lazy = true,
    event = { 'CmdlineEnter', 'CursorHold' },
  })
  --The linediff plugin provides a simple command, :Linediff, which is used to diff two separate blocks of text.
  -- tools({
  --   'pfeiferj/nvim-hurl',
  --   lazy = true,
  --   cmd = { 'HurlRun' }, --, "'<,'>HurlRun"
  --   ft = { 'hurl', 'http' },
  -- })
  tools({ 'AndrewRadev/linediff.vim', lazy = true, cmd = { 'Linediff' } }) -- , "'<,'>Linediff"
  tools({
    'ibhagwan/fzf-lua',
    lazy = true,
    cmd = { 'FzfLua' },
    config = function()
      require('fzf-lua').setup({
        winopts = {
          preview = {
            default = 'bat_native',
          },
          on_create = function()
            vim.opt_local.buflisted = false
          end,
        },
      })
    end,
  })
end
