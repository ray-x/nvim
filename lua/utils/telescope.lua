local a = vim.api
local telescope = require("telescope")
local actions = require('telescope.actions')
local config = require('telescope.config')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local previewers = require('telescope.previewers')
local conf = require('telescope.config').values

local layout = require('telescope.pickers.layout_strategies')
local resolve = require('telescope.config.resolve')
local make_entry = require('telescope.make_entry')
local previewers = require('telescope.previewers')
local sorters = require('telescope.sorters')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local builtin = require('telescope.builtin')
local config = require('telescope.config')
local state = require('telescope.state')
local action_set = require "telescope.actions.set"

M = {}

M.find_dots = function(opts)
  opts = opts or {}

  opts.cwd = require'core.global'.home
  -- By creating the entry maker after the cwd options,
  -- we ensure the maker uses the cwd options when being created.
  opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)

  pickers.new(opts, {
    prompt_title = '~~ Dotfiles ~~',
    finder = finders.new_oneshot_job({
      "git", "--git-dir=" .. require'core.global'.home .. "/.dots/",
      "--work-tree=" .. require'core.global'.home, "ls-tree", "--full-tree", "-r", "--name-only",
      "HEAD"
    }, opts),
    previewer = previewers.cat.new(opts),
    sorter = conf.file_sorter(opts)
  }):find()
end

-- Looks for git files, but falls back to normal files
M.files = function(opts)
  opts = opts or {}

  vim.fn.system("git status")
  local is_not_git = vim.v.shell_error > 0
  if is_not_git then
    require'telescope.builtin'.find_files(opts)
    return
  end

  if opts.cwd then
    opts.cwd = vim.fn.expand(opts.cwd)
  else
    --- Find root of git directory and remove trailing newline characters
    opts.cwd = string.gsub(vim.fn.system("git rev-parse --show-toplevel"), '[\n\r]+', '')
  end

  -- By creating the entry maker after the cwd options,
  -- we ensure the maker uses the cwd options when being created.
  opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)

  pickers.new(opts, {
    prompt_title = 'Git File',
    finder = finders.new_oneshot_job({"git", "ls-files", "--recurse-submodules"}, opts),
    previewer = previewers.cat.new(opts),
    sorter = conf.file_sorter(opts)
  }):find()
end

-- nnoremap <Leader>o <Cmd>lua require'telescope_config'.files{}<CR>
-- nnoremap <Leader>d <Cmd>lua require'telescope_config'.find_dots{}<CR>

vim.api.nvim_command([[ command! -nargs=1 Rg call luaeval('require('telescope.builtin').grep_string(
        require("config.telescope").theme({
            search = _A
        })
    )', expand('<args>'))
    ]])

--[[
    +-------------------------------------+
    | Prompt                              |
    +--------------------+----------------+
    | Results            | Preview        |
    |                    |                |
    |                    |                |
    +--------------------+----------------+
--]]
layout.custom = function(self, columns, lines)
  local initial_options = self:_get_initial_window_options()
  local preview = initial_options.preview
  local results = initial_options.results
  local prompt = initial_options.prompt

  -- This sets the height/width for the whole layout
  local height = resolve.resolve_height(self.window.results_height)(self, columns, lines)
  local width = resolve.resolve_width(self.window.width)(self, columns, lines)

  local max_results = (height > lines and lines or height)
  local max_width = (width > columns and columns or width)

  local has_preview = self.previewer

  -- border size
  local bs = self.window.border and 1 or 0

  prompt.height = 1
  results.height = max_results
  preview.height = max_results
  preview.width = width - math.floor(width * self.window.results_width)

  prompt.width = max_width
  results.width = max_width - (has_preview and (preview.width + bs) or 0)

  prompt.line = (lines / 2) - ((max_results + (bs * 2)) / 2)
  results.line = prompt.line + 1 + (bs)
  preview.line = results.line

  if not self.previewer or columns < self.preview_cutoff then
    if self.window.border and self.window.borderchars then
      self.window.borderchars.results[6] = self.window.borderchars.preview[6]
      self.window.borderchars.results[7] = self.window.borderchars.preview[7]
    end

    preview.height = 0
  end

  results.col = math.ceil((columns / 2) - (width / 2) - bs)
  prompt.col = results.col
  preview.col = results.col + results.width + bs

  return {preview = has_preview and preview, results = results, prompt = prompt}
end

