local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
vim.o.runtimepath = vim.o.runtimepath .. ",~/github/"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", install_path })
end

require("paq")({
  "savq/paq-nvim", -- Let Paq manage itself
  "neovim/nvim-lspconfig", -- Mind the semi-colons
  "hrsh7th/nvim-cmp", -- Use braces when passing options
  "lsp_signature.nvim",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  "windwp/nvim-autopairs",
  "jose-elias-alvarez/null-ls.nvim",
})
vim.cmd([[colorscheme darkblue]])

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
  capabilities = capabilities,
}

require("lsp_signature").setup()

require("lspconfig").sumneko_lua.setup(lua_cfg)
require("lspconfig").gopls.setup({ capabilities = capabilities })
vim.cmd([[set mouse=a]])

config = function()
  local null_ls = require("null-ls")
  local lspconfig = require("lspconfig")

  local sources = {
    null_ls.builtins.formatting.autopep8,
    null_ls.builtins.formatting.rustfmt,
    null_ls.builtins.diagnostics.yamllint,
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.code_actions.proselint,
    null_ls.builtins.code_actions.refactoring,
    null_ls.builtins.diagnostics.staticcheck,
    null_ls.builtins.diagnostics.revive,
    null_ls.builtins.formatting.prettier,
  }

  local function exist(bin)
    return vim.fn.exepath(bin) ~= ""
  end

  table.insert(
    sources,
    null_ls.builtins.formatting.golines.with({
      extra_args = {
        "--max-len=120",
        "--base-formatter=gofumpt",
      },
    })
  )

  -- shell script
  if exist("shellcheck") then
    table.insert(sources, null_ls.builtins.diagnostics.shellcheck)
  end

  -- shell script
  if exist("shfmt") then
    table.insert(sources, null_ls.builtins.formatting.shfmt)
  end

  -- golang
  if exist("golangci-lint") then
    table.insert(sources, null_ls.builtins.diagnostics.golangci_lint)
  end
  table.insert(sources, null_ls.builtins.diagnostics.staticcheck)
  table.insert(sources, null_ls.builtins.diagnostics.revive)

  -- docker
  if exist("hadolint") then
    table.insert(sources, null_ls.builtins.diagnostics.hadolint)
  end

  if exist("eslint_d") then
    table.insert(sources, null_ls.builtins.diagnostics.eslint_d)
  end
  -- js, ts
  if exist("prettierd") then
    table.insert(sources, null_ls.builtins.formatting.prettierd)
  end
  -- lua
  if exist("selene") then
    table.insert(sources, null_ls.builtins.diagnostics.selene)
  end

  if exist("stylua") then
    table.insert(
      sources,
      null_ls.builtins.formatting.stylua.with({
        extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
      })
    )
  end

  table.insert(sources, null_ls.builtins.formatting.trim_newlines)
  table.insert(sources, null_ls.builtins.formatting.trim_whitespace)

  local cfg = { sources = sources }
  -- if plugin_debug() then
  --   cfg.debug = true
  -- end

  null_ls.config(cfg)

  if lspconfig["null-ls"] then
    lspconfig["null-ls"].setup({
      on_attach = function(client, bufnr)
        if client.resolved_capabilities.document_formatting then
          vim.cmd([[
					augroup null_ls_format
						au!
						au BufWritePost <buffer> lua vim.lsp.buf.formatting_sync()
					augroup end
				]])
        end
      end,
    })
  end

  null_ls.config({ sources = sources })
end

config()
