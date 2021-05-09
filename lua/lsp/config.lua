local lspconfig = require "lspconfig"
local lsp = require("vim.lsp")
--
-- vim.cmd [[packadd lspsaga.nvim]]
-- local saga = require "lspsaga"
-- saga.init_lsp_saga()

-- vim.cmd [[packadd navigator.lua]]
-- local navigator = require "navigator"
-- navigator.setup()
-- M={}
--
--
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
--
-- function M.reload_lsp()
--   vim.lsp.stop_client(vim.lsp.get_active_clients())
--   vim.cmd [[edit]]
-- end
--
-- function M.open_lsp_log()
--   local path = vim.lsp.get_log_path()
--   vim.cmd("edit " .. path)
-- end
--
-- vim.cmd("command! -nargs=0 LspLog call v:lua.open_lsp_log()")
-- vim.cmd("command! -nargs=0 LspRestart call v:lua.reload_lsp()")
--
-- print("loading lsp client")
-- local cfg = {}
-- require('lsp.clients').setup(cfg)
-- require('lsp.mappings').setup(cfg)
-- return M

local stylelint = {
  lintCommand = "stylelint --stdin --stdin-filename ${INPUT} --formatter compact",
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = {
    "%f: line %l, col %c, %tarning - %m",
    "%f: line %l, col %c, %trror - %m"
  },
  formatCommand = "stylelint --fix --stdin --stdin-filename ${INPUT}",
  formatStdin = true
}
local prettier = {
  formatCommand = "./node_modules/.bin/prettier --stdin-filepath ${INPUT}",
  formatStdin = true
}

local eslint_d = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true
}
local rustfmt = {
  formatCommand = "rustfmt",
  formatStdin = true
}
---  , '-c', '/Users/ray.xu/.config/efm-langserver/config.yaml'
-- require'lspconfig'.efm.setup {
--   cmd = { 'efm-langserver'},
--   init_options = {
--     documentFormatting = true,
--     rename = false,
--     hover = true,
--     codeAction = true,
--     completion = false,
--   },
--   on_attach = function(client)
--     client.resolved_capabilities.document_formatting = true
--     client.resolved_capabilities.goto_definition = false
--     -- set_lsp_config(client)
--   end,
--   filetypes = { "javascript", "javascriptreact", 'typescript', 'typescriptreact', 'lua', 'go' },
--   settings = {
--     rootMarkers = { '.git', 'package.json' },
--     languages = {
--       typescript = { {stylelint} , prettier },
--       typescriptreact = { stylelint, prettier },
--       lua = { {formatCommand = "lua-format --tab-width=2 -i", formatStdin = true}},
--       go = { {formatCommand = "golines --max-len=120  --base-formatter=gofumpt", formatStdin = true} },
--       javascript = {eslint_d},
--       javascriptreact = {eslint_d},
--      -- python = { python-flake8 },
--     },
--   },
-- }

-- require "lspconfig".efm.setup {
--   cmd = { 'efm-langserver', '-loglevel', '10'},
--   init_options = {documentFormatting = true},
--   settings = {
--     rootMarkers = {".git/", 'package.json', 'Makefile'},
--     languages = {
--       typescript = { stylelint , prettier },
--       typescriptreact = { stylelint, prettier },
--       javascript = {eslint_d},
--       javascriptreact = {eslint_d},
--       go = { {formatCommand = "golines --max-len=120  --base-formatter=gofumpt", formatStdin = true} },
--       lua = {
--         {formatCommand = "luafmt --indent-count 2 --stdin", formatStdin = true,
--          lintCommand = "luacheck --formatter plain --codes --filename %s -", formatStdin = true,
--          lintStdin = true,
--          lintFormats = {"%f:%l:%c: %m"},
--          lintIgnoreExitCode = true,
--         }
--       },
--     }
--   }
-- }
-- require'lspconfig'.stylelint_lsp.setup{stylelint
--   settings = {
--     stylelintplus = {
--       -- see available options in stylelint-lsp documentation
--     }
--   }
-- }

if not lspconfig.golangcilsp then
  lspconfig.golangcilsp = {
    default_config = {
      cmd = {"golangci-lint-langserver"},
      root_dir = lspconfig.util.root_pattern(".git", "go.mod"),
      init_options = {
        command = {"golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json"}
      }
    }
  }
end

-- local lspconfig = require 'lspconfig'
-- local configs = require 'lspconfig/configs'

-- if not lspconfig.golangcilsp then
--   configs.golangcilsp = {
--     default_config = {
--       cmd = {'golangci-lint-langserver'},
--       root_dir = lspconfig.util.root_pattern('.git', 'go.mod'),
--       init_options = {
--           command = { "golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json" };
--       }
--     };
--   }
-- end
-- lspconfig.golangcilsp.setup {
--   filetypes = {'go'}
-- }

-- local rust_cfg = {
--   filetypes = {"rust"},
--   root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json", ".git"),
--   settings = {
--     ["rust-analyzer"] = {
--       assist = {importMergeBehavior = "last", importPrefix = "by_self"},
--       cargo = {loadOutDirsFromCheck = true},
--       procMacro = {enable = true}
--     }
--   }
-- }
-- lspconfig.rust_analyzer.setup(rust_cfg)

return M
