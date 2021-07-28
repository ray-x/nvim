local config = {}
local bind = require('keymap.bind')
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd

function config.nvim_treesitter()
  require("modules.lang.treesitter").treesitter()
end

function config.nvim_treesitter_ref()
  require("modules.lang.treesitter").treesitter_ref()
end

function config.lint()
  require('lint').linters_by_ft = {markdown = {'vale'}, go = {'golangcilint'}}
  -- vim.cmd([[au BufWritePost <buffer> lua require('lint').try_lint()]])
end

function config.neomake()
  vim.g.neomake_error_sign = {text = '✖', texthl = 'NeomakeErrorSign'}
  vim.g.neomake_warning_sign = {text = '∆', texthl = 'NeomakeWarningSign'}
  vim.g.neomake_message_sign = {text = '➤', texthl = 'NeomakeMessageSign'}
  vim.g.neomake_info_sign = {text = 'ℹ', texthl = 'NeomakeInfoSign'}
  vim.g.neomake_go_enabled_makers = {'go', 'golangci_lint', 'golint'}
end

function config.sidekick()
  -- body
  vim.g.sidekick_printable_def_types = {
    'function', 'class', 'type', 'module', 'parameter', 'method', 'field'
  }
  -- vim.g.sidekick_def_type_icons = {
  --    class = "\\uf0e8",
  --    type = "\\uf0e8",
  --    ['function'] = "\\uf794",
  --    module = "\\uf7fe",
  --    arc_component = "\\uf6fe",
  --    sweep = "\\uf7fd",
  --    parameter = "•",
  --    var = "v",
  --    method = "\\uf794",
  --    field = "\\uf6de",
  -- }
  -- vim.g.sidekick_ignore_by_def_type = {
  --   ['var'] = {"_": 1, "self": 1},
  --   parameters = {"self": 1},
  -- }

  -- Indicates which definition types should have their line number displayed in the outline window.
  vim.g.sidekick_line_num_def_types = {
    class = 1,
    type = 1,
    ['function'] = 1,
    module = 1,
    method = 1
  }

  -- What to display between definition and line number
  vim.g.sidekick_line_num_separator = " "
  -- What to display to the left and right of the line number
  -- vim.g.sidekick_line_num_left = "\\ue0b2"
  -- vim.g.sidekick_line_num_right = "\\ue0b0"
  -- -- What to display before outer vs inner vs folded outer definitions
  -- vim.g.sidekick_outer_node_folded_icon = "\\u2570\\u2500\\u25C9"
  -- vim.g.sidekick_outer_node_icon = "\\u2570\\u2500\\u25CB"
  -- vim.g.sidekick_inner_node_icon = "\\u251c\\u2500\\u25CB"
  -- -- What to display to left and right of def_type_icon
  -- vim.g.sidekick_left_bracket = "\\u27ea"
  -- vim.g.sidekick_right_bracket = "\\u27eb"
end

function config.ale()
  vim.g.ale_sign_error = "ﴫ"
  vim.g.ale_sign_warning = ""
  -- vim.g.ale_go_gopls_executable = "gopls"
  -- vim.g.ale_go_revive_executable = "revive"
  -- vim.g.ale_go_gopls_options = "-remote=auto"
  -- vim.g.ale_go_golangci_lint_options =
  --   "--enable-all --disable dogsled --disable gocognit --disable godot --disable godox --disable lll --disable nestif --disable wsl --disable gocyclo --disable asciicheck --disable gochecknoglobals"
  vim.g.ale_lint_delay = 1000 -- " begin lint after 1s
  vim.g.ale_lint_on_save = 1
  -- " vim.g.ale_lint_on_text_changed = 'never'   --" do not lint when I am typing  'normal (def)'   'never'
  vim.g.ale_sign_column_always = 1
  vim.g.ale_go_golangci_lint_package = 1
  -- vim.g.ale_lua_luafmt_executable = "luafmt"
  -- vim.g.ale_lua_luafmt_options = "--indent-count 2"
  vim.g.ale_python_flake8_args = "--ignore=E501"
  vim.g.ale_python_flake8_executable = "flake8"
  vim.g.ale_python_flake8_options = "--ignore=E501"
  -- " 'go vet' not working
  vim.g.ale_linters = {
    javascript = {"eslint", "flow-language-server"},
    -- javascript['jsx']  = {'eslint', 'flow-language-server'},
    -- go = {"govet", "golangci-lint", "revive"},
    markdown = {"mdl", "write-good"},
    sql = {"sqlint"}
    -- lua = {"luacheck"},
    -- python = {"flake8", "pylint"}
  }

  vim.g.ale_fixers = {
    -- go = {"gofumports"},
    -- javascript = {"prettier", "eslint"},
    -- javascript['jsx'] = {'prettier', 'eslint'},
    -- typescript = {"eslint", "tslint"},
    -- markdown = {"prettier"},
    -- json = {"prettier"},
    sql = {"pgformatter"},
    -- css = {"prettier"},
    -- php = {"php-cs-fixer"},
    ale_fixers = {"prettier", "remark"}
    -- lua = {"luafmt"},
    -- python = {"autopep8", "yapf"}
  }
