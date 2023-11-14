local conf = require('modules.editor.config')

return function(editor)
  editor({
    'anuvyklack/hydra.nvim',
    dependencies = 'anuvyklack/keymap-layer.nvim',
    event = { 'CmdwinEnter', 'CmdlineEnter', 'CursorMoved' },
    config = conf.hydra,
    lazy = true,
  })

  editor({
    'gbprod/substitute.nvim',
    event = { 'CmdlineEnter', 'TextYankPost' },
    config = conf.substitute,
    lazy = true,
  })

  editor({
    'tpope/vim-abolish',
    event = { 'CmdlineEnter' },
    keys = { '<Plug>(abolish-coerce-word)' },
    init = function()
      -- use default mapping
      vim.g.abolish_no_mappings = true
    end,
    lazy = true,
  })
  editor({
    'tpope/vim-repeat',
    event = { 'CmdlineEnter' },
    keys = { '<Plug>(RepeatDot)', '<Plug>(RepeatUndo)', '<Plug>(RepeatRedo)' },

    init = function()
      vim.fn['repeat#set'] = function(...)
        vim.fn['repeat#set'] = nil
        require('lazy').load({ plugins = { 'vim-repeat' } })
        return vim.fn['repeat#set'](...)
      end
    end,
    lazy = true,
  })

  -- I like this plugin, but 1) offscreen context is slow
  -- 2) it not friendly to lazyload and treesitter startup
  --  motions g%, [%, ]%, and z%.
  --  text objects i% and a%
  editor({
    'andymass/vim-matchup',
    event = { 'CursorHold', 'CursorHoldI' },
    key = { '<Plug>(matchup-%)', '<Plug>(matchup-g%)' },
    cmd = { 'MatchupWhereAmI' }, --
    setup = function()
      local fsize = vim.fn.getfsize(vim.fn.expand('%:p:f'))
      if fsize == nil or fsize < 0 then
        fsize = 1
      end
      local enabled = 1
      if fsize > 500000 then
        enabled = 0
      end
      vim.g.matchup_enabled = enabled
      vim.g.matchup_surround_enabled = 0
      vim.g.matchup_transmute_enabled = 0
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_hi_surround_always = 1
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
      vim.cmd([[nnoremap <c-s-k> :<c-u>MatchupWhereAmI?<cr>]])
    end,
  })

  editor({
    'folke/flash.nvim',
    event = 'VeryLazy',
    config = true,
    ---@type Flash.Config
    opts = {

      -- labels = "abcdefghijklmnopqrstuvwxyz",
      labels = 'asdfghjklqwertyuiopzxcvbnm0123456789ASDFGHJKLQWERTYUIOPZXCVBNM',
      -- `f`, `F`, `t`, `T`, `;` and `,` motions
      modes = {
        char = {
          enabled = true,
          -- dynamic configuration for ftFT motions
          config = function(opts)
            -- autohide flash when in operator-pending mode
            opts.autohide = opts.autohide
              or (vim.fn.mode(true):find('no') and vim.v.operator == 'y')

            -- disable jump labels when not enabled, when using a count,
            -- or when recording/executing registers
            opts.jump_labels = opts.jump_labels
              and vim.v.count == 0
              and vim.fn.reg_executing() == ''
              and vim.fn.reg_recording() == ''

            -- Show jump labels only in operator-pending mode
            -- opts.jump_labels = vim.v.count == 0 and vim.fn.mode(true):find("o")
          end,
          autohide = true,
          jump_labels = true,
          multi_line = false,
          char_actions = function(motion)
            return {
              -- ['<C-n>'] = 'next', -- set to `right` to always go right
              -- ['<C-p>'] = 'prev', -- set to `left` to always go left
              -- clever-f style
              [motion:lower()] = 'next',
              [motion:upper()] = 'prev',
              -- jump2d style: same case goes next, opposite case goes prev
              -- [motion] = "next",
              -- [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
            }
          end,
          -- hide after jump when not usi
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "o", "x" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  })

  editor({
    'kylechui/nvim-surround',
    lazy = true,
    -- opt for sandwitch for now until some issue been addressed
    event = { 'CursorMoved', 'CursorMovedI', 'CursorHold' },
    config = function()
      require('nvim-surround').setup({
        -- Configuration here, or leave empty to use defaults
        -- sournd  cs, ds, yss
        keymaps = {
          -- default
          insert = '<C-g>s',
          insert_line = '<C-g>S',
          normal = 'ca',   -- e.g. caiw"
          normal_cur = 'cas',
          normal_line = 'cA',
          normal_cur_line = 'cAl',
          visual = 'ca',
          visual_cur = 'cas',
          visual_line = 'cA',
          delete = 'ds',
          change = 'cs',
        },
      })
    end,
  })

  -- nvim-colorizer replacement
  editor({
    'rrethy/vim-hexokinase',
    -- ft = { 'html','css','sass','vim','typescript','typescriptreact'},
    config = conf.hexokinase,
    build = 'make hexokinase',
    lazy = true,
    cmd = { 'HexokinaseTurnOn', 'HexokinaseToggle' },
  })

  editor({
    'chrisbra/Colorizer',
    ft = { 'log', 'txt', 'text', 'css' },
    lazy = true,
    cmd = { 'ColorHighlight', 'ColorUnhighlight' },
  })

  editor({
    'kevinhwang91/nvim-hlslens',
    keys = { '/', '?', '*', '#' }, --'n', 'N', '*', '#', 'g'
    lazy = true,
    config = conf.hlslens,
  })

  -- not working well with navigator
  -- editor({
  --   'kevinhwang91/nvim-ufo',
  --   lazy = true,
  --   dependencies = { 'kevinhwang91/promise-async' },
  --   config = conf.ufo,
  -- })

  editor({
    'mg979/vim-visual-multi',
    -- stylua: ignore
    keys = { '<C-n>', '<C-N>', '<M-n>', '<S-Down>', '<S-Up>', '<M-Left>',
      '<M-i>', '<M-Right>', '<M-D>', '<M-Down>', '<C-d>', '<C-Down>',
      '<C-Up>', '<S-Right>', '<C-LeftMouse>', '<M-LeftMouse>', '<M-C-RightMouse>',
    },
    lazy = true,
    init = conf.vmulti,
  })

  editor({
    'numToStr/Comment.nvim',
    keys = { 'g', '<ESC>', 'v', 'V', '<c-v>' },
    event = { 'ModeChanged' },
    module = true,
    config = conf.comment,
  })

  -- copy paste failed in block mode when clipboard = unnameplus"
  editor({
    'gbprod/yanky.nvim',
    event = { 'TextYankPost' },
    keys = {
      '<Plug>(YankyPutAfter)',
      '<Plug>(YankyPutBefore)',
      '<Plug>(YankyGPutBefore)',
      '<Plug>(YankyGPutAfter)',
    },
    lazy = true,
    config = conf.yanky,
  })

  editor({ 'dhruvasagar/vim-table-mode', cmd = { 'TableModeToggle' } })

  -- fix terminal color
  editor({
    'norcalli/nvim-terminal.lua',
    lazy = true,
    ft = { 'log', 'terminal' },
    config = function()
      require('terminal').setup()
    end,
  })

  editor({
    'simnalamburt/vim-mundo',
    lazy = true,
    cmd = { 'MundoToggle', 'MundoShow', 'MundoHide' },
    build = function()
      vim.cmd([[packadd vim-mundo]])
      vim.cmd([[UpdateRemotePlugins]])
    end,
    init = function()
      -- body
      vim.g.mundo_prefer_python3 = 1
    end,
  })
  editor({ 'mbbill/undotree', lazy = true, cmd = { 'UndotreeToggle' } })

  editor({
    'Wansmer/treesj',
    lazy = true,
    cmd = { 'TSJToggle', 'TSJJoin', 'TSJSplit' },
    keys = { '<space>j', '<space>s' },
    config = function()
      require('treesj').setup({
        use_default_keymaps = false,
      })
    end,
  })

  editor({
    'chaoren/vim-wordmotion',
    lazy = true,
    keys = { '<Plug>WordMotion_w', '<Plug>WordMotion_b' },
    init = function()
      -- stylua: ignore
      vim.g.wordmotion_spaces = { '-', '_', '/', '.', ':', "'", '"', '=', '#', ',', '.', ';', '<', '>', '(', ')', '{', '}' }
      vim.g.wordmotion_uppercase_spaces =
        { '/', '.', ':', "'", '"', '=', '#', ',', '.', ';', '<', '>', '(', ')', '{', '}' }
    end,
    -- keys = {'w','W', 'gE', 'aW'}
  })

  editor({
    'Pocco81/true-zen.nvim',
    lazy = true,
    cmd = { 'TZAtaraxis', 'TZMinimalist', 'TZNarrow', 'TZFocus' },
    config = function()
      require('true-zen').setup({})
    end,
  })

  editor({
    'nvim-orgmode/orgmode',
    lazy = true,
    config = conf.orgmode,
    ft = 'org',
    dependencies = {
      'akinsho/org-bullets.nvim',
      lazy = true,
      config = function()
        require('org-bullets').setup()
      end,
    },
  })
  editor({
    'lukas-reineke/headlines.nvim',
    ft = { 'org', 'norg', 'md' },
    config = conf.headline,
  })
  editor(
    {
      'echasnovski/mini.nvim',
      version = false,
      event = { 'CursorHold', 'CursorHoldI', 'CursorMoved', 'CursorMovedI', 'ModeChanged' },
      config = conf.mini,
    } -- mini.ai to replace targets
  )

  editor({
    'AndrewRadev/switch.vim',
    lazy = true,
    cmd = { 'Switch', 'SwitchCase' }, --'Switch!' , 'Switch?',
    keys = { '<Plug>(Switch)' },
    event = { 'FuncUndefined' },
    init = function()
      vim.g.switch_mapping = '<Space>t'
      vim.fn['switch#Switch'] = function(...)
        vim.fn['switch#Swtich'] = nil
        require('lazy').load({ plugins = { 'switch.vim' } })
        return vim.fn['switch#Switch'](...)
      end
    end,
  })
  editor({
    'mizlan/iswap.nvim',
    lazy = true,
    cmd = { 'ISwap', 'ISwapWith', 'ISwapNode', 'ISwapNodeWith' },
    config = function()
      require('iswap').setup({})
    end,
  })
  editor({
    'chentoast/marks.nvim',
    lazy = true,
    cmd = { 'MarksToggleSigns' },
    config = function()
      require('marks').setup({})
    end,
    keys = { 'm', '<Plug>(Marks-set)', '<Plug>(Marks-toggle)' },
  })
  editor({
    'tversteeg/registers.nvim',
    name = 'registers',
    keys = {
      { '"', mode = { 'n', 'v' } },
      { '<C-R>', mode = 'i' },
    },
    cmd = 'Registers',
    config = function()
      require('registers').setup({
        show = '*"%01234abcpwy:',
        -- Show a line at the bottom with registers that aren't filled
        show_empty = false,
      })
    end,
  })

  -- editor({
  --   'rainbowhxch/accelerated-jk.nvim',
  --   keys = { 'j', 'k', 'h', 'l', '<Up>', '<Down>', '<Left>', '<Right>' },
  --   config = function()
  --     require('accelerated-jk').setup({
  --       mode = 'time_driven',
  --       acceleration_motions = { 'h', 'l', 'e', 'b' },
  --       acceleration_limit = 150,
  --       acceleration_table = { 7, 12, 17, 21, 24, 26, 28, 30 },
  --       enable_deceleration = false,
  --       deceleration_table = { { 150, 9999 } },
  --     })
  --     vim.keymap.set('n', '<Down>', '<Plug>(accelerated_jk_j)', {})
  --     vim.keymap.set('n', '<Up>', '<Plug>(accelerated_jk_k)', {})
  --     vim.keymap.set('n', '<Left>', function()
  --       require('accelerated-jk').move_to('h')
  --     end, {})
  --     vim.keymap.set('n', '<Right>', function()
  --       require('accelerated-jk').move_to('l')
  --     end, {})
  --   end,
  -- })
end
