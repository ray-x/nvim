local stylelint = {
  lintCommand = "stylelint --stdin --stdin-filename ${INPUT} --formatter compact",
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = { "%f: line %l, col %c, %tarning - %m", "%f: line %l, col %c, %trror - %m" },
  formatCommand = "stylelint --fix --stdin --stdin-filename ${INPUT}",
  formatStdin = true,
}

local prettier = {
  -- formatCommand = 'prettier --stdin-filepath ${INPUT}',
  -- formatCommand = './node_modules/.bin/prettier --find-config-path --stdin-filepath ${INPUT}',
  formatCommand = "prettier --find-config-path --stdin-filepath ${INPUT}",
  formatStdin = true,
}
-- local prettier = {formatCommand = 'prettier --stdin-filepath ${INPUT}', formatStdin = true}

local eslint_d = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT} -f visualstudio",
  lintStdin = true,
  lintFormats = { "%f(%l,%c): %tarning %m", "%f(%l,%c): %rror %m" }, -- {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true,
}
local pythonBlack = { formatCommand = [[black --quiet -]], formatStdin = true }
local sql_formatter = {
  formatCommand = [[sql-formatter -l plsql -i 4 -u | sed -e 's/\$ {/\${/g' | sed -e 's/: :/::/g']],
  formatStdin = true,
}

local rustfmt = { formatCommand = "rustfmt", formatStdin = true }
-- -style="{BasedOnStyle: Google, IndentWidth: 4, AlignConsecutiveDeclarations: true, AlignConsecutiveAssignments: true, ColumnLimit: 0}"
local clangfmtproto = {
  formatCommand = [[clang-format -style="{BasedOnStyle: Google, IndentWidth: 4, AlignConsecutiveDeclarations: true, AlignConsecutiveAssignments: true, ColumnLimit: 0}"]],
  formatStdin = true,
}
local efm_cfg = {
  flags = { debounce_text_changes = 2000 },
  cmd = { "efm-langserver", "-loglevel", "1", "-logfile", vim.fn.expand("$HOME") .. "/tmp/efm.log" }, -- 1~10
  init_options = { documentFormatting = true, codeAction = false, document_formatting = true },
  root_dir = require("lspconfig").util.root_pattern({ ".git/", "package.json", "." }),
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.definitionProvider = false
    -- client.resolved_capabilities.code_action = nil
    local log = require("guihua.log").new({ level = "info" }, true)

    vim.cmd([[
      aug efmFormat
        au!
        autocmd BufWritePre * lua vim.lsp.buf.formatting()
      aug END
     ]])

    -- print ("efm attached")
    -- set_lsp_config(client)
  end,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "html",
    "css",
    "go",
    "lua",
    "sql",
    "json",
    "markdown",
    "scss",
    "yaml",
    "javascript.jsx",
    "less",
    "graphql",
    "vue",
    "svelte",
    "proto",
  },

  settings = {
    rootMarkers = { ".git/", "package.json", "Makefile", "go.mod" },
    lintDebounce = "1s",
    formatDebounce = "1000ms",
    languages = {
      css = { prettier },
      json = { prettier },
      scss = { prettier },
      yaml = { prettier },
      markdown = { prettier },
      typescript = { stylelint, prettier, eslint_d },
      typescriptreact = { stylelint, prettier, eslint_d },
      javascript = { eslint_d, prettier },
      javascriptreact = { eslint_d, prettier },
      sass = { prettier },
      less = { prettier },
      graphql = { prettier },
      vue = { prettier },
      html = { prettier },
      svelte = { eslint_d, prettier },
      proto = { clangfmtproto },

      ["javascript.jsx"] = { eslint_d, prettier },
      python = { pythonBlack },
      go = {
        {
          formatCommand = "golines --max-len=120  --base-formatter=gofumpt",
          formatStdin = true,
          lintCommand = "golangci-lint run",
          LintSeverity = 3,
        },
      },
      lua = {
        {
          formatCommand = "lua-format --indent-width 2 --tab-width 2 --no-use-tab --column-limit 120 --column-table-limit 100 --no-keep-simple-function-one-line --no-chop-down-table --chop-down-kv-table --no-keep-simple-control-block-one-line --no-keep-simple-function-one-line --no-break-after-functioncall-lp --no-break-after-operator",
          formatStdin = true,
        },
      },
      sql = { -- length 100, FUNCTION upcase, keep newline, parameter & insert each parameter a new line '-B -t'
        sql_formatter,
      },
      rust = { rustfmt },
    },
  },
}

return { efm = efm_cfg }
