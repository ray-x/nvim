-- local dap = require "dap"
-- dap.adapters.go = function(callback, config)
--     local handle
--     local pid_or_err
--     local port = 38697
--     handle, pid_or_err =
--     vim.loop.spawn(
--     "dlv",
--     {
--         args = {"dap", "-l", "127.0.0.1:" .. port},
--         detached = true
--     },
--     function(code)
--         handle:close()
--         print("Delve exited with exit code: " .. code)
--     end
--     )
--     ----should we wait for delve to start???
--     --vim.defer_fn(
--     --function()
--     --dap.repl.open()
--     --callback({type = "server", host = "127.0.0.1", port = port})
--     --end,
--     --100)
-- dap.repl.open()
--     callback({type = "server", host = "127.0.0.1", port = port})
-- end
-- -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
-- dap.configurations.go = {
--     {
--         type = "go",
--         name = "Debug",
--         request = "launch",
--         program = "${file}"
--     }
-- }
-- require('telescope').load_extension('dap')
-- require('dbg.go')

local dap = require"dap"
dap.configurations.lua = { 
  { 
    type = 'nlua', 
    request = 'attach',
    name = "Attach to running Neovim instance",
    host = function()
      local value = vim.fn.input('Host [127.0.0.1]: ')
      if value ~= "" then
        return value
      end
      return '127.0.0.1'
    end,
    port = function()
      local val = tonumber(vim.fn.input('Port: '))
      assert(val, "Please provide a port number")
      return val
    end,
  }
}

dap.adapters.nlua = function(callback, config)
  callback({ type = 'server', host = config.host, port = config.port })
end

-- lua require'dap'.continue() 