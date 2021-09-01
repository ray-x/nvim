local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_args = bind.map_args
K = {}
local function check_back_space()
  local col = vim.fn.col(".") - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
    return true
  else
    return false
  end
end

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local keys = {
  -- ["n|F13"]  = map_cmd("<S-F1>"),
  -- ["n|F14"]  = map_cmd("<S-F2>"),
  -- ["n|F15"]  = map_cmd("<S-F3>"),
  -- ["n|F16"]  = map_cmd("<S-F4>"),
  -- ["n|F17"]  = map_cmd("<S-F5>"),
  -- ["n|F18"]  = map_cmd("<S-F6>"),
  -- ["n|F19"]  = map_cmd("<S-F7>"),
  -- ["n|F20"]  = map_cmd("<S-F8>"),
  -- ["n|F21"]  = map_cmd("<S-F9>"),
  -- ["n|F22"]  = map_cmd("<S-F10>"),
  -- ["n|F23"]  = map_cmd("<S-F11>"),
  -- ["n|F24"]  = map_cmd("<S-F12>"),
  --
  --
  -- pack?
  -- ["n|<Leader>tr"]     = map_cr("call dein#recache_runtimepath()"):with_noremap():with_silent(),
  -- ["n|<Leader>tf"]     = map_cu('DashboardNewFile'):with_noremap():with_silent(),
  -- gitsign?
  ["n|[g"] = map_cr('<cmd> lua require"gitsigns".prev_hunk()'):with_noremap():with_silent(),
  ["n|]g"] = map_cr('<cmd> lua require"gitsigns".next_hunk()'):with_noremap():with_silent(),
  --
  -- Lsp mapp work when insertenter and lsp start
  --
  -- ["n|<Leader>tc"] = map_cu("Clap colors"):with_noremap():with_silent(),
  ["n|<Leader>bb"] = map_cu("Clap buffers"):with_noremap():with_silent(),
  ["n|<Leader>ff"] = map_cu("Clap grep"):with_noremap():with_silent(),
  ["n|<Leader>fb"] = map_cu("Clap marks"):with_noremap():with_silent(),
  ["n|<C-x><C-f>"] = map_cu("Clap filer"):with_noremap():with_silent(),
  ["n|<Leader>ff"] = map_cu("Clap files ++finder=rg --ignore --hidden --files"):with_noremap()
      :with_silent(),
  ["n|<M-g>"] = map_cu("Clap gfiles"):with_noremap():with_silent(),
  ["n|<Leader>fw"] = map_cu("Clap grep ++query=<Cword>"):with_noremap():with_silent(),
  ["n|<M-h>"] = map_cu("Clap history"):with_noremap():with_silent(),
  ["n|<Leader>fW"] = map_cu("Clap windows"):with_noremap():with_silent(),
  ["n|<Leader>fl"] = map_cu("Clap loclist"):with_noremap():with_silent(),
  ["n|<Leader>fu"] = map_cu("Clap git_diff_files"):with_noremap():with_silent(),
  ["n|<Leader>fv"] = map_cu("Clap grep ++query=@visual"):with_noremap():with_silent(),
  ["n|<Leader>fd"] = map_cu("Clap dotfiles"):with_noremap():with_silent(),
  ["n|<Leader>bp"] = map_cu("BufferLinePick"):with_noremap():with_silent(),
  ["n|<Leader>fh"] = map_cu("Clap command_history"):with_noremap():with_silent(),
  ["n|<Leader><Leader>r"] = map_cmd("v:lua.run_or_test()"):with_expr(),
  ["v|<Leader><Leader>r"] = map_cmd("v:lua.run_or_test()"):with_expr(),
  ["n|<Leader>di"] = map_cr("<cmd>lua require'dap.ui.variables'.hover()"):with_expr(),
  ["n|<Leader>di"] = map_cr("<cmd>lua require'dap.ui.widgets'.hover()"):with_expr(), -- TODO: another key?

  ["v|<Leader>di"] = map_cr("<cmd>lua require'dap.ui.variables'.visual_hover()"):with_expr(),

  -- Plugin QuickRun
  -- ["n|<Leader>r"]     = map_cr("<cmd> lua require'selfunc'.run_command()"):with_noremap():with_silent(),
  -- Plugin Vista
  ["n|<Leader>v"] = map_cu("Vista!!"):with_noremap():with_silent(),
  -- Plugin SplitJoin
  ["n|<Leader><Leader>s"] = map_cr("SplitjoinSplit"),
  ["n|<Leader><Leader>j"] = map_cr("SplitjoinJoin"),
  ["n|<F13>"] = map_cr("NvimTreeToggle"),
  ["n|hW"] = map_cr("HopWordBC"),
  ["n|hw"] = map_cr("HopWordAC"),
  ["n|hl"] = map_cr("HopLineStartAC"),
  ["n|hL"] = map_cr("HopLineStartBC"),
  ["n|s"] = map_cr("HopChar1AC"),
  ["n|S"] = map_cr("HopChar1BC"),
  ["v|s"] = map_cr("HopChar1AC"),
  ["v|S"] = map_cr("HopChar1BC"),
  -- ["n|<Space>s"] = map_cr("HopChar2"),
  ["n|<Space>s"] = map_cr("HopChar2AC"),
  ["n|<Space>S"] = map_cr("HopChar2BC"),
  ["n|<Space>F"] = map_cr("HopPattern"),
  ["n|<Space>]"] = map_cr("HopPatternAC"),
  ["n|<Space>["] = map_cr("HopPatternBC")
}
--
-- undo leader mapping
vim.g.mapleader = "\\"
vim.cmd([[vnoremap  <leader>y  "+y]])
vim.cmd([[nnoremap  <leader>Y  "+yg_]])
vim.cmd([[vnoremap  <M-c>  "+y]])
vim.cmd([[nnoremap  <M-c>  "+yg_]])

-- vim.cmd([[nunmap j]])
-- vim.cmd([[nunmap k]])
-- vim.cmd([[unmap <Leader>ss]])
-- vim.cmd([[unmap <Leader>sl]])
-- vim.cmd([[xunmap I]])
-- vim.cmd([[xunmap gI]])
-- vim.cmd([[xunmap A]])
--
-- vim.cmd([[nmap ; <Plug>Sneak_;]])
--
--
bind.nvim_load_mapping(keys)

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

_G.run_or_test = function(...)
  -- if not packer_plugins["nvim-luadev"].loaded then
  --   vim.cmd [[packadd nvim-luadev]]
  -- end
  local ft = vim.bo.filetype
  local fn = vim.fn.expand("%")
  if fn == "[nvim-lua]" then
    return t("<Plug>(Luadev-Run)")
  end
  if ft == "lua" then
    local f = string.find(fn, "spec")
    if f == nil then
      -- let run lua test
      return t("<cmd>luafile %<CR>")
    end
    return t("<Plug>PlenaryTestFile")
  end
end

vim.cmd([[command! -nargs=*  DebugOpen lua require"modules.lang.dap".prepare()]])
-- Use `git ls-files` for git files, use `find ./ *` for all files under work directory.
vim.cmd(
    [[command! FR let old = expand("<cword>") | let rep = input("Replace " . old . " with: ", old) | execute ":FloatermNew --height=0.95 --width=0.95  git ls-files  | sad " . old . " " . rep ]])

--
return K
