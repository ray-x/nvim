local dap = require "dap"
dap.adapters.rust = {
    type = 'executable',
    attach = {
        pidProperty = "pid",
        pidSelect = "ask"
    },
    command = 'lldb-vscode', -- my binary was called 'lldb-vscode-11'
    env = {
        LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES"
    },
    name = "lldb"
}
dap.configurations.rust = {
    {
        type = "rust",
        name = "Debug",
        request = "launch",
        program= vim.fn.expand("$HOME")  .. "/workspace/development/rust-app/target/debug/myapp1"
    }
}


require('telescope').load_extension('dap')
require('dbg.rust')