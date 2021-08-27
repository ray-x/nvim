local editor = {}

local conf = require("modules.editor.config")

-- alternatives: steelsojka/pears.nvim
-- windwp/nvim-ts-autotag  'html', 'javascript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue'
-- windwp/nvim-autopairs

editor["windwp/nvim-autopairs"] = {
  -- keys = {{'i', '('}},
  -- keys = {{'i'}},
  -- after = "nvim-treesitter", "nvim-cmp",
  event = "InsertCharPre",
  -- after = "hrsh7th/nvim-compe",
  -- event = 'InsertEnter',  -- not working!
  config = conf.autopairs,
  opt = true
}

editor["andymass/vim-matchup"] = {
  event = {"CursorMoved", "CursorMovedI"},
  config = function()
    vim.g.matchup_enabled = 1
    vim.g.matchup_surround_enabled = 1
    -- vim.g.matchup_transmute_enabled = 1
    vim.g.matchup_matchparen_deferred = 1
    vim.g.matchup_matchparen_offscreen = {method = 'popup'}

  end
}

-- editor["ggandor/lightspeed.nvim"] = {
--   as = "lightspeed",
--   keys = {'f', 'F', 'S', 's', 't', 'T'},
--   config = function()
--     -- you can configure Hop the way you like here; see :h hop-config
--     require"lightspeed".setup {
--       jump_to_first_match = true,
--       jump_on_partial_input_safety_timeout = 400,
--       -- This can get _really_ slow if the window has a lot of content,
--       -- turn it on only if your machine can always cope with it.
--       highlight_unique_chars = false,
--       grey_out_search_area = true,
--       match_only_the_start_of_same_char_seqs = true,
--       limit_ft_matches = 5,
--       full_inclusive_prefix_key = '<c-x>',
--       -- By default, the values of these will be decided at runtime,
--       -- based on `jump_to_first_match`.
--       labels = nil,
--       cycle_group_fwd_key = nil,
--       cycle_group_bwd_key = nil
--     }
--     -- vim.api.nvim_set_keymap('n', '$', "<cmd>lua require'hop'.hint_words()<cr>", {})
--   end
-- }

editor["tpope/vim-surround"] = {
  opt = true
  -- event = 'InsertEnter',
  -- keys={'c', 'd'}
}

-- nvim-colorizer replacement
editor["rrethy/vim-hexokinase"] = {
  -- ft = { 'html','css','sass','vim','typescript','typescriptreact'},
  config = conf.hexokinase,
  run = "make hexokinase",
  opt = true,
  cmd = {"HexokinaseTurnOn", "HexokinaseToggle"}
}

-- <A-k>   Move current line/selection up
-- <A-j>   Move current line/selection down
-- <A-h>   Move current character/selection left
-- <A-l>   Move current character/selection right
editor["matze/vim-move"] = {
  opt = true,
  event = "InsertEnter"
  -- fn = {'<Plug>MoveBlockDown', '<Plug>MoveBlockUp', '<Plug>MoveLineDown', '<Plug>MoveLineUp'}
}

-- editor["kevinhwang91/nvim-hlslens"] = {
--   -- keys = {"/", "?", '*', '#'}, --'n', 'N', '*', '#', 'g'
--   -- opt = true,
--   -- config = conf.hlslens
-- }

editor["mg979/vim-visual-multi"] = {
  keys = {
    "<C-n>", "<C-n>", "<M-n>", "<S-Down>", "<S-Up>", "<M-Left>", "<M-Right>", "<M-D>", "<M-Down>",
    "<C-d>", "<C-Down>", "<S-Right>", "<C-LeftMouse>", "<M-C-RightMouse>", "<Leader>"
  },
  opt = true,
  setup = conf.vmulti
}
-- EasyMotion in lua. -- maybe replace sneak
editor["phaazon/hop.nvim"] = {
  as = "hop",
  cmd = {
    "HopWord", "HopWordAC", "HopWordBC", "HopLine", "HopChar1", "HopChar1AC", "HopChar1BC",
    "HopChar2", "HopChar2AC", "HopChar2BC", "HopPattern", "HopPatternAC", "HopPatternBC"
  },
  config = function()
    -- you can configure Hop the way you like here; see :h hop-config
    require"hop".setup {keys = "adghklqwertyuiopzxcvbnmfjADHKLWERTYUIOPZXCVBNMFJ1234567890"}
    -- vim.api.nvim_set_keymap('n', '$', "<cmd>lua require'hop'.hint_words()<cr>", {})
  end
}

editor["preservim/nerdcommenter"] = {
  --- cmd = {'NERDCommenterComment', 'NERDCommenterToggle', 'NERDCommenterNested', 'NERDCommenterInvert', 'NERDCommenterSexy'},
  keys = {"<Leader>c<space>", "\\c ", "<C-<Space>>", "<Leader>cc", "//", "<M-/>"},
  -- keys = {'<Leader>c<space>', '\\c ', '<Leader>cc', '//', '<M-/>'},
  setup = conf.nerdcommenter,
  fn = {"NERDComment"}
  -- opt = true,
}
-- copy paste failed in block mode when clipboard = unnameplus"
editor["bfredl/nvim-miniyank"] = {
  keys = {"p", "y", "<C-v>"},
  opt = true,
  setup = function()
    vim.api.nvim_command("map p <Plug>(miniyank-autoput)")
    vim.api.nvim_command("map P <Plug>(miniyank-autoPut)")
  end
}

editor['dhruvasagar/vim-table-mode'] = {cmd = {'TableModeToggle'}}

-- fix terminal color
editor["norcalli/nvim-terminal.lua"] = {
  opt = true,
  ft = {"log", "terminal"},
  config = function()
    require"terminal".setup()
  end
}

-- python3 support is flaky
-- editor['simnalamburt/vim-mundo']  = { opt = true, cmd ={'MundoToggle', 'MundoShow', 'MundoHide'},
-- setup = function ()
--   -- body
--   vim.g.mundo_prefer_python3=1
-- end
-- }
editor["mbbill/undotree"] = {opt = true, cmd = {"UndotreeToggle"}}
editor["AndrewRadev/splitjoin.vim"] = {
  opt = true,
  cmd = {"SplitjoinJoin", "SplitjoinSplit"},
  setup = function()
    vim.g.splitjoin_split_mapping = ""
    vim.g.splitjoin_join_mapping = ""
  end
  -- keys = {'<space>S', '<space>J'}
}
-- editor['justinmk/vim-sneak']  = {opt = true, keys = {'s'}, config = function() vim.g['sneak#label']= 1 end}
editor["chaoren/vim-wordmotion"] = {
  opt = true,
  fn = {"<Plug>WordMotion_w"}
  -- keys = {'w','W', 'gE', 'aW'}
}

return editor
