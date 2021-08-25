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

-- completion["hrsh7th/nvim-compe"] = {
--   event = "InsertEnter",
--   config = conf.nvim_compe
-- }


completion["hrsh7th/nvim-cmp"] = {
  -- opt=true,
  -- event = "InsertEnter",   --InsertCharPre
  requires = {
    {"hrsh7th/cmp-buffer", after = "nvim-cmp" },
    {"hrsh7th/cmp-nvim-lua", after = "nvim-cmp" },
    {"hrsh7th/cmp-vsnip", after = "nvim-cmp" },
    {"hrsh7th/cmp-calc", after = "nvim-cmp" },
    {"hrsh7th/cmp-path", after = "nvim-cmp" },
    {"hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" },
    {"tzachar/cmp-tabnine", opt=true},
  },
  config = conf.nvim_cmp
}

completion["hrsh7th/vim-vsnip"] = {
  event = "InsertEnter",
  requires = {"rafamadriz/friendly-snippets", opt = true, event = "InsertEnter"},
  setup = conf.vim_vsnip
  -- after = "hrsh7th/nvim-compe",
}
-- completion["pierreglaser/folding-nvim"] = {}
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