M.theme = function(opts)
  return vim.tbl_deep_extend("force", {
    sorting_strategy = "ascending",
    layout_strategy = "custom",
    results_title = false,
    preview_title = false,
    preview = false,
    winblend = 30,
    width = 100,
    results_height = 15,
    results_width = 0.37,
    border = false,
    borderchars = {
      {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
      prompt = {"─", "│", " ", "│", "╭", "╮", "│", "│"},
      results = {"─", "│", "─", "│", "├", "┬", "┴", "╰"},
      preview = {"─", "│", "─", "│", "╭", "┤", "╯", "╰"}
    }
  }, opts or {})
end

function M.files()
  pickers.new(M.theme(), {
    finder = finders.new_oneshot_job({"fd", "-t", "f"}),
    sorter = sorters.get_fzy_sorter()
  }):find()
end

function M.buffers()
  local opts = {shorten_path = true}
  local buffers = vim.tbl_filter(function(b)
    return (opts.show_all_buffers or vim.api.nvim_buf_is_loaded(b)) and 1 == vim.fn.buflisted(b)
  end, vim.api.nvim_list_bufs())

  local max_bufnr = math.max(unpack(buffers))
  opts.bufnr_width = #tostring(max_bufnr)

  pickers.new(M.theme(), {
    finder = finders.new_table {results = buffers, entry_maker = make_entry.gen_from_buffer(opts)},
    sorter = sorters.get_fzy_sorter()
  }):find()
end

function M.command_history()
  builtin.command_history(M.theme())
end

function M.load_dotfiles()
  local has_telescope, telescope = pcall(require, 'telescope.builtin')
  if has_telescope then
    local finders = require('telescope.finders')
    local previewers = require('telescope.previewers')
    local pickers = require('telescope.pickers')
    local sorters = require('telescope.sorters')
    local themes = require('telescope.themes')

    local results = {}
    local dotfiles = require'core.global'.home .. '/.dotfiles'
    for file in io.popen('find "' .. dotfiles .. '" -type f'):lines() do
      if not file:find('fonts') then
        table.insert(results, file)
      end
    end

    for file in io.popen('find "' .. global.vim_path .. '" -type f'):lines() do
      table.insert(results, file)
    end

    telescope.dotfiles = function(opts)
      opts = themes.get_dropdown {}
      pickers.new(opts, {
        prompt = 'dotfiles',
        finder = finders.new_table {results = results},
        previewer = previewers.cat.new(opts),
        sorter = sorters.get_generic_fuzzy_sorter()
      }):find()
    end
  end
  require('telescope.builtin').dotfiles()
end

M.setup = function()
  telescope.setup {
    defaults = {
      shorten_path = true,
      prompt_prefix = "🍔 ",
      layout_config = {prompt_position = "top"},
      sorting_strategy = "ascending",
      file_previewer = require"telescope.previewers".vim_buffer_cat.new,
      grep_previewer = require"telescope.previewers".vim_buffer_vimgrep.new,
      qflist_previewer = require"telescope.previewers".vim_buffer_qflist.new,
      extensions = {fzy_native = {override_generic_sorter = false, override_file_sorter = true}},
      mappings = {
        n = {
          ["<C-e>"] = function(prompt_bufnr)
            local results_win = state.get_status(prompt_bufnr).results_win
            local height = vim.api.nvim_win_get_height(results_win)
            action_set.shift_selection(prompt_bufnr, math.floor(height / 2))
          end,
          ["<C-y>"] = function(prompt_bufnr)
            local results_win = state.get_status(prompt_bufnr).results_win
            local height = vim.api.nvim_win_get_height(results_win)
            action_set.shift_selection(prompt_bufnr, -math.floor(height / 2))
          end
        },
        i = {
          ["<esc>"] = actions.close,
          ["<C-e>"] = function(prompt_bufnr)
            local results_win = state.get_status(prompt_bufnr).results_win
            local height = vim.api.nvim_win_get_height(results_win)
            action_set.shift_selection(prompt_bufnr, math.floor(height / 2))
          end,
          ["<C-y>"] = function(prompt_bufnr)
            local results_win = state.get_status(prompt_bufnr).results_win
            local height = vim.api.nvim_win_get_height(results_win)
            action_set.shift_selection(prompt_bufnr, -math.floor(height / 2))
          end
        }
      }
    }
  }
  telescope.load_extension("dotfiles")
  telescope.load_extension("gosource")
  telescope.load_extension("live_grep_raw")
end

return M
