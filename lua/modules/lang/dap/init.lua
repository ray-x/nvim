-- require('telescope').load_extension('dap')
local M={}
local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_args = bind.map_args




local function keybind()

  local keys = {
  -- DAP --
  -- 

  ["n|<leader><F5>"] = map_cr('<cmd>lua require"dap".continue()'):with_noremap():with_silent(),
  ["n|<leader><F10>"] = map_cr('<cmd>lua require"dap".step_over()'):with_noremap():with_silent(),
  ["n|<leader><F11>"] = map_cr('<cmd>lua require"dap".step_into()'):with_noremap():with_silent(),
  ["n|<leader><F12>"] = map_cr('<cmd>lua require"dap".step_out()'):with_noremap():with_silent(),
  ["n|<leader>ds"] = map_cr('<cmd>lua require"dap".stop()'):with_noremap():with_silent(),
  ["n|<leader>dk"] = map_cr('<cmd>lua require"dap".up()'):with_noremap():with_silent(),
  ["n|<leader>dj"] = map_cr('<cmd>lua require"dap".down()'):with_noremap():with_silent(),
  ["n|<leader><F9>"] = map_cr('<cmd>lua require"dap".toggle_breakpoint()'):with_noremap()
      :with_silent(),
  ["n|<leader>dsbr"] = map_cr(
      '<cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))'):with_noremap()
      :with_silent(),
  ["n|<leader>dsbm"] = map_cr(
      '<cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))'):with_noremap()
      :with_silent(),
  ["n|<leader>dro"] = map_cr('<cmd>:'):with_noremap():with_silent(),
  ["n|<leader>drl"] = map_cr('<cmd>lua require"dap".repl.run_last()'):with_noremap():with_silent(),
  -- ["n|[t"] = map_cr("lua require'nvim-treesitter-refactor.navigation'.goto_previous_usage(0)"):with_noremap():with_silent(),
  -- ["n|]t"] = map_cr("lua require'nvim-treesitter-refactor.navigation'.goto_next_usage(0)"):with_noremap():with_silent(),
  ["n|<leader>dcc"] = map_cr('<cmd>lua require"telescope".extensions.dap.commands{}'):with_noremap()
      :with_silent(),
  ["n|<leader>dco"] = map_cr('<cmd>lua require"telescope".extensions.dap.configurations{}'):with_noremap()
      :with_silent(),
  ["n|<leader>dlb"] = map_cr('<cmd>lua require"telescope".extensions.dap.list_breakpoints{}'):with_noremap()
      :with_silent(),
  ["n|<leader>dv"] = map_cr('<cmd>lua require"telescope".extensions.dap.variables{}'):with_noremap()
      :with_silent(),
  ["n|<leader>df"] = map_cr('<cmd>lua require"telescope".extensions.dap.frames{}'):with_noremap()
      :with_silent(),
  --
  }

  bind.nvim_load_mapping(keys)
  local keys = {
    -- DAP --
    -- run
    -- ["n|r"] = map_cr('<cmd>lua require"go.dap".run()<CR>'):with_noremap():with_silent(),

    ["n|c"] = map_cr('<cmd>lua require"dap".continue()<CR>'):with_noremap():with_silent(),
    ["n|n"] = map_cr('<cmd>lua require"dap".step_over()<CR>'):with_noremap():with_silent(),
    ["n|s"] = map_cr('<cmd>lua require"dap".step_into()<CR>'):with_noremap():with_silent(),
    ["n|o"] = map_cr('<cmd>lua require"dap".step_out()<CR>'):with_noremap():with_silent(),
    ["n|S"] = map_cr('<cmd>lua require"dap".stop()<CR>'):with_noremap():with_silent(),
    ["n|u"] = map_cr('<cmd>lua require"dap".up()<CR>'):with_noremap():with_silent(),
    ["n|D"] = map_cr('<cmd>lua require"dap".down()<CR>'):with_noremap():with_silent(),
    ["n|C"] = map_cr('<cmd>lua require"dap".run_to_cursor()<CR>'):with_noremap():with_silent(),
    ["n|b"] = map_cr('<cmd>lua require"dap".toggle_breakpoint()<CR>'):with_noremap():with_silent(),
    ["n|P"] = map_cr('<cmd>lua require"dap".pause()<CR>'):with_noremap():with_silent(),
    ["n|p"] = map_cr('<cmd>lua require"dap.ui.widgets".hover()<CR>'):with_noremap():with_silent(),
    ["v|p"] = map_cr('<cmd>lua require"dap.ui.variables".visual_hover()<CR>'):with_noremap()
        :with_silent()
    --
  }

  bind.nvim_load_mapping(keys)

end



local loader = require "packer".loader


-- if ft == 'go' then
--   require('modules.lang.dap.go')
-- end


M.prepare = function ()
  local loader = require "packer".loader
  loader('nvim-dap')
  loader('nvim-dap-ui')
  loader('nvim-dap-virtual-text')


  local ft = vim.bo.filetype
  print(ft)
  
  if ft == 'lua' then
    keys = {["n|<F5>"] = map_cr('<cmd>lua require"osv".launch()'):with_noremap():with_silent()}
    bind.nvim_load_mapping(keys)
    require('modules.lang.dap.lua')
  end
  if ft == 'rust' then
    require('modules.lang.dap.lua')
  end
  
  if ft == 'python' then
    require('modules.lang.dap.py')
  end
  
  if ft == 'typescript' or ft == 'javascript' then
    print("debug prepare for js")
    -- vim.cmd([[command! -nargs=*  Debug lua require"modules.lang.dap.jest".attach()]])
    vim.cmd([[command! -nargs=*  DebugTest lua require"modules.lang.dap.jest".run(<f-args>)]])
    require('modules.lang.dap.js')
  end

  vim.cmd([[command! BPToggle lua require"dap".toggle_breakpoint()]])
  vim.cmd([[command! Debug lua require"modules.lang.dap".StartDbg()]])

  require("dapui").setup()
  require("dapui").open()
end

M.StartDbg = function ()
  -- body
  keybind()
  require'dap'.continue()
end

M.StopDbg = function()
  local keys = {"r", "c", "n", "s", "o", "S", "u", "d", "C", "b", "P"}
  for _, value in pairs(keys) do
    local cmd = "unmap " .. value
    vim.cmd(cmd)
  end

  vim.cmd([[uvmap p]])
  require'dap'.disconnect()
  require'dap'.stop();
  require"dap".repl.close()
  require("dapui").close()
end

return M