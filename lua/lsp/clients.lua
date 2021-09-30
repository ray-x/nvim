-- todo allow config passed in

local lspconfig = nil
local lsp_status = nil


-- if vim.fn.line('$') > 100000 then  -- skip for large file
--   print('file too large')
--   return {}
-- end
-- if not packer_plugins["nvim-lua/lsp-status.nvim"] or not packer_plugins["lsp-status.nvim"].loaded then
--   vim.cmd [[packadd lsp-status.nvim]]
--   lsp_status = require("lsp-status")
--   -- if lazyloading
--   vim.cmd [[packadd nvim-lspconfig]]
--   lspconfig = require "lspconfig"
-- end
--
-- local cap = vim.lsp.protocol.make_client_capabilities()
-- -- Code actions
-- cap.textDocument.codeAction = {
--   dynamicRegistration = false,
--   codeActionLiteralSupport = {
--     codeActionKind = {
--       valueSet = {
--         "",
--         "quickfix",
--         "refactor",
--         "refactor.extract",
--         "refactor.inline",
--         "refactor.rewrite",
--         "source",
--         "source.organizeImports"
--       }
--     }
--   }
-- }
-- local on_attach = require("lsp.handler").on_attach
-- local lsp_status_cfg = {
--   status_symbol = "",
--   indicator_errors = "", --'',
--   indicator_warnings = "", --'',
--   indicator_info = "﯎",
--   --'',
--   indicator_hint = "💡",
--   indicator_ok = "",
--   --'✔️',
--   spinner_frames = {"⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"},
--   select_symbol = function(cursor_pos, symbol)
--     if symbol.valuerange then
--       local value_range = {
--         ["start"] = {
--           character = 0,
--           line = vim.fn.byte2line(symbol.valuerange[1])
--         },
--         ["end"] = {
--           character = 0,
--           line = vim.fn.byte2line(symbol.valuerange[2])
--         }
--       }
--
--       return require("lsp-status.util").in_range(cursor_pos, value_range)
--     end
--   end
-- }
--
-- -- local gopls = {}
-- -- gopls["ui.completion.usePlaceholders"] = true
--


-- return {setup = setup}
return {}
