local configs = require('lspconfig/configs')
local lsp = require('vim.lsp')

-- lsp not included in lspconfig

M = {}

function M.completion_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.documentationFormat = { 'markdown', 'plaintext' }
  capabilities.textDocument.completion.completionItem.preselectSupport = true
  capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
  capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
  capabilities.textDocument.completion.completionItem.deprecatedSupport = true
  capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
  }
  return capabilities
end

M.setup = function()
  local capabilities = M.completion_capabilities()

  -- Apply baseline completion capabilities for all servers on Neovim 0.12+.
  if vim.lsp and type(vim.lsp.config) == 'function' then
    pcall(vim.lsp.config, '*', {
      capabilities = capabilities,
      flags = {
        -- Prevent excessive didChange traffic on rapidly updating buffers.
        debounce_text_changes = 300,
      },
    })
  end

  if not vim.lsp.config.emmet_ls then
    configs.emmet_ls = {
      default_config = {
        cmd = { 'emmet-ls', '--stdio' },
        filetypes = { 'html', 'css', 'javascript', 'typescript', 'scss' },
        capabilities = capabilities,
        root_dir = function(fname)
          return vim.uv.cwd()
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
  --         return vim.uv.cwd()
  --       end,
  --       settings = {},
  --     },
  --   }
  -- end

  --[[

  vim.lsp.config.emmet_ls.setup({ capabilities = capabilities })
  vim.lsp.config.markdown_oxide.setup({
    -- root_dir = function() return vim.fn.getcwd() end,
    -- root_dir = lspconfig.util.root_pattern('.git', vim.uv.cwd()),
    root_dir = function()
      return lspconfig.util.root_pattern('.git', '.markdownlint.json')(vim.uv.cwd())
    end,
    filetypes = { 'markdown' },
  })

  -- ]]
end
return M
