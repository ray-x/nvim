set termguicolors
call plug#begin('~/.vim/plugged')
Plug 'neovim/nvim-lspconfig'

Plug 'ray-x/lsp_signature.nvim'

call plug#end()

lua <<EOF
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  }
}

local nvim_lsp = require'lspconfig'

local signature_config = {
  log_path = "/Users/ray.xu/tmp/sig.log",
  debug = true,
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  hint_prefix = "",
  hi_parameter = "Search",
  fix_pos = true,
  extra_trigger_chars = {"(", ","},
  handler_opts = {
    border = "none",
  }
}

nvim_lsp.gopls.setup{
  on_attach = function(client, bufnr)
    require "lsp_signature".on_attach(signature_config)
    -- require'aerial'.on_attach(client)
  end,
  capabilities = capabilities,
  cmd = {"gopls", "serve"},
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}
EOF
set mouse=a
colorscheme evening