M = {}
local parse_changes = function()
  local status = vim.fn.system "git status --porcelain"

  local changes = vim.split(vim.trim(status), "\n")

  return changes
end

-- https://github.com/rmagatti/igs.nvim/
-- send changed file to qf

M.qf_add = function(type)
  type = type or 'all'
  local changes = parse_changes()
  local qflist_what = {}

  for _, change in ipairs(changes) do
    local change_type = vim.trim(change:sub(1, 1))
    local file_path = vim.trim(change:sub(3))

    if type == "all" then
      local bufnr = vim.fn.bufadd(file_path)
      table.insert(qflist_what, {bufnr = bufnr, lnum = 0, col = 0})
    elseif change_type == type then
      local bufnr = vim.fn.bufadd(file_path)
      table.insert(qflist_what, {bufnr = bufnr, lnum = 0, col = 0})
    end
  end

  if vim.tbl_isempty(qflist_what) then
    return
  end

  vim.fn.setqflist(qflist_what)

  vim.cmd [[copen]]
end
return M
