local bind = require("keymap.bind")
local map_cmd = bind.map_cmd
local map_func = bind.map_func
local loader = require("packer").loader
local K = {}
local function check_back_space()
  local col = vim.fn.col(".") - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
    return true
  else
    return false
  end
end

-- stylua: ignore start

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
  ["n|<M-h>"] = map_cmd("Clap history"):with_noremap():with_silent(),

  -- ["n|<Leader>fb"] = map_cu("Clap marks"):with_noremap():with_silent(),
  -- ["n|<Leader>ff"] = map_cu("Clap files ++finder=rg --ignore --hidden --files"):with_noremap():with_silent(),
  -- ["n|<Leader>fw"] = map_cu("Clap grep ++query=<Cword>"):with_noremap():with_silent(),
  -- ["n|<Leader>fu"] = map_cu("Clap git_diff_files"):with_noremap():with_silent(),
  -- ["n|<Leader>fv"] = map_cu("Clap grep ++query=@visual"):with_noremap():with_silent(),
  -- ["n|<Leader>fh"] = map_cu("Clap command_history"):with_noremap():with_silent(),

  ["n|<F5>"] = map_func(function()
      return _G.run_or_test(true)
    end)
    :with_expr()
    :with_desc("run or test"),
  ["n|<Leader>r"] = map_func(function() return _G.run_or_test() end):with_expr():with_desc("run or test"),

  ["v|<Leader>r"] = map_func(function() _G.run_or_test() end):with_expr():with_desc("run or test"),

  ["n|<Leader>R"] = map_func(function() _G.run_or_test(true) end):with_expr():with_desc("run or test"),
  ["v|<Leader>R"] = map_func(function() _G.run_or_test(true) end):with_expr():with_desc("run or test"),

  ["n|<Leader>bp"] = map_cmd("BufferLinePick"):with_noremap():with_silent(),

  ["n|<C-k>"] = map_cmd("v:lua.ctrl_k()"):with_silent():with_expr(),

  -- Plugin QuickRun
  -- ["n|<Leader>r"]     = map_cmd("<cmd> lua require'selfunc'.run_command()"):with_noremap():with_silent(),
  -- Plugin Vista
  -- ["n|<Leader>v"] = map_cu("Vista!!"):with_noremap():with_silent(),
  -- Plugin SplitJoin
  ["n|<Leader><Leader>s"] = map_cmd("SplitjoinSplit"),
  ["n|<Leader><Leader>j"] = map_cmd("SplitjoinJoin"),
  ["n|<F13>"] = map_cmd("NvimTreeToggle"),
  ["n|hW"] = map_cmd("HopWordBC"),
  ["n|hw"] = map_cmd("HopWordAC"),
  ["n|hl"] = map_cmd("HopLineStartAC"),
  ["n|hL"] = map_cmd("HopLineStartBC"),

  ["xon|f"] = map_cmd("lua  Line_ft('f')"),
  ["xon|F"] = map_cmd("lua  Line_ft('F')"),
  ["xon|t"] = map_cmd("lua  Line_ft('t')"),
  ["xon|T"] = map_cmd("lua  Line_ft('T')"),
  ["n|s"] = map_cmd("lua hop1(1)"):with_silent(),
  ["n|S"] = map_cmd("lua hop1()"):with_silent(),
  ["x|s"] = map_cmd("lua hop1(1)"):with_silent(),
  ["x|S"] = map_cmd("lua hop1()"):with_silent(),
  -- ["v|<M-s>"] = map_cmd("lua require'hop'.hint_char1()"):with_silent():with_expr(),
  -- ["n|<Space>s"] = map_cmd("HopChar2"),
  ["n|<M-s>"] = map_cmd("HopChar2AC"),
  ["n|<M-S>"] = map_cmd("HopChar2BC"),
  ["xv|<M-s>"] = map_cmd("HopChar2AC"):with_silent(),
  ["xv|<M-S>"] = map_cmd("HopChar2BC"):with_silent(),
  ["n|<Space>F"] = map_cmd("HopPattern"),
  ["n|<Space>]"] = map_cmd("HopChar1MW"),
  ["n|<Space>["] = map_cmd("HopChar2MW"),
  -- clap --
  ["n|<d-C>"] = map_cmd("Clap | startinsert"),
  ["i|<d-C>"] = map_cmd("Clap | startinsert"):with_noremap():with_silent(),
  ["n|<Leader>df"] = map_cmd("Clap dumb_jump ++query=<cword> | startinsert"),
  ["n|<F9>"] = map_cmd("GoBreakToggle"),

  -- swap
  ["n|<leader>a"] = map_cmd("ISwapWith"),
  ["n|<leader>A"] = map_cmd("ISwapNodeWith"),
  -- session
  -- ["n|<Leader>ss"] = map_cu('SessionSave'):with_noremap(),
  -- ["n|<Leader>sl"] = map_cu('SessionLoad'):with_noremap(),

  ["n|<Leader>bd"] = map_cmd([[lua require("close_buffers").delete({type='this'})]]),
  ["n|<Space>M"] = map_cmd([[lua require("harpoon.mark").toggle_file()]]),
  ["n|<Space>n"] = map_cmd([[lua require("harpoon.ui").nav_next()]]),
  ["n|<Space>p"] = map_cmd([[lua require("harpoon.ui").nav_prev()]]),
  -- ["n|<Space>m1"] = map_cmd([[lua require("harpoon.ui").nav_file(1)]]),
  ["n|<Space>m"] = map_cmd([[Telescope harpoon marks ]]),
  ["n|<Leader>N"] = map_func(function()
    require('close_buffers').wipe({ type = 'nameless', force = true })
    vim.cmd([[nohl]])
  end),
  ["v|<Leader>re"] = map_cmd("<esc>lua require('refactoring').refactor('Extract Function')"),
  ["v|<Leader>rf"] = map_cmd("<esc>lua require('refactoring').refactor('Extract Function To File')"),
  ["v|<Leader>rt"] = map_cmd("<esc>lua require('refactoring').refactor()"),

  ["v|<Leader>gs"] = map_cmd("lua require('utils.git').qf_add()"),

  ["n|<F10>"] = {
    cmd = function()
      if vim.o.conceallevel > 0 then
        vim.o.conceallevel = 0
      else
        vim.o.conceallevel = 2
      end
    end,
    options = { noremap = true, silent = true, desc = "toggle concel" },
  },
  ["n|<F11>"] = {
    cmd = function()
      if vim.o.concealcursor == "n" then
        vim.o.concealcursor = ""
      else
        vim.o.concealcursor = "n"
      end
    end,
    options = { noremap = true, silent = true, desc = "toggle concelcursor" },
  },

  -- -- Add word to search then replace
  -- vim.keymap.set('n', '<Leader>j', [[let @/='\<'.expand('<cword>').'\>'"_ciw]])
  --
  -- -- Add selection to search then replace
  -- vim.keymap.set('x', '<Leader>j', [[ylet @/=substitute(escape(@", '/'), '\n', '\\n', 'g')"_cgn]])
}

-- stylua: ignore end
--
vim.cmd([[vnoremap  <leader>y  "+y]])
vim.cmd([[nnoremap  <leader>Y  "+yg_]])
-- vim.cmd([[vnoremap  <M-c>  "+y]])
-- vim.cmd([[nnoremap  <M-c>  "+yg_]])

vim.cmd([[vnoremap  <D-c>  *+y]])
vim.cmd([[nnoremap  <D-c>  *+yg_]])
vim.cmd([[inoremap  <D-c>  *+yg_]])
vim.cmd([[inoremap  <D-v>  <CTRL-r>*]])
--

_G.run_or_test = function(debug)
  -- local function rot()
  local ft = vim.bo.filetype
  local fn = vim.fn.expand("%")
  fn = string.lower(fn)
  -- if fn == "[nvim-lua]" then
  --   if not packer_plugins["nvim-luadev"].loaded then
  --     loader("nvim-luadev")
  --   end
  --   return [[<Plug>Luadev-Run]]
  -- end
  if ft == "lua" then
    local f = string.find(fn, "spec")
    if f == nil then
      -- let run lua test
      return "<CMD>luafile %<CR>"
    end
    return "<Plug>PlenaryTestFile"
  end
  if ft == "go" then
    local f = string.find(fn, "test.go")
    if f == nil then
      -- let run lua test
      if debug then
        return "<CMD>GoDebug <CR>"
      else
        return "<CMD>GoRun<CR>"
      end
    end

    if debug then
      return "<CMD>GoDebug -t<CR>"
    else
      return "<CMD>GoTestFunc -F<CR>"
    end
  end
  local m = vim.fn.mode()
  if m == "n" or m == "i" then
    require("sniprun").run()
  else
    require("sniprun").run("v")
  end
end

_G.hop1 = function(ac)
  if packer_plugins["hop"].loaded ~= true then
    loader("hop")
  end
  if vim.fn.mode() == "s" then
    -- print(vim.fn.mode(), vim.fn.mode() == 's')
    return vim.cmd('exe "normal! i s"')
  end

  if ac == 1 then
    require("hop").hint_char1({ direction = require("hop.hint").HintDirection.AFTER_CURSOR })
  else
    require("hop").hint_char1({ direction = require("hop.hint").HintDirection.BEFORE_CURSOR })
  end
end

_G.Line_ft = function(a)
  if packer_plugins["hop"].loaded ~= true then
    loader("hop")
  end
  if vim.fn.mode() == "s" then
    return vim.fn.input(a)
  end
  -- check and load hop
  local loaded, hop = pcall(require, "hop")
  if not loaded or not hop.initialized then
    require("packer").loader("hop")
    loaded, hop = pcall(require, "hop")
  end
  if a == "f" then
    require("hop").hint_char1({
      direction = require("hop.hint").HintDirection.AFTER_CURSOR,
      current_line_only = true,
    })
  end
  if a == "F" then
    require("hop").hint_char1({
      direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
      current_line_only = true,
    })
  end

  if a == "t" then
    require("hop").hint_char1({
      direction = require("hop.hint").HintDirection.AFTER_CURSOR,
      current_line_only = true,
      hint_offset = -1,
    })
  end
  if a == "T" then
    require("hop").hint_char1({
      direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
      current_line_only = true,
      hint_offset = 1,
    })
  end
end

vim.cmd([[command! -nargs=*  DebugOpen lua require"modules.lang.dap".prepare()]])
vim.cmd([[command! -nargs=*  Format lua vim.lsp.buf.format({async=true}) ]])
vim.cmd([[command! -nargs=*  HpoonClear lua require"harpoon.mark".clear_all()]])

local plugmap = require("keymap").map
local merged = vim.tbl_extend("force", plugmap, keys)

bind.nvim_load_mapping(merged)
local key_maps = bind.all_keys

K.get_keymaps = function()
  local ListView = require("guihua.listview")
  local win = ListView:new({
    loc = "top_center",
    border = "none",
    prompt = true,
    enter = true,
    rect = { height = 20, width = 90 },
    data = key_maps,
  })
end

vim.cmd([[command! -nargs=* Keymaps lua require('overwrite.mapping').get_keymaps()]])

vim.api.nvim_create_user_command("Jsonfmt", function(opts)
  vim.cmd([[silent! %s/\\"/"/g]])
  vim.cmd([[w]])
  if vim.fn.executable("jq") == 0 then
    lprint("jq not found")
    return vim.cmd([[%!python -m json.tool]])
  end
  vim.cmd("%!jq")
end, { nargs = "*" })

vim.api.nvim_create_user_command("NewOrg", function(opts)
  local fn = vim.fn.strftime("%Y_%m_%d") .. ".org"
  if vim.fn.empty(opts.args) == 0 then
    fn = opts.args[1] or fn
  end
  vim.cmd("e " .. fn)
  vim.api.nvim_buf_set_lines(
    0,
    0,
    4,
    false,
    { "#+TITLE: ", "#+AUTHER: Ray", "#+Date:" .. vim.fn.strftime("%c"), "", "* 1st", "* 2nd" }
  )
end, { nargs = "*" })

vim.api.nvim_create_user_command("Flg", "Flog -date=short", { nargs= "*" } )
vim.api.nvim_create_user_command("Flgs", "Flogsplit -date=short", {})

-- Use `git ls-files` for git files, use `find ./ *` for all files under work directory.
--
return K
