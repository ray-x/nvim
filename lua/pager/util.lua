local nvim = vim.api -- luacheck: ignore

-- Check if the begining of the current buffer contains ansi escape sequences.
--
-- For performance only the first 100 lines are checked.
local function check_escape_sequences()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = nvim.nvim_get_option_value('filetype', { buf = bufnr })
  if filetype == '' or filetype == 'text' then
    for _, line in ipairs(nvim.nvim_buf_get_lines(0, 0, 100, false)) do
      if line:find('\27%[[;?]*[0-9.;]*[A-Za-z]') ~= nil then
        return true
      end
    end
  end
  return false
end

return {
  check_escape_sequences = check_escape_sequences,
}
