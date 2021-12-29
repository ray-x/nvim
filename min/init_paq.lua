local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
vim.o.runtimepath = vim.o.runtimepath .. ",~/github/"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", install_path })
end

require("paq")({
  "savq/paq-nvim",
  "neovim/nvim-lspconfig",
  "nvim-treesitter/nvim-treesitter",
  "hrsh7th/nvim-cmp",
  "ray-x/lsp_signature.nvim",
  "ray-x/aurora",
  "ray-x/guihua.lua",
  "ray-x/navigator.lua",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  "windwp/nvim-autopairs",
  "jose-elias-alvarez/null-ls.nvim",
  'christoomey/vim-tmux-navigator'
})

local sumneko_root_path = vim.fn.expand("$HOME") .. "/github/sumneko/lua-language-server"
local sumneko_binary = vim.fn.expand("$HOME") .. "/github/sumneko/lua-language-server/bin/macOS/lua-language-server"

local lua_cfg = {
  cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
      diagnostics = { enable = true },
    },
  },
}
require("navigator").setup({
  debug = true,
  default_mapping = false,
  keymaps = { { mode = 'i', key = '<M-k>', func = 'signature_help()' },
{ key = "<c-i>", func = "signature_help()" } },
  lsp_signature_help = true,
  lsp = {
    sumneko_lua = lua_cfg,
  },
})

local cmp = require("cmp")
cmp.setup({
  mapping = {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require("luasnip").expand_or_jumpable() then
        require("luasnip").expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require("luasnip").jumpable(-1) then
        require("luasnip").jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  sources = { { name = "nvim_lsp" }, { name = "luasnip" } },
  completion = { completeopt = "menu,menuone,noinsert" },
  experimental = { ghost_text = true },
})

require("luasnip").config.set_config({ history = true, updateevents = "TextChanged,TextChangedI" })
require("luasnip.loaders.from_vscode").load()

require("nvim-autopairs").setup()
local cmp_autopairs = require("nvim-autopairs.completion.cmp")

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))

cmp_autopairs.lisp[#cmp_autopairs.lisp + 1] = "racket"

--- require("lsp_signature").setup()
vim.cmd([[set mouse=a]])

config = function()
  local null_ls = require("null-ls")
  local sources = {
    null_ls.builtins.diagnostics.revive,
    null_ls.builtins.formatting.prettier,
  }
  table.insert(sources, null_ls.builtins.diagnostics.staticcheck)
  local cfg = { sources = sources }
  null_ls.config(cfg)
  null_ls.config({ sources = sources })
end

vim.cmd([[set mouse=a]])
vim.cmd([[colorscheme aurora]])
config()