end

function config.sqls()
end

function config.syntax_folding()
  local fname = vim.fn.expand("%:p:f")
  local fsize = vim.fn.getfsize(fname)
  if fsize > 1024 * 1024 then
    print("disable syntax_folding")
    vim.api.nvim_command("setlocal foldmethod=none")
    return
  end
  vim.api.nvim_command("setlocal foldmethod=expr")
  vim.api.nvim_command("setlocal foldexpr=nvim_treesitter#foldexpr()")
end


local stylelint = {
  lintCommand = "stylelint --stdin --stdin-filename ${INPUT} --formatter compact",
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = {"%f: line %l, col %c, %tarning - %m", "%f: line %l, col %c, %trror - %m"},
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
local rustfmt = {formatCommand = "rustfmt", formatStdin = true}


  -- local cfg = {
  --   library = {
  --     vimruntime = true, -- runtime path
  --     types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
  --     plugins = true, -- installed opt or start plugins in packpath
  --     -- you can also specify the list of plugins to make available as a workspace library
  --     -- plugins = { "nvim-treesitter", "plenary.nvim", "navigator" },
  --   },
  --   -- pass any additional options that will be merged in the final lsp config
  --   lspconfig = {
  --     -- cmd = {sumneko_binary},
  --     -- on_attach = ...
  --   },
  -- }

  -- local luadev = require("lua-dev").setup(cfg)

function config.navigator()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local sumneko_root_path = vim.fn.expand("$HOME") .. "/github/sumneko/lua-language-server"
  local sumneko_binary = vim.fn.expand("$HOME")
                             .. "/github/sumneko/lua-language-server/bin/macOS/lua-language-server"

  local single = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}
  local efm_cfg = {
        flags = {debounce_text_changes = 2000},
        cmd = {'efm-langserver', '-loglevel', '1', '-logfile', '/Users/ray.xu/tmp/efm.log'}, -- 1~10
        init_options = {documentFormatting = true},
        on_attach = function(client)
          client.resolved_capabilities.document_formatting = true
          client.resolved_capabilities.goto_definition = false
          client.resolved_capabilities.code_action = nil
          local log = require("guihua.log").new({level = "info"}, true)
          vim.cmd([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()]])
          -- print ("efm attached")
          -- set_lsp_config(client)
        end,
        filetypes = {
          "javascript", "javascriptreact", 'typescript', 'typescriptreact', 
          'html', 'css', 'go', 'lua'
        },
        settings = {
          rootMarkers = {".git/", 'package.json', 'Makefile', 'go.mod'},
          lintDebounce =   "1s",
          formatDebounce = "1000ms",
          languages = {
            typescript = {stylelint, prettier},
            typescriptreact = {stylelint, prettier},
            javascript = {eslint_d},
            javascriptreact = {eslint_d},
            -- python = { python-flake8 },
            go = {
              {
                formatCommand = "golines --max-len=120  --base-formatter=gofumpt",
                formatStdin = true,
                lintCommand = "golangci-lint run",
                LintSeverity = 3,
              }
            },

            lua = {
              { formatCommand = "lua-format --indent-width 2 --tab-width 2 --no-use-tab --column-limit 120 --column-table-limit 100 --no-keep-simple-function-one-line --no-chop-down-table --chop-down-kv-table --no-keep-simple-control-block-one-line --no-keep-simple-function-one-line --no-break-after-functioncall-lp --no-break-after-operator",
               formatStdin = true,
              }
            },
          }
        }
      }

    local nav_cfg = {
      debug = true,
      width = 0.7,
      border = single, -- "single",
      -- keymaps = {{key = "GR", func = "references()"}}, 
      -- on_attach = function(client, bufnr)
      --   require "lsp_signature".on_attach(
      --     {
      --       floating_window = true,
      --       log_path = "/Users/ray.xu/tmp/sig.log",
      --       debug = true,
      --       fix_pos = true,
      --       hi_parameter = 'Constant',
      --       bind = true, -- This is mandatory, otherwise border config won't get registered.
      --       handler_opts = {
      --         border = {"╭", "─" ,"╮", "│", "╯", "─", "╰", "│" },
      --       },
      --     }
      --   )
      -- end,
      lsp = {
        format_on_save = true, -- set to false to disasble lsp code format on save (if you are using prettier/efm/formater etc)
        denols = {filetypes = {}},
        -- flow = {
        --   filetypes ={},
        -- },
        tsserver = {
          filetypes = {
            "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact",
            "typescript.tsx"
          },
          on_attach = function(client)
            client.resolved_capabilities.document_formatting = false -- allow efm to format
          end
        },
        gopls = {
          on_attach = function(client)
            -- print("i am a hook")
            client.resolved_capabilities.document_formatting = false  --efm
          end,
          settings = {
            gopls = {gofumpt = true} -- enableww gofumpt etc,
          }
          -- set to {} to disable the lspclient for all filetype
        },
        clangd = {filetypes = {}},  -- using ccls
        sumneko_lua = {
          sumneko_root_path = sumneko_root_path,
          sumneko_binary = sumneko_binary
          -- settings = luadev.settings
        },
        efm = efm_cfg,
      },
    }
    require"navigator".setup({
      debug = true, 
      width = 0.7,
      border = single, -- "single",
      lsp = {
        format_on_save = true, -- set to false to disasble lsp code format on save (if you are using prettier/efm/formater etc)
        denols = {filetypes = {}},
        tsserver = {
          filetypes = {
            "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact",
            "typescript.tsx"
          },
          on_attach = function(client)
            client.resolved_capabilities.document_formatting = false -- allow efm to format
          end
        },
        gopls = {
          on_attach = function(client)
            -- print("i am a hook")
            client.resolved_capabilities.document_formatting = false  --efm
          end,
          settings = {
            gopls = {gofumpt = true} -- enableww gofumpt etc,
          }
          -- set to {} to disable the lspclient for all filetype
        },
        clangd = {filetypes = {}},  -- using ccls
        sumneko_lua = {
          sumneko_root_path = sumneko_root_path,
          sumneko_binary = sumneko_binary
          -- settings = luadev.settings
        },
        efm = efm_cfg,
    }})
