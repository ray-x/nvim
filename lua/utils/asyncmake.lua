-- https://github.com/ms-jpq/neovim-async-tutorial for more tips
local M = {}

function M.make()
  local lines = {""}
  local winnr = vim.fn.win_getid()
  local bufnr = vim.api.nvim_win_get_buf(winnr)

  local makeprg = vim.api.nvim_buf_get_option(bufnr, "GoBuild")
  if not makeprg then return end

  local cmd = vim.fn.expandcmd(makeprg)

  local function on_event(job_id, data, event)
    if event == "stdout" or event == "stderr" then
      if data then
        vim.list_extend(lines, data)
      end
    end

    if event == "exit" then
      vim.fn.setqflist({}, " ", {
        title = cmd,
        lines = lines,
        efm = vim.api.nvim_buf_get_option(bufnr, "errorformat")
      })
      vim.api.nvim_command("doautocmd QuickFixCmdPost")
    end
  end

  local job_id =
    vim.fn.jobstart(
    cmd,
    {
      on_stderr = on_event,
      on_stdout = on_event,
      on_exit = on_event,
      stdout_buffered = true,
      stderr_buffered = true,
    }
  )
end

return M


-- command! Make silent lua require'async_make'.make()
-- nnoremap <silent> <space>m :Make<CR>
-- augroup LintOnSave
--   autocmd! BufWritePost <buffer> Make
-- augroup END
-- command! DisableLintOnSave autocmd! LintOnSave BufWritePost <buffer>