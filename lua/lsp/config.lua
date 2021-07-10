local lspconfig = require "lspconfig"
local configs = require 'lspconfig/configs'
local lsp = require("vim.lsp")

M = {}
--
--

--  lua print(vim.inspect(vim.lsp.buf_get_clients(0)))
M.setup = function()
 -- print("lspconfig setup")
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  if not lspconfig.emmet_ls then
    configs.emmet_ls = {
      default_config = {
        cmd = {'emmet-ls', '--stdio'},
        filetypes = {'html', 'css'},
        root_dir = function(fname)
          return vim.loop.cwd()
        end,
        settings = {}
      }
    }
  end

  lspconfig.emmet_ls.setup {capabilities = capabilities}
  -- print(vim.inspect(lspconfig.emmet_ls))
  -- print(vim.inspect(capabilities.textDocument.completion))
  --
  --
  --



  -- lspconfig.diagnosticls.setup{
  --   filetypes = { "go", "javascript", "javascript.jsx" },
  --   init_options = {
  --     args = {"--log-level", "10"},
  --     filetypes = {
  --       javascript = "eslint",
  --       ["javascript.jsx"] = "eslint",
  --       javascriptreact = "eslint",
  --       typescriptreact = "eslint",
  --     },
  --     linters = {
  --       eslint = {
  --         sourceName = "eslint",
  --         command = "./node_modules/.bin/eslint",
  --         rootPatterns = { ".git" },
  --         debounce = 100,
  --         args = {
  --           "--stdin",
  --           "--stdin-filename",
  --           "%filepath",
  --           "--format",
  --           "json",
  --         },
  --         parseJson = {
  --           errorsRoot = "[0].messages",
  --           line = "line",
  --           column = "column",
  --           endLine = "endLine",
  --           endColumn = "endColumn",
  --           message = "${message} [${ruleId}]",
  --           security = "severity",
  --         };
  --         securities = {
  --           [2] = "error",
  --           [1] = "warning"
  --         }
  --       },
  --       golangci = {
  --         sourceName = "golangci-lint",
  --         command = "golangci-lint",
  --         rootPatterns = { ".git", ".go.mod" },
  --         debounce = 420,
  --         args = {
  --           "run",
  --           "%filepath",
  --           "--out-format",
  --           "json",
  --         },
  --         parseJson = {
  --           errorsRoot = "[0].Issues",
  --           line = "Pos.Line",
  --           column = "Pos.Column",
  --           message = "${Text} [${Pos.Filename} ${FromLinter}]",
  --           security = "Severity",
  --         };
  --       }
  --     }
  --   }
  -- }

  -- local stylelint = {
  --   lintCommand = "stylelint --stdin --stdin-filename ${INPUT} --formatter compact",
  --   lintIgnoreExitCode = true,
  --   lintStdin = true,
  --   lintFormats = {"%f: line %l, col %c, %tarning - %m", "%f: line %l, col %c, %trror - %m"},
  --   formatCommand = "stylelint --fix --stdin --stdin-filename ${INPUT}",
  --   formatStdin = true
  -- }
  -- local prettier = {
  --   formatCommand = "./node_modules/.bin/prettier --stdin-filepath ${INPUT}",
  --   formatStdin = true
  -- }

  -- local eslint_d = {
  --   lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  --   lintStdin = true,
  --   lintFormats = {"%f:%l:%c: %m"},
  --   lintIgnoreExitCode = true,
  --   formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  --   formatStdin = true
  -- }
  -- local rustfmt = {formatCommand = "rustfmt", formatStdin = true}

  -- lspconfig.efm.setup {
  --   flags = {debounce_text_changes = 1000},
  --   cmd = {'efm-langserver', '-loglevel', '5', '-logfile', '/Users/ray.xu/tmp/efm.log'}, -- 1~10
  --   init_options = {documentFormatting = true},
  --   on_attach = function(client)
  --     client.resolved_capabilities.document_formatting = true
  --     client.resolved_capabilities.goto_definition = false
  --     client.resolved_capabilities.code_action = nil
  --     local log = require("guihua.log").new({level = "info"}, true)
  --     vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()]])
  --     -- print ("efm attached")
  --     -- set_lsp_config(client)
  --   end,
  --   filetypes = {
  --     "javascript", "javascriptreact", 'typescript', 'typescriptreact', 
  --     'html', 'css', 'go', 'lua'
  --   },
  --   settings = {
  --     rootMarkers = {".git/", 'package.json', 'Makefile', 'go.mod'},
  --     lintDebounce =   "1s",
  --     -- formatDebounce = "1000ms",
  --     languages = {
  --       typescript = {stylelint, prettier},
  --       typescriptreact = {stylelint, prettier},
  --       javascript = {eslint_d},
  --       javascriptreact = {eslint_d},
  --       -- python = { python-flake8 },
  --       go = {
  --         {
  --           formatCommand = "golines --max-len=120  --base-formatter=gofumpt",
  --           formatStdin = true,
  --           lintCommand = "golangci-lint run",
  --           LintSeverity = 3,
  --         }
  --       },

  --       lua = {
  --         -- --indent-width 2 --tab-width 2 --no-use-tab --column-limit 110 --column-table-limit 100 --no-keep-simple-function-one-line --no-chop-down-table --chop-down-kv-table --no-keep-simple-control-block-one-line --no-keep-simple-function-one-line --no-break-after-functioncall-lp --no-break-after-operator
  --         { formatCommand = "lua-format --indent-width 2 --tab-width 2 --no-use-tab --column-limit 120 --column-table-limit 100 --no-keep-simple-function-one-line --no-chop-down-table --chop-down-kv-table --no-keep-simple-control-block-one-line --no-keep-simple-function-one-line --no-break-after-functioncall-lp --no-break-after-operator",
  --          formatStdin = true,
  --         }
  --       },
  --     }
  --   }
  -- }





