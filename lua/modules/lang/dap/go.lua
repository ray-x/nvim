local dap = require "dap"
dap.adapters.go = function(callback, config)
  local handle
  local pid_or_err
  local port = 38697
  handle, pid_or_err = vim.loop.spawn("dlv", {
    args = {"dap", "-l", "127.0.0.1:" .. port},
    detached = true
  }, function(code)
    handle:close()
    print("Delve exited with exit code: " .. code)
  end)
  -- Wait 100ms for delve to start
  vim.defer_fn(function()
    dap.repl.open()
    callback({type = "server", host = "127.0.0.1", port = port})
  end, 100)
end
-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {type = "go", name = "Debug", request = "launch", program = "${file}"}, {
    type = "go",
    name = "Debug test",
    request = "launch",
    mode = "test", -- Mode is important
    program = "${file}"
  }
}

dap.continue()