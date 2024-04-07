local function fetch_and_paste_url_title()
  -- Get content of the unnamed register
  local url = vim.fn.getreg('*')

  -- Check if the content is likely a URL
  if not url:match('^https?://') then
    print('Register does not contain a valid URL')
    return
  end

  -- Use curl to fetch the webpage content. Adjust timeout as necessary.
  local cmd = string.format('curl -m 5 -s %s', vim.fn.shellescape(url))
  local result = vim.fn.system(cmd)

  -- Extract the title of the webpage
  local title = result:match('<title>(.-)</title>')
  if not title or title == '' then
    title = ''
  end

  -- Format and paste the Markdown link
  local markdown_link = string.format('[%s](%s)', title, url)
  vim.api.nvim_put({ markdown_link }, 'l', true, true)
end

local function parseFrontmatter(fileContent)
  local frontmatter = {}
  local inFrontmatter = false
  local currentKey, currentList, currentIndent
  if type(fileContent) == 'string' then
    -- split the string into lines
    fileContent = vim.split(fileContent, '\n', true)
  end

  for _, line in ipairs(fileContent) do
    if line:match('^---') then
      if inFrontmatter then
        if currentKey and currentList then
          frontmatter[currentKey] = currentList
        end
        break -- End of frontmatter
      end
      inFrontmatter = true
    elseif inFrontmatter then
      if currentKey then
        local itemIndent, item = line:match('^(%s*)%- (.*)$')
        if itemIndent and item and #itemIndent > (currentIndent or 0) then
          table.insert(currentList, item)
        else
          if currentList then -- Save the previous list if any
            frontmatter[currentKey] = currentList
          end
          currentKey, currentList, currentIndent = nil, nil, nil -- Reset for the next key
        end
      end

      if not currentKey then -- Process a new key or a non-list line
        local key, value = line:match('^(%w+):%s*(.*)$')
        if key then
          if value == '' then -- Prepare for a list in the second format
            currentKey, currentList = key, {}
            currentIndent = #line:match('^%s*')
          elseif value:match('^%[.*%]$') then -- Array in the first format
            frontmatter[key] = {}
            for item in value:gmatch('[%w_-]+') do
              table.insert(frontmatter[key], item)
            end
          else
            frontmatter[key] = value
          end
        end
      end
    end
  end

  if currentKey and currentList then -- Handle case where EOF is reached while parsing a list
    frontmatter[currentKey] = currentList
  end
  -- print(vim.inspect(frontmatter))
  return frontmatter
end

local filecontent1 = [[
---
title: My title
tags: [tag1, tag2]
---

This is the content
- item 1
- item 2
]]

-- local filecontent1 = {
--   '---',
--   'title: My title',
--   'tags: [tag1, tag2]',
--   '---',
--   'This is the content',
--   '- item 1',
--   '- item 2',
--   '---',
-- }
--
local filecontent2 = {
  '---',
  'title: My title',
  'tags:',
  '  - tag1',
  '  - tag2',
  '---',
  'This is the content',
  '- item 1',
  '- item 2',
  '---',
}

parseFrontmatter(filecontent1)
parseFrontmatter(filecontent2)
local function readFirstNLines(filePath, N)
  local lines = {}
  local file = io.open(filePath, 'r')
  if file then
    for _ = 1, N do
      local line = file:read('*line')
      if not line then
        break
      end
      table.insert(lines, line)
      if line == '---' then
        break
      end
    end
    file:close()
  end
  return table.concat(lines, '\n')
end

local function contains_all(table, table2)
  for key, value in pairs(table2) do
    if not vim.tbl_contains(table, value) then
      return false
    end
  end
  return true
end

local function contains_any(table, table2)
  for key, value in pairs(table2) do
    if vim.tbl_contains(table, value) then
      return true
    end
  end
  return false
end

