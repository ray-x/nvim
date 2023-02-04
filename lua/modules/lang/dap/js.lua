-- https://alpha2phi.medium.com/neovim-lsp-and-dap-using-lua-3fb24610ac9f
local global = require('core.global')
local dap = require('dap')
dap.adapters.node2 = {
  type = 'executable',
  command = 'node',
  args = { global.home .. '/software/vscode-node-debug2/out/src/nodeDebug.js' },
}

dap.configurations.javascript = {
  {
    type = 'node2',
    request = 'launch',
    -- program = { os.getenv('HOME') .. '/workspace/development/alpha2phi/python-apps/debugging/hello.js'},
    program = '${workspaceFolder}/${file}',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal',
  },
}

dap.configurations.typescript = {
  {
    type = 'node2',
    request = 'launch',
    -- program = { os.getenv('HOME') .. '/workspace/development/alpha2phi/python-apps/debugging/hello.js'},
    program = '${workspaceFolder}/${file}',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal',
  },
}
