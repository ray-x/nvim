return {
  config = function()
    local null_ls = require("null-ls")
    local lspconfig = require("lspconfig")

    local sources = {}

    local function exist(bin)
      return vim.fn.exepath(bin) ~= ""
    end

    -- lua
    if exist("stylua") then
      table.insert(sources, null_ls.builtins.formatting.stylua)
    end

    table.insert(sources, null_ls.builtins.formatting.autopep8)
    table.insert(
      sources,
      null_ls.builtins.formatting.golines.with({
        "--max-len=120",
        "--base-formatter=gofumpt",
      })
    )

    -- shell script
    if exist("shellcheck") then
      table.insert(sources, null_ls.builtins.diagnostics.shellcheck)
    end

    table.insert(sources, null_ls.builtins.formatting.rustfmt)

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
      table.insert(null_ls.builtins.formatting.stylua.with({
        args = { "--indent-type", "Spaces", "--indent_width", "2", "-" },
      }))
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

    null_ls.config({ sources = sources })

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

    local setup = require("null-ls")
    null_ls.config({ sources = sources })
  end,
}
