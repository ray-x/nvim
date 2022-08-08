local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_key = bind.map_key
require("keymap.config")

local plug_map = {
  ["i|<TAB>"] = map_cmd("v:lua.tab_complete()"):with_expr():with_silent(),
  ["i|<S-TAB>"] = map_cmd("v:lua.s_tab_complete()"):with_silent():with_expr(),
  ["s|<TAB>"] = map_cmd("v:lua.tab_complete()"):with_expr():with_silent(),
  ["s|<S-TAB>"] = map_cmd("v:lua.s_tab_complete()"):with_silent():with_expr(),
  -- person keymap
  -- ["n|mf"]             = map_cr("<cmd>lua require('internal.fsevent').file_event()<CR>"):with_silent():with_nowait():with_noremap();
  -- Lsp mapp work when insertenter and lsp start
  ["n|<leader>li"] = map_cr("LspInfo"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>ll"] = map_cr("LspLog"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>lr"] = map_cr("LspRestart"):with_noremap():with_silent():with_nowait(),
  -- ["n|<Leader>e"]      = map_cr('NvimTreeToggle'):with_noremap():with_silent(),
  -- ["n|<Leader>F"] = map_cr('NvimTreeFindFile'):with_noremap():with_silent(),
  -- Plugin MarkdownPreview
  ["n|<Leader>om"] = map_cu("MarkdownPreview"):with_noremap():with_silent(),
  -- Plugin DadbodUI
  ["n|<Leader>od"] = map_cr("DBUIToggle"):with_noremap():with_silent(),
  -- Plugin Telescope
  ["i|<M-r>"] = map_cmd("<cmd>Telescope registers<cr>"):with_noremap():with_silent(),
  ["n|<M-P>"] = map_cr(
    '<cmd>lua require("telescope").extensions.frecency.frecency({ sorter = require("telescope").extensions.fzf.native_fzf_sorter(),default_text=":CWD:" })'
  ):with_silent(),

  -- ["n|<Leader>bb"] = map_cu("Telescope buffers"):with_noremap():with_silent(),
  -- ["n|<Leader>fb"] = map_cu("Telescope file_browser"):with_noremap():with_silent(),
  -- ["n|<Leader>fg"] = map_cu("Telescope git_files"):with_noremap():with_silent(),
  -- ["n|<Leader>fr"] = map_cmd("<cmd>Telescope registers<cr>"):with_noremap():with_silent(),
  -- ["n|<Leader>fj"] = map_cmd('<cmd>lua require"utils.telescope".jump()<CR>'):with_noremap():with_silent(),
  -- ["n|<Leader>fl"] = map_cr('<cmd>lua require("telescope").extensions.neoclip.default()'):with_silent(),
  -- ["n|<Leader>fz"] = map_cr('<cmd>lua require("telescope").extensions.zoxide.list()'):with_silent(),
  -- ["n|<Leader>fp"] = map_cr('<cmd>lua require("telescope").extensions.projects.projects()'):with_silent(),
  -- ["n|<Leader>fw"] = map_cu("Telescope grep_string"):with_noremap():with_silent(),
  -- -- ["n|<Leader>fl"] = map_cu("Telescope loclist"):with_noremap():with_silent(),
  -- ["n|<Leader>fc"] = map_cu("Telescope git_commits"):with_noremap():with_silent(),
  -- ["n|<Leader>ft"] = map_cu("Telescope help_tags"):with_noremap():with_silent(),
  -- ["n|<Leader>fs"] = map_cu("Telescope gosource"):with_noremap():with_silent(),
  -- GUI, kitty

  ["in|<d-p>"] = map_cu("Telescope find_files"):with_noremap():with_silent(),
  ["in|<M-p>"] = map_cu("Telescope find_files"):with_noremap():with_silent(),
  -- ["in|<d-T>"] = map_cu("Telescope"):with_noremap():with_silent(),
  ["in|<M-f>"] = map_cr([[<cmd>lua lua require"utils.telescope".grep_string_cursor_raw()]])
    :with_noremap()
    :with_silent(),
  ["in|<d-F>"] = map_cr([[<cmd>lua require"utils.telescope".grep_string_cursor()]]):with_noremap():with_silent(),
  ["v|<d-F>"] = map_cr([[<cmd>lua require"utils.telescope".grep_string_viusal()]]):with_noremap():with_silent(),
  ["in|<d-f>"] = map_cr([[<cmd>lua require"utils.telescope".grep_string_cursor_raw()]]):with_noremap():with_silent(),
  ["v|<d-f>"] = map_cr([[<cmd>lua require"utils.telescope".grep_string_visual_raw()]]):with_expr():with_silent(),
  ["n|w"] = map_cmd('v:lua.word_motion_move("w")'):with_silent():with_expr(),

  ["n|<Leader>do"] = map_cu("DiffviewOpen"):with_noremap():with_silent(),
  ["n|<Leader>dc"] = map_cu("DiffviewClose"):with_noremap():with_silent(),
  ["n|<Leader>ng"] = map_cu("Neogit"):with_noremap():with_silent(),

  -- Plugin QuickRun
  -- Plugin Vista
  ["n|<Leader>v"] = map_cu("TSymbols"):with_noremap():with_silent(),
  ["n|<F8>"] = map_cu("LspSymbols"):with_silent(),

  ["x|<Leader>c<Space>"] = map_key("gc"),
  ["n|<Leader>c<Space>"] = map_key("gcc"),
  -- ["n|<Leader>c<Space>"] = map_cmd("<CMD>lua require'Comment.api'.toggle_linewise_op()<CR>"):with_silent(),
  ["n|<d-/>"] = map_cmd("<ESC><CMD>lua require'Comment.api'.toggle_current_linewise({})<CR>"):with_silent(),
  ["i|<d-/>"] = map_cmd("<ESC><CMD>lua require'Comment.api'.toggle_current_linewise({})<CR>"):with_silent(),
  ["x|<d-/>"] = map_cmd("<ESC><CMD>lua require'Comment.api'.toggle_linewise_op(vim.fn.visualmode())<CR>"):with_silent(),

  ["n|<m-/>"] = map_cmd("<ESC><CMD>lua require'Comment.api'.toggle_current_linewise({})<CR>"):with_silent(),
  ["i|<m-/>"] = map_cmd("<ESC><CMD>lua require'Comment.api'.toggle_current_linewise({})<CR>"):with_silent(),
  ["x|<m-/>"] = map_cmd("<ESC><CMD>lua require'Comment.api'.toggle_linewise_op(vim.fn.visualmode())<CR>"):with_silent(),
}

return { map = plug_map }

-- bind.nvim_load_mapping(plug_map)
