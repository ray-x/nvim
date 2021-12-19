return {
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

    table.insert(
      sources,
      require("null-ls.helpers").make_builtin({
        method = require("null-ls.methods").internal.DIAGNOSTICS,
        filetypes = { "java" },
        generator_opts = {
          command = "java",
          args = { "$FILENAME" },
          to_stdin = false,
          format = "raw",
          from_stderr = true,
          on_output = require("null-ls.helpers").diagnostics.from_errorformat([[%f:%l: %trror: %m]], "java"),
        },
        factory = require("null-ls.helpers").generator_factory,
      })
    )

    local cfg = {
      sources = sources,
      debounce = 1000,
      root_dir = require'lspconfig'.util.root_pattern(".null-ls-root", "Makefile", ".git", "go.mod", "package.json", "tsconfig.json"),
      on_attach = function (client)
        if client.resolved_capabilities.document_formatting then
            vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
        end
     end
    }


    null_ls.setup(cfg)
  end,
}
