local completion = {}
local conf = require("modules.completion.config")

completion["neovim/nvim-lspconfig"] = {
  -- event = 'BufRead',
  -- ft = {'html','css', 'javascript', 'java', 'javascriptreact', 'vue','typescript', 'typescriptreact', 'go', 'lua', 'cpp', 'c',
  -- 'markdown', 'makefile','python','bash', 'sh', 'php', 'yaml', 'json', 'sql', 'vim', 'sh'},
  config = conf.nvim_lsp,
  -- event = 'CursorHold',
  opt = true
}

completion["ms-jpq/coq_nvim"] = {
  opt = true,
  -- event = "InsertEnter",
  branch = 'coq',
  config = function()
    vim.cmd([[COQnow -s]])
  end
}

completion["ms-jpq/coq.artifacts"] = {
  opt = true,
  -- event = "InsertEnter",
  -- event = "InsertEnter",
  branch = 'artifacts',
}


-- completion["hrsh7th/nvim-compe"] = {
--   event = "InsertEnter",
--   config = conf.nvim_compe
-- }
-- loading sequence LuaSnip -> nvim-cmp -> cmp_luasnip -> cmp-nvim-lua -> cmp-nvim-lsp ->cmp-buffer -> friendly-snippets
-- too many bugs saddly not as good as compe
completion["hrsh7th/nvim-cmp"] = {
  -- opt=true,
  event = "InsertCharPre",   --InsertCharPre
  after = "LuaSnip",
  requires = {
    {"hrsh7th/cmp-buffer", after = "nvim-cmp" , opt=true},
    {"hrsh7th/cmp-nvim-lua", after = "nvim-cmp", opt=true },
    {"hrsh7th/cmp-vsnip", after = "nvim-cmp", opt=true },
    {"hrsh7th/cmp-calc", after = "nvim-cmp", opt=true },
    {"hrsh7th/cmp-path", after = "nvim-cmp", opt=true },
    {"hrsh7th/cmp-nvim-lsp", after = "nvim-cmp", opt=true },
    {"f3fora/cmp-spell", after = "nvim-cmp", opt=true },
    -- {"quangnguyen30192/cmp-nvim-ultisnips", event = "InsertCharPre", after = "nvim-cmp", opt=true },
    {"saadparwaiz1/cmp_luasnip", after = {"nvim-cmp", "LuaSnip"}},
    {"tzachar/cmp-tabnine", opt=true},
  },
  config = conf.nvim_cmp
}


-- can not lazyload, it is also slow...
completion["L3MON4D3/LuaSnip"] = { -- need to be the first to load
  event = "InsertEnter",
  requires = {"rafamadriz/friendly-snippets", event = "InsertEnter"}, --, event = "InsertEnter"
  config = conf.luasnip
}



-- completion["SirVer/ultisnips"] = {
--   opt = true,
--   -- event = "InsertEnter",
--   requires = {"honza/vim-snippets",opt = true, }, --event = "InsertEnter"
--   -- after = "vim-snippets",
-- }


completion["nvim-telescope/telescope.nvim"] = {
  cmd = "Telescope",
  config = conf.telescope,
  setup = conf.telescope_preload,
  requires = {
    {"nvim-lua/popup.nvim", opt = true},
    {"nvim-lua/plenary.nvim", opt = true},
    {"nvim-telescope/telescope-fzy-native.nvim", opt = true}
  },
  opt = true
}

completion["mattn/emmet-vim"] = {
  event = "InsertEnter",
  ft = {"html", "css", "javascript", "javascriptreact", "vue", "typescript", "typescriptreact"},
  setup = conf.emmet
}

-- note: part of the code is used in navigator
completion[vim.fn.expand("$HOME") .. "/github/lsp_signature.nvim"] = {
  opt = false,
  config = function()
    require "lsp_signature".setup({
        toggle_key = [[<M-x>]],
        floating_window = true,
        log_path = vim.fn.expand("$HOME")  .. "/tmp/sig.log",
        debug = true,
        hi_parameter = 'Search',
        bind = true,
        handler_opts = {
          border = 'single', --"shadow", --{"╭", "─" ,"╮", "│", "╯", "─", "╰", "│" },
        },
      })
  end
}
-- completion['ray-x/lsp_signature.nvim'] = {
--   config = function() require "lsp_signature".on_attach() end
-- }

return completion
