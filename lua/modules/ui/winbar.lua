local M = {}

vim.api.nvim_set_hl(0, "WinBarSignature", { fg = "#dedede", bg = "#363636" })
vim.api.nvim_set_hl(0, "WinBarSigDoc", { fg = "#dedede", bg = "#363636" })
vim.api.nvim_set_hl(0, "WinBarSigActParm", { fg = "#dedede", bg = "#9f3838" })

local treesitter_context = require"modules.lang.treesitter".context

function M.eval()
  local columns = vim.api.nvim_get_option("columns")
  if not pcall(require, "lsp_signature") then
    return treesitter_context(columns)
  end
  local sig = require("lsp_signature").status_line(columns)

  if sig == nil or sig.label == nil or sig.range == nil then
     return treesitter_context(columns)
  end
  local label1 = sig.label
  local label2 = ""
  if sig.range then
    label1 = sig.label:sub(1, sig.range["start"] - 1)
    label2 = sig.label:sub(sig.range["end"] + 1, #sig.label)
  end
  local doc = sig.doc or ""
  if #doc + #sig.label >= columns then
    local trim = math.max(5, columns - #sig.label - #sig.hint - 10)
    doc = doc:sub(1, trim) .. "..."
    -- lprint(doc)
  end


  return "%#WinBarSignature#"
      .. label1
      .. "%*"
      .. "%#WinBarSigActParm#"
      .. sig.hint
      .. "%*"
      .. "%#WinBarSignature#"
      .. label2
      .. "%*"
      .. "%#WinBarSigDoc#"
      .. " " .. doc
    or "" .. "%*"
end

return M
