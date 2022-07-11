local editor = {}

local conf = require("modules.editor.config")

-- alternatives: steelsojka/pears.nvim
-- windwp/nvim-ts-autotag  'html', 'javascript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue'
-- windwp/nvim-autopairs

editor["windwp/nvim-autopairs"] = {
  -- keys = {{'i', '('}},
  -- keys = {{'i'}},
  after = { "nvim-cmp" }, -- "nvim-treesitter", nvim-cmp "nvim-treesitter", coq_nvim
  -- event = "InsertEnter",  --InsertCharPre
  -- after = "hrsh7th/nvim-compe",
  config = conf.autopairs,
  opt = true,
}

editor["anuvyklack/hydra.nvim"] = {
  requires = "anuvyklack/keymap-layer.nvim",
  -- event = { "CmdwinEnter", "CmdlineEnter", "CursorMoved" },
  config = conf.hydra,
  opt = true,
}

editor["gbprod/substitute.nvim"] = {
  event = { "CursorMoved", "CursorMovedI", "CmdlineEnter" },
  config = conf.substitute,
  opt = true,
}

editor["tpope/vim-abolish"] = {
  event = { "CmdlineEnter" },
  opt = true,
}

-- I like this plugin, but 1) offscreen context is slow
-- 2) it not friendly to lazyload and treesitter startup
-- editor["andymass/vim-matchup"] = {
--   opt = true,
--   event = {"CursorMoved", "CursorMovedI"},
--   cmd = {'MatchupWhereAmI?'},
--   config = function()
--     vim.g.matchup_enabled = 1
--     vim.g.matchup_surround_enabled = 1
--     -- vim.g.matchup_transmute_enabled = 1
--     vim.g.matchup_matchparen_deferred = 1
--     vim.g.matchup_matchparen_offscreen = {method = 'popup'}
--     vim.cmd([[nnoremap <c-s-k> :<c-u>MatchupWhereAmI?<cr>]])
--   end
-- }

-- Feel more comfortable with hop
-- editor["ggandor/lightspeed.nvim"] = {
--   as = "lightspeed",
--   opt = true,
--   keys = {'f', 'F', 't', 'T', 'S', 's'},
--   config = conf.lightspeed
-- }

-- editor["tpope/vim-surround"] = {
--   opt = true,
--   event = { "InsertEnter", "CursorMoved", "CursorMovedI" },
--   -- keys={'c', 'd'}
-- }
--
editor["machakann/vim-sandwich"] = {
  opt = true,
  event = { "CursorMoved", "CursorMovedI" },
  setup = function()
    vim.g.sandwich_no_default_key_mappings = 1
    vim.cmd[[
  nmap za <Plug>(sandwich-add)
	xmap za <Plug>(sandwich-add)
	omap za <Plug>(sandwich-add)
	nmap zd <Plug>(sandwich-delete)
	xmap zd <Plug>(sandwich-delete)
	nmap zdb <Plug>(sandwich-delete-auto)
	nmap zr <Plug>(sandwich-replace)
	xmap zr <Plug>(sandwich-replace)
	nmap zrb <Plug>(sandwich-replace-auto)
  omap ib <Plug>(textobj-sandwich-auto-i)
	xmap ib <Plug>(textobj-sandwich-auto-i)
	omap ab <Plug>(textobj-sandwich-auto-a)
	xmap ab <Plug>(textobj-sandwich-auto-a)
	omap is <Plug>(textobj-sandwich-query-i)
	xmap is <Plug>(textobj-sandwich-query-i)
	omap as <Plug>(textobj-sandwich-query-a)
	xmap as <Plug>(textobj-sandwich-query-a)
    ]]
  end,
}

-- nvim-colorizer replacement
editor["rrethy/vim-hexokinase"] = {
  -- ft = { 'html','css','sass','vim','typescript','typescriptreact'},
  config = conf.hexokinase,
  run = "make hexokinase",
  opt = true,
  cmd = { "HexokinaseTurnOn", "HexokinaseToggle" },
}

editor["chrisbra/Colorizer"] = {
  ft = { "log", "txt", "text" },
  opt = true,
  cmd = { "ColorHighlight", "ColorUnhighlight" },
}

