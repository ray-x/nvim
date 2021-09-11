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
  -- opt = true,
  -- ft = {'html','css', 'javascript', 'java', 'typescript', 'typescriptreact','go', 'python', 'cpp', 'c', 'rust'},
  -- event = "InsertCharPre",
  after = {"coq.artifacts"},
  branch = 'coq',
  setup = function()
    vim.g.coq_settings = { auto_start = false }
  end,
  config = function()
    if not load_coq() then return end
    vim.g.coq_settings = {['display.icons.mode'] = 'short', ['display.pum.kind_context'] = {'',''}, ['display.pum.source_context'] = {'',''} }
    if vim.o.ft ~= 'lua' and vim.o.ft ~= 'sql' and vim.o.ft ~= 'vim'then
      vim.cmd([[COQnow]])
    end
  end
}

completion["ms-jpq/coq.artifacts"] = {
  -- opt = true,
  event = "InsertEnter",
  branch = 'artifacts'
}

-- loading sequence LuaSnip -> nvim-cmp -> cmp_luasnip -> cmp-nvim-lua -> cmp-nvim-lsp ->cmp-buffer -> friendly-snippets
completion["hrsh7th/nvim-cmp"] = {
  -- opt = true,
  -- event = "InsertEnter", -- InsertCharPre
  -- ft = {'lua', 'markdown',  'yaml', 'json', 'sql', 'vim', 'sh', 'sql', 'vim', 'sh'},
  after = {"LuaSnip"}, -- "nvim-snippy",
  requires = {
    {"hrsh7th/cmp-buffer", after = "nvim-cmp", opt = true},
    {"hrsh7th/cmp-nvim-lua", after = "nvim-cmp", opt = true},
    -- {"hrsh7th/cmp-vsnip", after = "nvim-cmp", opt = true},
    {"hrsh7th/cmp-calc", after = "nvim-cmp", opt = true},
    {"hrsh7th/cmp-path", after = "nvim-cmp", opt = true},
    {vim.fn.expand('$HOME') .. "/github/cmp-treesitter", after = "nvim-cmp", opt = true},
    {"hrsh7th/cmp-nvim-lsp", after = "nvim-cmp", opt = true},
    {"f3fora/cmp-spell", after = "nvim-cmp", opt = true},
    {"octaltree/cmp-look", after = "nvim-cmp", opt = true},
    -- {"dcampos/cmp-snippy",after = {"nvim-snippy", "nvim-cmp"}},
    -- {"quangnguyen30192/cmp-nvim-ultisnips", event = "InsertCharPre", after = "nvim-cmp", opt=true },
    {"saadparwaiz1/cmp_luasnip", after = {"nvim-cmp", "LuaSnip"}},
    -- {"tzachar/cmp-tabnine", opt = true}
  },
  config = conf.nvim_cmp
}

-- can not lazyload, it is also slow...
completion["L3MON4D3/LuaSnip"] = { -- need to be the first to load
  event = "InsertEnter",
  requires = {"rafamadriz/friendly-snippets", event = "InsertEnter"}, -- , event = "InsertEnter"
  config = conf.luasnip
}
completion["kristijanhusak/vim-dadbod-completion"] = {
  event = "InsertEnter",
  ft = {'sql'},
  setup = function()
    vim.cmd([[autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni]])
    -- vim.cmd([[autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })]])
    -- body
  end
}

completion["dcampos/nvim-snippy"] = {
  opt = true,
  -- event = "InsertEnter",
  -- requires = {"honza/vim-snippets", event = "InsertEnter"}, --event = "InsertEnter"
  config = function()
    require'snippy'.setup {}
    -- body
    -- vim.cmd([[imap <expr> <Tab> snippy#can_expand_or_advance() ? '<Plug>(snippy-expand-or-next)' : '<Tab>']])
    -- vim.cmd([[imap <expr> <S-Tab> snippy#can_jump(-1) ? '<Plug>(snippy-previous)' : '<Tab>']])
    -- vim.cmd([[smap <expr> <Tab> snippy#can_jump(1) ? '<Plug>(snippy-next)' : '<Tab>']])
    -- vim.cmd([[smap <expr> <S-Tab> snippy#can_jump(-1) ? '<Plug>(snippy-previous)' : '<Tab>']])
  end
  -- after = "vim-snippets"
}

completion["nvim-telescope/telescope.nvim"] = {
  cmd = "Telescope",
  config = conf.telescope,
  setup = conf.telescope_preload,
  requires = {
    {"nvim-lua/popup.nvim", opt = true}, {"nvim-lua/plenary.nvim", opt = true},
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
  config = function()
    require"lsp_signature".setup({
      toggle_key = [[<M-x>]],
      doc_lines = 4,
      floating_window = true,
      floating_window_above_cur_line = true,
      log_path = vim.fn.expand("$HOME") .. "/tmp/sig.log",
      debug = true,
      verbose = true,
      hi_parameter = 'Search',
      bind = true,
      handler_opts = {
        border = 'single' -- "shadow", --{"╭", "─" ,"╮", "│", "╯", "─", "╰", "│" },
      }
    })
  end
}
-- completion['ray-x/lsp_signature.nvim'] = {
--   config = function() require "lsp_signature".on_attach() end
-- }

return completion
