local conf = require("modules.editor.config")

-- alternatives: steelsojka/pears.nvim
-- windwp/nvim-ts-autotag  'html', 'javascript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue'
-- windwp/nvim-autopairs
return function(editor)
  editor({
    "windwp/nvim-autopairs",
    -- keys = {{'i', '('}},
    -- keys = {{'i'}},
    after = { "nvim-cmp" }, -- "nvim-treesitter", nvim-cmp "nvim-treesitter", coq_nvim
    -- event = "InsertEnter",  --InsertCharPre
    -- after = "hrsh7th/nvim-compe",
    config = conf.autopairs,
    opt = true,
  })

  editor({
    "anuvyklack/hydra.nvim",
    requires = "anuvyklack/keymap-layer.nvim",
    -- event = { "CmdwinEnter", "CmdlineEnter", "CursorMoved" },
    config = conf.hydra,
    opt = true,
  })

  editor({ "gbprod/substitute.nvim", event = { "CmdlineEnter", "TextYankPost" }, config = conf.substitute, opt = true })

  editor({
    "tpope/vim-abolish",
    event = { "CmdlineEnter" },
    keys = { "<Plug>(abolish-coerce-word)" },
    setup = function()
      -- use default mapping
      vim.g.abolish_no_mappings = true
    end,
    opt = true,
  })

  -- I like this plugin, but 1) offscreen context is slow
  -- 2) it not friendly to lazyload and treesitter startup
  --  motions g%, [%, ]%, and z%.
  --  text objects i% and a%
  editor({
    "andymass/vim-matchup",
    opt = true,
    event = { "CursorHold", "CursorHoldI" },
    cmd = { "MatchupWhereAmI?" },
    config = function()
      local fsize = vim.fn.getfsize(vim.fn.expand("%:p:f"))
      if fsize == nil or fsize < 0 then
        fsize = 1
      end
      local enabled = 1
      if fsize > 500000 then
        enabled = 0
      end
      vim.g.matchup_enabled = enabled
      vim.g.matchup_surround_enabled = enabled
      -- vim.g.matchup_transmute_enabled = 1
      vim.g.matchup_matchparen_deferred = enabled
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.cmd([[nnoremap <c-s-k> :<c-u>MatchupWhereAmI?<cr>]])
    end,
  })

  -- Feel more comfortale with hop
  -- editor({
  --   "ggandor/leap.nvim",
  --   keys = { "s", "S" },
  --   opt = true,
  --   module = "leap",
  --   config = require("modules.editor.leap").setup,
  --   requires = {
  --     {
  --       "ggandor/leap-ast.nvim",
  --       after = "leap.nvim",
  --       opt = true,
  --       module = "leap-ast",
  --       config = require("modules.editor.leap").ast,
  --     },
  --     { "ggandor/flit.nvim", after = "leap.nvim", opt = true, module = "flit", require("modules.editor.leap").flit },
  --   },
  -- })

  editor({
    "machakann/vim-sandwich",
    opt = true,
    event = { "CursorMoved", "CursorMovedI" },
    cmd = { "Sandwith" },
    setup = function()
      vim.g.sandwich_no_default_key_mappings = 1
    end,
  })

  editor({
    "kylechui/nvim-surround",
    opt = true,
    -- opt for sandwitch for now until some issue been addressed
    -- event = { "CursorMoved", "CursorMovedI" },
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
        -- sournd  cs, ds, yss
        keymaps = {
          -- default
          -- [insert] = "ys",
          -- insert_line = "yss",
          visual = "<Leader>cr",
          -- delete = "ds",
          -- change = "cs",
        },
      })
    end,
  })

  -- nvim-colorizer replacement
  editor({
    "rrethy/vim-hexokinase",
    -- ft = { 'html','css','sass','vim','typescript','typescriptreact'},
    config = conf.hexokinase,
    run = "make hexokinase",
    opt = true,
    cmd = { "HexokinaseTurnOn", "HexokinaseToggle" },
  })

  editor({
    "chrisbra/Colorizer",
    ft = { "log", "txt", "text" },
    opt = true,
    cmd = { "ColorHighlight", "ColorUnhighlight" },
  })

  -- booperlv/nvim-gomove
  -- <A-k>   Move current line/selection up
  -- <A-j>   Move current line/selection down
  -- <A-h>   Move current character/selection left
  -- <A-l>   Move current character/selection right

  editor({
    "booperlv/nvim-gomove",
    -- event = { "CursorMoved", "CursorMovedI" },
    keys = { "v", "V", "<c-v>", "<c-V>" },
    config = conf.move,
  })

  -- Great plugin.
  ft =
    { "c" },
    editor({
      "kevinhwang91/nvim-hlslens",
      keys = { "/", "?", "*", "#" }, --'n', 'N', '*', '#', 'g'
      module = { "hlslens" },
      opt = true,
      config = conf.hlslens,
    })

  editor({ "kevinhwang91/nvim-ufo", opt = true, requires = { "kevinhwang91/promise-async" }, config = conf.ufo })

  editor({
    "mg979/vim-visual-multi",
    keys = {
      "<C-n>",
      "<C-N>",
      "<M-n>",
      "<S-Down>",
      "<S-Up>",
      "<M-Left>",
      "<M-i>",
      "<M-Right>",
      "<M-D>",
      "<M-Down>",
      "<C-d>",
      "<C-Down>",
      "<S-Right>",
      "<C-LeftMouse>",
      "<M-LeftMouse>",
      "<M-C-RightMouse>",
    },
    opt = true,
    setup = conf.vmulti,
  })

  editor({ "indianboy42/hop-extensions", after = "hop", opt = true })

  -- EasyMotion in lua. -- maybe replace sneak
  editor({
    "phaazon/hop.nvim",
    as = "hop",
    cmd = {
      "HopWord",
      "HopWordMW",
      "HopWordAC",
      "HopWordBC",
      "HopLine",
      "HopChar1",
      "HopChar1MW",
      "HopChar1AC",
      "HopChar1BC",
      "HopChar2",
      "HopChar2MW",
      "HopChar2AC",
      "HopChar2BC",
      "HopPattern",
      "HopPatternAC",
      "HopPatternBC",
      "HopChar1CurrentLineAC",
      "HopChar1CurrentLineBC",
      "HopChar1CurrentLine",
    },
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require("hop").setup({ keys = "adghklqwertyuiopzxcvbnmfjADHKLWERTYUIOPZXCVBNMFJ1234567890" })
      -- vim.api.nvim_set_keymap('n', '$', "<cmd>lua require'hop'.hint_words()<cr>", {})
    end,
  })

  editor({ "numToStr/Comment.nvim", keys = { "g", "<ESC>", "v", "V", "<c-v>" }, config = conf.comment })

  -- copy paste failed in block mode when clipboard = unnameplus"
  editor({
    "gbprod/yanky.nvim",
    event = { "CursorMoved", "TextYankPost" },
    keys = {
      "<Plug>(YankyPutAfter)",
      "<Plug>(YankyPutBefore)",
      "<Plug>(YankyGPutBefore)",
      "<Plug>(YankyGPutAfter)",
    },
    module = "yanky",
    opt = true,
    config = conf.yanky,
  })

  editor({ "dhruvasagar/vim-table-mode", cmd = { "TableModeToggle" } })

  -- fix terminal color
  editor({
    "norcalli/nvim-terminal.lua",
    opt = true,
    ft = { "log", "terminal" },
    config = function()
      require("terminal").setup()
    end,
  })

  editor({
    "simnalamburt/vim-mundo",
    opt = true,
    cmd = { "MundoToggle", "MundoShow", "MundoHide" },
    run = function()
      vim.cmd([[packadd vim-mundo]])
      vim.cmd([[UpdateRemotePlugins]])
    end,
    setup = function()
      -- body
      vim.g.mundo_prefer_python3 = 1
    end,
  })
  editor({ "mbbill/undotree", opt = true, cmd = { "UndotreeToggle" } })

  editor({
    "Wansmer/treesj",
    opt = true,
    cmd = { "TSJToggle", "TSJJoin", "TSJSplit" },
    keys = { "<space>j" },
    module = "treesj",
    config = function()
      require("treesj").setup({
        use_default_keymaps = false,
      })
    end,
  })

  editor({
    "chaoren/vim-wordmotion",
    opt = true,
    keys = { "<Plug>WordMotion_w", "<Plug>WordMotion_b" },
    -- keys = {'w','W', 'gE', 'aW'}
  })

  editor({
    "Pocco81/true-zen.nvim",
    opt = true,
    cmd = { "TZAtaraxis", "TZMinimalist", "TZNarrow", "TZFocus" },
    config = function()
      require("true-zen").setup({})
    end,
  })

  editor({
    "nvim-neorg/neorg",
    opt = true,
    config = conf.neorg,
    ft = "norg",
    requires = { "nvim-neorg/neorg-telescope", ft = { "norg" } },
  })

  editor({
    "nvim-orgmode/orgmode",
    opt = true,
    config = conf.orgmode,
    ft = "org",
    requires = {
      "akinsho/org-bullets.nvim",
      opt = true,
      config = function()
        require("org-bullets").setup()
      end,
    },
  })
  editor({
    "lukas-reineke/headlines.nvim",
    ft = { "org", "norg", "md" },
    config = conf.headline,
  })

  editor({ "hrsh7th/vim-searchx", event = { "CmdwinEnter", "CmdlineEnter" }, conf = conf.searchx })

  editor({
    "wellle/targets.vim",
    opt = true,
    event = { "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI" },
    setup = function() end,
  })

  editor({
    "AndrewRadev/switch.vim",
    opt = true,
    cmd = { "Switch", "Switch!", "Switch?", "SwitchCase", "SwitchCase!" },
    fn = { "switch#Switch" },
    keys = { "<Plug>(Switch)" },
    setup = function()
      vim.g.switch_mapping = "<Space>t"
    end,
  })
  editor({
    "mizlan/iswap.nvim",
    opt = true,
    cmd = { "ISwap", "ISwapWith", "ISwapNode", "ISwapNodeWith" },
    config = function()
      require("iswap").setup({})
    end,
  })
end