-- Check if vhdl_ls server already defined.
if not lspconfig.vhdl_ls then configs['vhdl_ls'] = {default_config = {}} end

lspconfig.vhdl_ls.setup {
    cmd = {"/Users/ray.xu/lsp_test/vhdl/rust_hdl/target/release/vhdl_ls"},
    filetypes = { "vhdl"},
    root_dir = require('lspconfig/util').root_pattern("vhdl_ls.toml"),
    
    -- handlers = {
    --     ["tailwindcss/getConfiguration"] = function(_, _, params, _, bufnr, _)
    --         -- tailwindcss lang server waits for this repsonse before providing hover
    --         vim.lsp.buf_notify(bufnr, "tailwindcss/getConfigurationResponse", {_id = params._id})
    --     end
    -- },
--     handlers = {
--         ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
--             virtual_text = O.clang.diagnostics.virtual_text,
--             signs = O.clang.diagnostics.signs,
--             underline = O.clang.diagnostics.underline,
--             update_in_insert = true
-- 
--         })
--     },
    
    -- on_attach = require'lsp'.common_on_attach
    on_attach = function(client, bufnr)
        -- This makes sure tsserver is not used for formatting (I prefer prettier)
        -- client.resolved_capabilities.call_hierarchy   = false
        client.resolved_capabilities.document_symbol  = false
        -- client.resolved_capabilities.goto_definition  = false
        -- client.resolved_capabilities.find_references  = false
        -- client.resolved_capabilities.hover            = false
        -- client.resolved_capabilities.signature_help   = false
        client.resolved_capabilities.workspace_symbol = false

        -- ts_utils_attach(client)
        -- on_attach(client, bufnr)
    end,
}

  -- lspconfig.stylelint_lsp.setup {
  --   stylelint = {
  --     settings = {
  --       stylelintplus = {
  --         -- see available options in stylelint-lsp documentation
  --       }
  --     }
  --   }
  -- }


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


  -- lspconfig.dartls.setup{init_options = {
  --     closingLabels = false,
  --     flutterOutline = false,
  --     onlyAnalyzeProjectsWithOpenFiles = false,
  --     outline = false,
  --     suggestFromUnimportedLibraries = true,
  --     triggerSignatureHelpAutomatically = true,
  --   }}

  vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false
    })


  -- vim.g.diagnostics_active = true
  -- function _G.toggle_diagnostics()
  --   if vim.g.diagnostics_active then
  --     vim.g.diagnostics_active = false
  --     vim.lsp.diagnostic.clear(0)
  --     vim.lsp.handlers["textDocument/publishDiagnostics"] = function()
  --     end
  --   else
  --     vim.g.diagnostics_active = true
  --     vim.lsp.handlers["textDocument/publishDiagnostics"] =
  --         vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  --           virtual_text = true,
  --           signs = true,
  --           underline = true,
  --           update_in_insert = false
  --         })
  --   end
  -- end
  -- _G.toggle_diagnostics()

  vim.api.nvim_set_keymap('n', '<leader>tt', ':call v:lua.toggle_diagnostics()<CR>',
                          {noremap = true, silent = true})

  -- local lspconfig = require 'lspconfig'
  -- local configs = require 'lspconfig/configs'

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
end
return M


    -- lspconfig.efm.setup {
    --     cmd = { 'efm-langserver', '-c', efm_config, '-logfile', efm_log },
    --     on_attach = on_attach,
    --     flags = { debounce_text_changes = 150 },
    --     filetypes = {
    --         'python',
    --         'lua',
    --         'yaml',
    --         'json',
    --         'markdown',
    --         'rst',
    --         'html',
    --         'css',
    --         'javascript',
    --         'typescript',
    --         'javascriptreact',
    --         'typescriptreact',
    --         'bash',
    --         'sh',
    --     },
    --     -- Fallback to .bashrc as a project root to enable LSP on loose files
    --     root_dir = function(fname)
    --         return lspconfig.util.root_pattern(
    --             'tsconfig.json',
    --             'pyproject.toml'
    --         )(fname) or lspconfig.util.root_pattern(
    --             '.eslintrc.js',
    --             '.git'
    --         )(fname) or lspconfig.util.root_pattern(
    --             'package.json',
    --             '.git/',
    --             '.zshrc'
    --         )(fname)
    --     end,
    --     init_options = {
    --         documentFormatting = true,
    --         documentSymbol = false,
    --         completion = false,
    --         codeAction = false,
    --         hover = false,
    --     },
    --     settings = {
    --         rootMarkers = { 'package.json', 'go.mod', '.git/', '.zshrc' },
    --         languages = {
    --             python = { isortd, blackd },
    --             lua = { stylua },
    --             yaml = { prettierd },
    --             json = { dprint },
    --             markdown = { dprint },
    --             html = { prettier_d },
    --             css = { prettier_d },
    --             javascript = { eslint_d, prettierd },
    --             typescript = { eslint_d, prettierd },
    --             javascriptreact = { eslint_d, prettierd },
    --             typescriptreact = { eslint_d, prettierd },
    --             bash = { shellcheck, shfmt },
    --             sh = { shellcheck, shfmt },
    --         },
    --     },
    -- }