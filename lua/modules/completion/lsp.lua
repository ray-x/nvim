local lspconfig = require "lspconfig"
local configs = require 'lspconfig/configs'
local lsp = require("vim.lsp")


-- lsp not included in lspconfig

M = {}

M.setup = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  if not lspconfig.emmet_ls then
    configs.emmet_ls = {
      default_config = {
        cmd = {'emmet-ls', '--stdio'},
        filetypes = {'html', 'css', 'javascript', 'typescript', 'scss'},
        root_dir = function(fname)
          return vim.loop.cwd()
        end,
        settings = {}
      }
    }
  end

  lspconfig.emmet_ls.setup {capabilities = capabilities}

end
return M