-- booperlv/nvim-gomove
-- <A-k>   Move current line/selection up
-- <A-j>   Move current line/selection down
-- <A-h>   Move current character/selection left
-- <A-l>   Move current character/selection right

editor["booperlv/nvim-gomove"] = {

  event = { "CursorMoved", "CursorMovedI" },
  config = conf.move,
}

-- Great plugin.
-- editor["kevinhwang91/nvim-hlslens"] = {
--   -- keys = {"/", "?", '*', '#'}, --'n', 'N', '*', '#', 'g'
--   -- opt = true,
--   -- config = conf.hlslens
-- }

editor["kevinhwang91/nvim-ufo"] = {
  opt = true,
  ft = { "c" },
  requires = { "kevinhwang91/promise-async" },
  config = conf.ufo,
}

editor["mg979/vim-visual-multi"] = {
  keys = {
    "<Ctrl>",
    "<M>",
    "<C-n>",
    "<C-n>",
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
    "<Leader>",
  },
  opt = true,
  setup = conf.vmulti,
}

editor["indianboy42/hop-extensions"] = { after = "hop", opt = true }

-- EasyMotion in lua. -- maybe replace sneak
editor["phaazon/hop.nvim"] = {
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
}

editor["numToStr/Comment.nvim"] = {
  keys = { "g", "<ESC>" },
  event = { "CursorMoved" },
  config = conf.comment,
}

-- copy paste failed in block mode when clipboard = unnameplus"
-- editor["bfredl/nvim-miniyank"] = {
--   keys = { "p", "y", "<C-v>" },
--   opt = true,
--   setup = function()
--     vim.api.nvim_command("map p <Plug>(miniyank-autoput)")
--     vim.api.nvim_command("map P <Plug>(miniyank-autoPut)")
--   end,
-- }
editor["gbprod/yanky.nvim"] = {
  event = { "CursorMoved", "CursorMovedI" },
  opt = true,
  setup = function()
    vim.keymap.set("n", "p", "<Plug>(YankyPutAfter)", {})
    vim.keymap.set("n", "P", "<Plug>(YankyPutBefore)", {})
    vim.keymap.set("x", "p", "<Plug>(YankyPutAfter)", {})
    vim.keymap.set("x", "P", "<Plug>(YankyPutBefore)", {})
    -- vim.keymap.set("n", "gp", "<Plug>(YankyGPutAfter)", {})
    vim.keymap.set("n", "gP", "<Plug>(YankyGPutBefore)", {})
    vim.keymap.set("x", "gp", "<Plug>(YankyGPutAfter)", {})
    vim.keymap.set("x", "gP", "<Plug>(YankyGPutBefore)", {})
  end,
  config = conf.yanky,
}

editor["dhruvasagar/vim-table-mode"] = { cmd = { "TableModeToggle" } }

-- fix terminal color
editor["norcalli/nvim-terminal.lua"] = {
  opt = true,
  ft = { "log", "terminal" },
  config = function()
    require("terminal").setup()
  end,
}

editor["simnalamburt/vim-mundo"] = {
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
}
editor["mbbill/undotree"] = { opt = true, cmd = { "UndotreeToggle" } }
editor["AndrewRadev/splitjoin.vim"] = {
  opt = true,
  cmd = { "SplitjoinJoin", "SplitjoinSplit" },
  setup = function()
    vim.g.splitjoin_split_mapping = ""
    vim.g.splitjoin_join_mapping = ""
  end,
  -- keys = {'<space>S', '<space>J'}
}

editor["chaoren/vim-wordmotion"] = {
  opt = true,
  fn = { "<Plug>WordMotion_w" },
  -- keys = {'w','W', 'gE', 'aW'}
}

editor["folke/zen-mode.nvim"] = {
  opt = true,
  cmd = { "ZenMode" },
  config = function()
    require("zen-mode").setup({})
  end,
}

editor["nvim-neorg/neorg"] = {
  opt = true,
  config = conf.neorg,
  ft = "norg",
  after = { "nvim-treesitter" },
  setup = vim.cmd("autocmd BufRead,BufNewFile *.norg setlocal filetype=norg"),
  requires = { "nvim-neorg/neorg-telescope", ft = { "norg" } },
}

editor["hrsh7th/vim-searchx"] = {
  event = { "CmdwinEnter", "CmdlineEnter" },
  conf = conf.searchx,
}

return editor
