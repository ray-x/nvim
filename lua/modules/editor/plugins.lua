local editor = {}

local conf = require("modules.editor.config")

-- editor['Raimondi/delimitMate'] = {
--   event = 'InsertEnter',
--   config = conf.delimimate,
-- }

-- alternatives: steelsojka/pears.nvim
-- windwp/nvim-ts-autotag  'html', 'javascript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue'
-- windwp/nvim-autopairs

editor["windwp/nvim-autopairs"] = {
  -- keys = {{'i', '('}},
  -- keys = {{'i'}},
  -- after = "nvim-treesitter",
  event = "InsertEnter",
  -- event = 'InsertEnter',  -- not working!
  config = conf.autopairs,
  opt = true
}


-- editor["ggandor/lightspeed.nvim"] ={}
editor["tpope/vim-surround"] = {
  opt = true
  --event = 'InsertEnter',
  --keys={'c', 'd'}
}

-- editor['steelsojka/pears.nvim'] = {
--   -- keys = {{'(','[', '<', '{'}},
--   event = 'InsertEnter',
--   config =  conf.pears_setup(),
--   opt = true
-- }

-- editor['/Users/ray.xu/github/pears.nvim'] = {
--   -- keys = {{'(','[', '<', '{'}},
--   -- event = 'InsertEnter',
--   config =  conf.pears_setup(),
--   -- opt=true
-- }

-- nvim-colorizer replacement
editor["rrethy/vim-hexokinase"] = {
  -- ft = { 'html','css','sass','vim','typescript','typescriptreact'},
  config = conf.hexokinase,
  run = "make hexokinase",
  opt = true,
  cmd = {"HexokinaseTurnOn", "HexokinaseToggle"}
}

editor['nacro90/numb.nvim'] = {
  event = {"CmdlineEnter"},
  config = function () 
    require('numb').setup{
      show_numbers = true, -- Enable 'number' for the window while peeking
      show_cursorline = true -- Enable 'cursorline' for the window while peeking
    }
  end
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

-- editor['hrsh7th/vim-eft'] = {
--   opt = true,
--   config = function()
--     vim.g.eft_ignorecase = true
--   end
-- }

-- editor['kana/vim-operator-replace'] = {
--   keys = {{'x','p'}},
--   config = function()
--     vim.api.nvim_set_keymap("x", "p", "<Plug>(operator-replace)",{silent =true})
--   end,
--   requires = 'kana/vim-operator-user'
-- }

editor["kevinhwang91/nvim-hlslens"] = {
  keys = {"/", "?", '*', '#'}, --'n', 'N', '*', '#', 'g'
  opt = true,
  config = conf.hlslens
}

editor["mg979/vim-visual-multi"] = {
  keys = {
    "<C-n>",
    "<C-n>",
    "<M-n>",
    "<S-Down>",
    "<S-Up>",
    "<M-Left>",
    "<M-Right>",
    "<M-D>",
    "<M-Down>",
    "<C-d>",
    "<C-Down>",
    "<S-Right>",
    "<C-LeftMouse>",
    "<M-C-RightMouse>",
    "<Leader>"
  },
  opt = true,
  setup = conf.vmulti
}
-- EasyMotion in lua. -- maybe replace sneak
editor["phaazon/hop.nvim"] = {
  as = "hop",
  cmd = {"HopWord", "HopLine", "HopChar1", "HopChar1AC", "HopChar1BC", "HopChar2AC","HopChar2BC", "HopPatternAC", "HopPatternBC"},
  config = function()
    -- you can configure Hop the way you like here; see :h hop-config
    require "hop".setup {keys = "asdghklqwertyuiopzxcvbnmfjASDGHKLQWERTYUIOPZXCVBNMFJ1234567890[]"}
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

editor['dhruvasagar/vim-table-mode'] = {
  cmd = {'TableModeToggle'}
}


-- fix terminal color
editor["norcalli/nvim-terminal.lua"] = {
  opt = true,
  ft = {"log", "terminal"},
  config = function()
    require "terminal".setup()
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

-- chaoren/vim-wordmotion
return editor
