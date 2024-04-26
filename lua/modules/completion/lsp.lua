local lspconfig = require('lspconfig')
local configs = require('lspconfig/configs')
local lsp = require('vim.lsp')

-- lsp not included in lspconfig

M = {}

M.setup = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  if not lspconfig.emmet_ls then
    configs.emmet_ls = {
      default_config = {
        cmd = { 'emmet-ls', '--stdio' },
        filetypes = { 'html', 'css', 'javascript', 'typescript', 'scss' },
        root_dir = function(fname)
          return vim.loop.cwd()
        end,
        settings = {},
      },
    }
  end
  -- if not lspconfig.goxls then
  --   configs.goxls= {
  --     default_config = {
  --       cmd = { 'goxls' },
  --       filetypes = { 'gop' },
  --       root_dir = function(fname)
  --         return vim.loop.cwd()
  --       end,
  --       settings = {},
  --     },
  --   }
  -- end

  lspconfig.emmet_ls.setup({ capabilities = capabilities })
  require('lspconfig').markdown_oxide.setup({
    -- root_dir = function() return vim.fn.getcwd() end,
    -- root_dir = lspconfig.util.root_pattern('.git', vim.uv.cwd()),
    root_dir = function()
      return lspconfig.util.root_pattern('.git', '.markdownlint.json')(vim.uv.cwd())
    end,
    filetypes = { 'markdown' },
  })
end
return M
