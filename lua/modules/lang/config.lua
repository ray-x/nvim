local config = {}

function config.nvim_treesitter()
  vim.api.nvim_command("set foldmethod=expr")
  vim.api.nvim_command("set foldexpr=nvim_treesitter#foldexpr()")
  require("modules.lang.treesitter").treesitter()
end

function config.nvim_treesitter_ref()
  require("modules.lang.treesitter").treesitter_ref()
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
  --" vim.g.ale_lint_on_text_changed = 'never'   --" do not lint when I am typing  'normal (def)'   'never'
  vim.g.ale_sign_column_always = 1
  vim.g.ale_go_golangci_lint_package = 1
  -- vim.g.ale_lua_luafmt_executable = "luafmt"
  -- vim.g.ale_lua_luafmt_options = "--indent-count 2"
  vim.g.ale_python_flake8_args = '--ignore=E501'
  vim.g.ale_python_flake8_executable = 'flake8'
  vim.g.ale_python_flake8_options = '--ignore=E501'
  --" 'go vet' not working
  vim.g.ale_linters = {
    javascript = {"eslint", "flow-language-server"},
    --javascript['jsx']  = {'eslint', 'flow-language-server'},
    -- go = {"govet", "golangci-lint", "revive"},
    markdown = {"mdl", "write-good"},
    sql = {"sqlint"},
    -- lua = {"luacheck"},
    -- python = {"flake8", "pylint"}
  }

  vim.g.ale_fixers = {
    -- go = {"gofumports"},
    -- javascript = {"prettier", "eslint"},
    --javascript['jsx'] = {'prettier', 'eslint'},
    -- typescript = {"eslint", "tslint"},
    -- markdown = {"prettier"},
    -- json = {"prettier"},
    sql = {"pgformatter"},
    -- css = {"prettier"},
    -- php = {"php-cs-fixer"},
    ale_fixers = {"prettier", "remark"},
    -- lua = {"luafmt"},
    -- python = {"autopep8", "yapf"}
  }
end

function config.sqls()
end

function config.navigator()
  require'navigator'.setup()
end


function config.playground()
  require "nvim-treesitter.configs".setup {
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries =true -- Whether the query persists across vim sessions
  }}
end

function config.luadev()
  -- vim.cmd([[vmap <leader><leader>r <Plug>(Luadev-Run)]])
end

function config.go()
  require('go').setup()

  vim.cmd("augroup go")
  vim.cmd("autocmd!")
  vim.cmd("autocmd FileType go nmap <leader>gb  :GoBuild")
  vim.cmd("autocmd FileType go nmap <leader><Leader>r  :GoRun")
  --  Show by default 4 spaces for a tab')
  vim.cmd("autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4")
  --  :GoBuild and :GoTestCompile')
  --vim.cmd('autocmd FileType go nmap <leader><leader>gb :<C-u>call <SID>build_go_files()<CR>')
  --  :GoTest')
  vim.cmd("autocmd FileType go nmap <leader>gt  GoTest")
  --  :GoRun

  vim.cmd("autocmd FileType go nmap <Leader><Leader>l GoLint")
  vim.cmd("autocmd FileType go nmap <Leader>gc :lua require('go.comment').gen()")

  vim.cmd("au FileType go command! Gtn :TestNearest -v -tags=integration")
  vim.cmd("au FileType go command! Gts :TestSuite -v -tags=integration")
  vim.cmd("augroup END")

  -- function! s:build_go_files()
  --   let l:file = expand('%')
  --   if l:file =~# '^\f\+_test\.go$'
  --     call go#test#Test(0, 1)
  --   elseif l:file =~# '^\f\+\.go$'
  --     call go#cmd#Build(0)
  --   endif
  -- endfunction
end

function config.dap()
  require('modules.lang.dap.dap')
end

function config.formatter()
  -- body

  require('formatter').setup({
  logging = false,
  filetype = {
    javascript = {
        -- prettier
       function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
            stdin = true
          }
        end
    },
    rust = {
      -- Rustfmt
      function()
        return {
          exe = "rustfmt",
          args = {"--emit=stdout"},
          stdin = true
        }
      end
    },
    lua = {
        -- luafmt
        function()
          return {
            exe = "luafmt",
            args = {"--indent-count", 2, "--stdin"},
            stdin = true
          }
        end
      }
    }
  })
  -- vim.api.nvim_exec([[
  -- augroup FormatAutogroup
  --   autocmd!
  --   autocmd BufWritePre *.js,*.rs,*.lua FormatWrite
  -- augroup END
  -- ]], true)
end

return config
