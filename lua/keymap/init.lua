local bind = require("keymap.bind")
local map_cmd = bind.map_cmd
-- local map_func = bind.map_func
local map_key = bind.map_key
require("keymap.config")

local plug_map = {
  ["i|<TAB>"] = map_cmd("v:lua.tab_complete()"):with_expr():with_silent(),
  ["i|<S-TAB>"] = map_cmd("v:lua.s_tab_complete()"):with_silent():with_expr(),
  ["s|<TAB>"] = map_cmd("v:lua.tab_complete()"):with_expr():with_silent(),
  ["s|<S-TAB>"] = map_cmd("v:lua.s_tab_complete()"):with_silent():with_expr(),
  -- person keymap
  ["n|<leader>li"] = map_cmd("LspInfo"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>ll"] = map_cmd("LspLog"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>lr"] = map_cmd("LspRestart"):with_noremap():with_silent():with_nowait(),
  -- ["n|<Leader>e"]      = map_cmd('NvimTreeToggle'):with_noremap():with_silent(),
  -- ["n|<Leader>F"] = map_cmd('NvimTreeFindFile'):with_noremap():with_silent(),
  -- Plugin MarkdownPreview
  ["n|<Leader>om"] = map_cmd("MarkdownPreview"):with_noremap():with_silent(),
  -- Plugin DadbodUI
  ["n|<Leader>od"] = map_cmd("DBUIToggle"):with_noremap():with_silent(),
  -- Plugin Telescope
  ["i|<M-r>"] = map_cmd("Telescope registers"):with_noremap():with_silent(),
  ["n|<M-P>"] = map_cmd(
    'lua require("telescope").extensions.frecency.frecency({ sorter = require("telescope").extensions.fzf.native_fzf_sorter(),default_text=":CWD:" })'
  ):with_silent(),

  ["in|<d-p>"] = map_cmd("Telescope find_files"):with_noremap():with_silent(),
  ["in|<M-p>"] = map_cmd("Telescope find_files"):with_noremap():with_silent(),
  -- ["in|<d-T>"] = map_cu("Telescope"):with_noremap():with_silent(),
  ["in|<M-f>"] = map_cmd([[lua require"utils.telescope".grep_string_cursor_raw()]]):with_noremap():with_silent(),
  ["in|<d-F>"] = map_cmd([[lua require"utils.telescope".grep_string_cursor()]]):with_noremap():with_silent(),
  ["v|<d-F>"] = map_cmd([[lua require"utils.telescope".grep_string_viusal()]]):with_noremap():with_silent(),
  ["in|<d-f>"] = map_cmd([[lua require"utils.telescope".grep_string_cursor_raw()]]):with_noremap():with_silent(),
  ["v|<d-f>"] = map_cmd([[lua require"utils.telescope".grep_string_visual_raw()]]):with_expr():with_silent(),
  ["n|w"] = map_cmd('v:lua.word_motion_move("w")'):with_silent():with_expr(),

  ["n|<Leader>do"] = map_cmd("DiffviewOpen"):with_noremap():with_silent(),
  ["n|<Leader>dc"] = map_cmd("DiffviewClose"):with_noremap():with_silent(),
  ["n|<Leader>ng"] = map_cmd("Neogit"):with_noremap():with_silent(),

  -- Plugin QuickRun
  -- Plugin Vista
  ["n|<Leader>v"] = map_cmd("TSymbols"):with_noremap():with_silent(),
  ["n|<F8>"] = map_cmd("LspSymbols"):with_silent(),

  ["x|<Leader>c<Space>"] = map_key("gc"),
  ["n|<Leader>c<Space>"] = map_key("gcc"),
  -- ["n|<Leader>c<Space>"] = map_cmd("<CMD>lua require'Comment.api'.toggle_linewise_op()<CR>"):with_silent(),
  ["n|<d-/>"] = map_cmd("lua require'Comment.api'.toggle_current_linewise({})"):with_silent(),
  ["i|<d-/>"] = map_cmd("lua require'Comment.api'.toggle_current_linewise({})"):with_silent(),
  ["x|<d-/>"] = map_cmd("lua require'Comment.api'.toggle_linewise_op(vim.fn.visualmode())"):with_silent(),

  ["n|<m-/>"] = map_cmd("lua require'Comment.api'.toggle_current_linewise({})"):with_silent(),
  ["i|<m-/>"] = map_cmd("lua require'Comment.api'.toggle_current_linewise({})"):with_silent(),
  ["x|<m-/>"] = map_cmd("lua require'Comment.api'.toggle_linewise_op(vim.fn.visualmode())"):with_silent(),
}

return { map = plug_map }

-- bind.nvim_load_mapping(plug_map)
