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

completion["glepnir/lspsaga.nvim"] = {
  cmd = "Lspsaga"
}

completion["hrsh7th/nvim-compe"] = {
  event = "InsertEnter",
  config = conf.nvim_compe
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

-- completion['RRethy/vim-illuminate'] = {
--   event = 'InsertEnter',
--   config = function()
--     vim.g.Illuminate_delay = 200
--     vim.g.Illuminate_ftblacklist = {'nerdtree', 'nvimtree', 'vista'}
--     vim.api.nvim_set_keymap('n', '<a-n>', '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>', {noremap=true})
--     vim.api.nvim_set_keymap('n', '<a-p>', '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>', {noremap=true})
--   end
-- }
-- enable for workstation....
-- completion['tzachar/compe-tabnine'] = {
--   event = 'InsertEnter',
--   run = './install.sh',
--   opt=true,
-- }
-- completion['nvim-lua/lsp-status.nvim'] = {
--   opt=true,
-- }

-- note: part of the code is used in navigator
completion["/Users/ray.xu/github/lsp_signature.nvim"] = {
  opt = false,
  config = function()
    require "lsp_signature".setup({
        floating_window = true,
        log_path = "/Users/ray.xu/tmp/sig.log",
        debug = true,
        hi_parameter = 'Search',
        bind = true,
        handler_opts = {
          border = {"╭", "─" ,"╮", "│", "╯", "─", "╰", "│" },
        },
      })
  end
}
-- completion['ray-x/lsp_signature.nvim'] = {
--   config = function() require "lsp_signature".on_attach() end
-- }

return completion