local function searchMarkdownFiles(dir, N, criteria, matches)
  matches = matches or {}
  local handle, err = vim.loop.fs_scandir(dir)
  if not handle then
    print('Error opening directory: ' .. err)
    return matches
  end
  local match_all = criteria.match or 'all'
  while true do
    local name, ftype = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end -- No more files or directories

    local filePath = dir .. '/' .. name
    if ftype == 'directory' then
      searchMarkdownFiles(filePath, N, criteria, matches) -- Recursive call
    elseif ftype == 'file' and name:match('%.md$') then
      local fileContent = readFirstNLines(filePath, N)
      local frontmatter = parseFrontmatter(fileContent)
      local match = true
      for key, value in pairs(criteria) do
        local target = frontmatter[key]
        value = type(target) == 'table' and value or { value }
        target = type(target) == 'table' and target or { target }
        if match_all == 'all' then
          match = contains_all(target, value)
        else
          match = contains_any(target, value)
        end
      end

      if match then
        table.insert(matches, filePath)
      end
    end
  end

  return matches
end

local function md_search(criteria, N)
  N = N or 20
  local currentDir = vim.fn.getcwd() -- Get the current working directory
  return searchMarkdownFiles(currentDir, N, criteria)
end

-- print(vim.inspect(md_search({}, 40)))

-- Looks for git files, but falls back to normal files
local md_files = function(opts)
  local pickers = require('telescope.pickers')
  local sorters = require('telescope.sorters')
  local telescope = require('telescope')
  local themes = require('telescope.themes')
  local conf = require('telescope.config').values
  local finders = require('telescope.finders')
  local make_entry = require('telescope.make_entry')
  local previewers = require('telescope.previewers')
  opts = opts or {}

  if opts.cwd then
    opts.cwd = vim.fn.expand(opts.cwd)
  else
    --- Find root of git directory and remove trailing newline characters
    opts.cwd = vim.fn.getcwd()
  end

  local conf = require('telescope.config').values
  -- By creating the entry maker after the cwd options,
  -- we ensure the maker uses the cwd options when being created.
  opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)
  -- local files = md_search(opts.search or opts or {}, 40)
  local files = md_search({ tags = 'streamco' }, 40)
  opts.search = nil
  pickers
    .new(opts, {
      prompt_title = 'Marddown File',
      finder = finders.new_table({ results = files }),
      previewer = previewers.cat.new(opts),
      sorter = conf.file_sorter(opts),
    })
    :find()
end

local tbl_clone = function(original)
  local copy = {}
  for key, value in pairs(original) do
    copy[key] = value
  end
  return copy
end

local setup_opts = {
  auto_quoting = true,
  mappings = {},
}