end

function config.playground()
  require"nvim-treesitter.configs".setup {
    playground = {
      enable = true,
      disable = {},
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = true -- Whether the query persists across vim sessions
    }
  }
end
function config.luadev()
  -- vim.cmd([[vmap <leader><leader>r <Plug>(Luadev-Run)]])
end
function config.lua_dev()
  local cfg = {
    library = {
      vimruntime = true, -- runtime path
      types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
      plugins = true -- installed opt or start plugins in packpath
      -- you can also specify the list of plugins to make available as a workspace library
      -- plugins = { "nvim-treesitter", "plenary.nvim", "navigator" },
    },
    -- pass any additional options that will be merged in the final lsp config
    lspconfig = {
      -- cmd = {sumneko_binary},
      -- on_attach = ...
    }
  }

  local luadev = require("lua-dev").setup(cfg)
  -- {
  --   -- add any options here, or leave empty to use the default settings
  --   -- lspconfig = {
  --   --   cmd = {"lua-language-server"}
  --   -- },
  -- })
  -- print(vim.inspect(luadev))
  -- require('lspconfig').sumneko_lua.setup(luadev)
end

function config.go()
  require("go").setup({
    verbose=true,
    log_path = vim.fn.expand("$HOME") .. "/tmp/gonvim.log",
    dap_debug=true,
    dap_debug_gui=true,
  })

  vim.cmd("augroup go")
  vim.cmd("autocmd!")
  vim.cmd("autocmd FileType go nmap <leader>gb  :GoBuild")
  vim.cmd("autocmd FileType go nmap <leader><Leader>r  :GoRun")
  --  Show by default 4 spaces for a tab')
  vim.cmd("autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4")
  --  :GoBuild and :GoTestCompile')
  -- vim.cmd('autocmd FileType go nmap <leader><leader>gb :<C-u>call <SID>build_go_files()<CR>')
  --  :GoTest')
  vim.cmd("autocmd FileType go nmap <leader>gt  GoTest")
  --  :GoRun

  vim.cmd("autocmd FileType go nmap <Leader><Leader>l GoLint")
  vim.cmd("autocmd FileType go nmap <Leader>gc :lua require('go.comment').gen()")

  vim.cmd("au FileType go command! Gtn :TestNearest -v -tags=integration")
  vim.cmd("au FileType go command! Gts :TestSuite -v -tags=integration")
  vim.cmd("augroup END")

end

function config.dap()
  -- dap.adapters.node2 = {
  --   type = 'executable',
  --   command = 'node',
  --   args = {os.getenv('HOME') .. '/apps/vscode-node-debug2/out/src/nodeDebug.js'},
  -- }
  -- vim.fn.sign_define('DapBreakpoint', {text='🟥', texthl='', linehl='', numhl=''})
  -- vim.fn.sign_define('DapStopped', {text='⭐️', texthl='', linehl='', numhl=''})
  -- require('telescope').load_extension('dap')
  -- vim.g.dap_virtual_text = true
end

return config
