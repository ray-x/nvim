set termguicolors
call plug#begin('~/.vim/plugged')

Plug 'neovim/nvim-lspconfig'
Plug '~/github/lsp_signature.nvim'
Plug '~/github/go.nvim'

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
  log_path = vim.fn.expand("$HOME") .. "/tmp/sig.log",
  debug = true,
  -- bind = true,
  -- hint_prefix = "",
  -- hi_parameter = "Search",
  -- fix_pos = true,
  -- extra_trigger_chars = {"(", ","},
  -- handler_opts = {
  --   border = "none",
  -- }
  hint_enable = false,
  handler_opts = {
    border = "single",
  },
  max_width = 80,
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

local sumneko_root_path = vim.fn.expand("$HOME")..'/github/sumneko/lua-language-server'
local sumneko_binary = vim.fn.expand("$HOME")..'/github/sumneko/lua-language-server/bin/macOS/lua-language-server'

local lua_cfg = {
  cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're -- using (most ely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Setup your lua path
        path = vim.split(package.path, ";")
      },
      diagnostics = {
        enable = true,
        -- Get the language server to recognize the `vim` global
        globals = {
          "vim",
          "describe",
          "it",
          "before_each",
          "after_each",
          "teardown",
          "pending"
        }
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
          -- [vim.fn.expand("~/repos/nvim/lua")] = true
        }
      }
    }
  }
}

-- require'lspconfig'.svelte.setup{}
-- require'lspconfig'.sumneko_lua.setup (lua_cfg)
require "lsp_signature".setup(signature_config)
require 'go'.setup({
  verbose = true,
  goimport = 'goimports',
  lsp_cfg = 
   {settings={gopls={matcher='CaseInsensitive', ['local'] = "~/github/go", gofumpt = true }}}
  
})

EOF
set mouse=a
colorscheme evening