local md_grep_telescope = function(opts)
  local pickers = require('telescope.pickers')
  local sorters = require('telescope.sorters')
  local telescope = require('telescope')
  local themes = require('telescope.themes')
  local conf = require('telescope.config').values
  local finders = require('telescope.finders')
  local make_entry = require('telescope.make_entry')
  local previewers = require('telescope.previewers')
  opts = vim.tbl_extend('force', setup_opts, opts or {})

  opts.vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments
  opts.entry_maker = opts.entry_maker or make_entry.gen_from_vimgrep(opts)
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd)

  if opts.search_dirs then
    for i, path in ipairs(opts.search_dirs) do
      opts.search_dirs[i] = vim.fn.expand(path)
    end
  end
  local where = opts.search_dirs
  if opts.search_files then
    -- flatten the list of files
    where = opts.search_files
  end

  local cmd_generator = function(prompt)
    local args = tbl_clone(opts.vimgrep_arguments)
    local prompt_parts = vim.split(prompt, ' ')
    local cmd = vim.tbl_flatten({ args, prompt_parts, where })

    if not prompt or prompt == '' then
      -- output the first line of files in the list
      local w = {}
      for i, v in ipairs(where) do
        table.insert(w, v .. ':1:1:')
      end
      w = table.concat(w, '\n')

      w = w .. '\n'
      return vim.tbl_flatten({ 'printf', w })
    end
    return cmd
  end

  -- apply theme
  if type(opts.theme) == 'table' then
    opts = vim.tbl_extend('force', opts, opts.theme)
  elseif type(opts.theme) == 'string' then
    if themes['get_' .. opts.theme] == nil then
      vim.notify_once(
        'live grep args config theme »' .. opts.theme .. '« not found',
        vim.log.levels.WARN
      )
    else
      opts = themes['get_' .. opts.theme](opts)
    end
  end

  local finder = function()
    local prompt_bufnr = vim.api.nvim_get_current_buf()
    local action_state = require('telescope.actions.state')
    local action_utils = require('telescope.actions.utils')
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local prompt
    if current_picker then
      local prompt = current_picker:_get_prompt()
    end
    -- if prompt == nil or prompt == '' and where then
    --   print('search : where', where)
    --   return finders.new_table({ results = where })
    -- end
    return finders.new_job(cmd_generator, opts.entry_maker, opts.max_results, opts.cwd)
  end

  pickers
    .new(opts, {
      prompt_title = 'Live Grep (Args)',
      finder = finder(),
      previewer = conf.grep_previewer(opts),
      sorter = sorters.highlighter_only(opts),
      attach_mappings = function(_, map)
        for mode, mappings in pairs(opts.mappings) do
          for key, action in pairs(mappings) do
            map(mode, key, action)
          end
        end
        return true
      end,
    })
    :find()
end

local function find_word_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local start_col = col
  local end_col = col
  while start_col > 0 and line:sub(start_col, start_col):match('%w') do
    start_col = start_col - 1
  end
  while end_col < #line and line:sub(end_col, end_col):match('%w') do
    end_col = end_col + 1
  end
  if start_col == end_col then
    return nil
  end
  return {
    text = line:sub(start_col + 1, end_col),
    start_col = start_col + 1,
    end_col = end_col,
  }
end

local function find_link_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local start_col = col
  local end_col = col
  while start_col > 0 and line:sub(start_col, start_col):match('%w') do
    start_col = start_col - 1
  end
  while end_col < #line and line:sub(end_col, end_col):match('%w') do
    end_col = end_col + 1
  end
  local link = line:match('%[.*%]%((.*)%)', start_col)
  if link then
    return {
      url = link,
      start_col = start_col + 1,
      end_col = end_col,
    }
  end
  return nil
end

local function follow_link()
  local word = find_word_under_cursor()
  local link = find_link_under_cursor() -- matches []() links only
  if link and link.url then
    if link.url:match('^https?://') then
      -- a link
      vim.ui.open(link.url)
    elseif link.url:match('^#') then
      -- an anchor
      vim.fn.search('^#* ' .. link.url:sub(2))
    else
      -- a file
      vim.cmd('e ' .. link.url)
    end
  elseif word then
    if word.text:match('^https?://') then
      -- Bare url i.e without link syntax
      vim.ui.open(word.text)
    else
      -- create a link
      local filename = string.lower(word.text:gsub('%s', '_') .. '.md')
      vim.cmd('norm! "_ciW[' .. word.text .. '](' .. filename .. ')')
    end
  end
end

vim.keymap.set('n', 'gx', function()
  follow_link()
end, { expr = true, noremap = true })

-- local test_telescope = function()
-- md_grep_telescope({
--   search_files = {
--     '/Users/rayxu/Library/CloudStorage/Dropbox/obsidian/work/cms.md',
--     '/Users/rayxu/Library/CloudStorage/Dropbox/obsidian/work/rec.md',
--   },
--   -- search_dirs = {
--   --   '/Users/rayxu/Library/CloudStorage/Dropbox/obsidian/work',
--   -- },
-- })
-- end

-- test_telescope()

return {
  fetch_and_paste_url_title = fetch_and_paste_url_title,
  parseFrontmatter = parseFrontmatter,
  md_search = md_search,
  md_files = md_files,
  follow_link = follow_link,
}
