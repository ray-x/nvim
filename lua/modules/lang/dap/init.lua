-- require('telescope').load_extension('dap')
local M = {}
local bind = require("keymap.bind")
local map_cr = bind.map_cr
-- local map_cu = bind.map_cu
-- local map_cmd = bind.map_cmd
-- local map_args = bind.map_args

local function keybind()

  local keys = {

    ["n|<leader><F5>"] = require"dap".continue,
    ["n|<leader><F10>"] = require"dap".step_over,
    ["n|<leader><F11>"] = require"dap".step_into,
    ["n|<leader><F12>"] = require"dap".step_out,
    ["n|<leader>ds"] = require"dap".stop,
    ["n|<leader>dk"] = require"dap".up,
    ["n|<leader>dj"] = require"dap".down,
    ["n|<leader><F9>"] = require"dap".toggle_breakpoint,
    ["n|<leader>dsbr"] = function()require"dap".set_breakpoint(vim.fn.input("breakpoint condition: "))end,
    ["n|<leader>dsbm"] = function() require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))end,
    ["n|<leader>dro"] = map_cr('<cmd>:'):with_noremap():with_silent(),
    ["n|<leader>drl"] = require"dap".repl.run_last,
    -- ["n|[t"] = map_cr("lua require'nvim-treesitter-refactor.navigation'.goto_previous_usage(0)"):with_noremap():with_silent(),
    -- ["n|]t"] = map_cr("lua require'nvim-treesitter-refactor.navigation'.goto_next_usage(0)"):with_noremap():with_silent(),
    ["n|<leader>dcc"] = require"telescope".extensions.dap.commands,
    ["n|<leader>dco"] = map_cr('<cmd>lua require"telescope".extensions.dap.configurations{}'):with_noremap()
        :with_silent(),
    ["n|<leader>dlb"] = map_cr('<cmd>lua require"telescope".extensions.dap.list_breakpoints{}'):with_noremap()
        :with_silent(),
    ["n|<leader>dv"] = require"telescope".extensions.dap.variables,
    ["n|<leader>df"] = require"telescope".extensions.dap.frames
    --
  }

  bind.nvim_load_mapping(keys)
  local dap_keys = {
    -- DAP --
    -- run
    -- ["n|r"] = map_cr('<cmd>lua require"go.dap".run()<CR>'):with_noremap():with_silent(),

    ["n|c"] = require"dap".continue,
    ["n|n"] = require"dap".step_over,
    ["n|s"] = require"dap".step_into,
    ["n|o"] = require"dap".step_out,
    ["n|S"] = require"dap".stop,
    ["n|u"] = require"dap".up,
    ["n|D"] = require"dap".down,
    ["n|C"] = require"dap".run_to_cursor,
    ["n|b"] = require"dap".toggle_breakpoint,
    ["n|P"] = require"dap".pause,
    ["n|p"] = require"dap.ui.widgets".hover,
    ["v|p"] = require"dap.ui.variables".visual_hover,
    ["n|<Leader>di"] = require'dap.ui.variables'.hover,
  }

  bind.nvim_load_mapping(dap_keys)

end

local loader = require"packer".loader

-- if ft == 'go' then
--   require('modules.lang.dap.go')
-- end

M.prepare = function()
  loader('nvim-dap')
  loader('nvim-dap-ui')
  loader('nvim-dap-virtual-text')

  local ft = vim.bo.filetype
  print(ft)

  if ft == 'lua' then
    local keys = {
      ["n|<F5>"] = require"osv".launch
    }
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

M.StartDbg = function()
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
