local bind = require('keymap.bind')
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_args = bind.map_args
local global = require 'core.global'
require('keymap.config')

local plug_map = {
  -- ["i|<TAB>"]      = map_cmd('v:lua.tab_complete()'):with_expr():with_silent(),
  -- ["i|<S-TAB>"]    = map_cmd('v:lua.s_tab_complete()'):with_silent():with_expr(),
  -- ["s|<TAB>"]      = map_cmd('v:lua.tab_complete()'):with_expr():with_silent(),
  -- ["s|<S-TAB>"]    = map_cmd('v:lua.s_tab_complete()'):with_silent():with_expr(),
  -- person keymap
  -- ["n|mf"]             = map_cr("<cmd>lua require('internal.fsevent').file_event()<CR>"):with_silent():with_nowait():with_noremap();
  -- Lsp mapp work when insertenter and lsp start
  ["n|<leader>li"] = map_cr("LspInfo"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>ll"] = map_cr("LspLog"):with_noremap():with_silent():with_nowait(),
  ["n|<leader>lr"] = map_cr("LspRestart"):with_noremap():with_silent():with_nowait(),
  -- ["n|gt"]             = map_cmd("<cmd>lua vim.lsp.buf.type_definition()<CR>"):with_noremap():with_silent(),
  -- ["n|<Leader>cw"]     = map_cmd("<cmd>lua vim.lsp.buf.workspace_symbol()<CR>"):with_noremap():with_silent(),
  ["n|<Leader>ct"] = map_args("Template"),
  ["n|<Leader>tf"] = map_cu('DashboardNewFile'):with_noremap():with_silent(),
  -- Plugin nvim-tree
  -- ["n|<Leader>e"]      = map_cr('NvimTreeToggle'):with_noremap():with_silent(),
  ["n|<Leader>F"] = map_cr('NvimTreeFindFile'):with_noremap():with_silent(),
  -- Plugin MarkdownPreview
  ["n|<Leader>om"] = map_cu('MarkdownPreview'):with_noremap():with_silent(),
  -- Plugin DadbodUI
  ["n|<Leader>od"] = map_cr('DBUIToggle'):with_noremap():with_silent(),
  -- Plugin Telescope
  ["n|<Leader>bb"] = map_cu('Telescope buffers'):with_noremap():with_silent(),
  ["n|<Leader>fb"] = map_cu('Telescope file_browser'):with_noremap():with_silent(),
  ["n|<Leader>fg"] = map_cu('Telescope git_files'):with_noremap():with_silent(),
  ["n|<Leader>fw"] = map_cu('Telescope grep_string'):with_noremap():with_silent(),
  ["n|<Leader>fl"] = map_cu('Telescope loclist'):with_noremap():with_silent(),
  ["n|<Leader>fc"] = map_cu('Telescope git_commits'):with_noremap():with_silent(),
  ["n|<Leader>ft"] = map_cu('Telescope help_tags'):with_noremap():with_silent(),
  -- ["n|<Leader>fd"]     = map_cu('Telescope dotfiles path='..global..'/.dotfiles'):with_noremap():with_silent(),
  ["n|<Leader>fs"] = map_cu('Telescope gosource'):with_noremap():with_silent(),
  ["n|w"] = map_cmd('v:lua.word_motion_move("w")'):with_silent():with_expr(),

  -- Plugin QuickRun
  ["n|<Leader>r"] = map_cr("<cmd> lua require'internal.quickrun'.run_command()"):with_noremap():with_silent(),
  -- Plugin Vista
  ["n|<Leader>v"] = map_cu('Vista'):with_noremap():with_silent(),
  -- Plugin vim-operator-surround
  -- ["n|sa"]             = map_cmd("<Plug>(operator-surround-append)"):with_silent(),
  -- ["n|sd"]             = map_cmd("<Plug>(operator-surround-delete)"):with_silent(),
  -- ["n|sr"]             = map_cmd("<Plug>(operator-surround-replace)"):with_silent(),
  ["n|<F8>"] = map_cmd("call SideKickNoReload()"):with_silent()

};

bind.nvim_load_mapping(plug_map)
