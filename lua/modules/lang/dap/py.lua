local adaptor = function()
  local dap = require('dap')
  dap.configurations.python = {
    {
      -- The first three options are required by nvim-dap
      type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
      request = 'launch',
      name = 'Launch file',

      -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

      program = '${file}', -- This configuration will launch the current file if used.
      pythonPath = function()
        -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
        -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
        -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
          return cwd .. '/venv/bin/python'
        elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
          return cwd .. '/.venv/bin/python'
        else
          return '/usr/bin/python'
        end
      end,
    },
  }

  dap.adapters.python = {
    type = 'executable',
    command = '/usr/local/opt/python@3.9/bin/python3',
    args = { '-m', 'debugpy.adapter' },
  }
  return dap
end

local config = function()
  local ok, dap = pcall(require, 'dap-python')
  if not ok then
    return vim.notify('Could not load dap-python')
  end

  -- local ok, mason = pcall(require, 'mason-registry')
  -- if not ok then
  --   vim.notify('Could not load mason-registry')
  --   return
  -- end

  local python_path = '/usr/bin/python'
  if require('core.global').is_mac then
    python_path = '/usr/local/bin/python'
  end

  local venv = os.getenv('VIRTUAL_ENV')
  if venv then
    python_path = venv .. '/bin/python'
  end
  dap.setup(python_path) --- hard coded path to python

  vim.keymap.set('n', '<F9>', require('dap').toggle_breakpoint, { desc = 'toggle' })
  vim.api.nvim_create_user_command('DebugyStop', function()
    local keys = { 'n', 's', 'o', 'r', 'u', 'c' }
    for _, key in ipairs(keys) do
      vim.keymap.unset('n', key)
    end
    require('dap').dap.disconnect()
  end, { desc = 'DebugyStop', nargs = '*' })

  vim.api.nvim_create_user_command('Debugy', function()
    vim.keymap.set('n', '<leader>dn', require('dap-python').test_method, { desc = 'Test method' })
    vim.keymap.set('n', '<leader>df', require('dap-python').test_class, { desc = 'Test class' })
    vim.keymap.set(
      'v',
      '<leader>ds',
      require('dap-python').debug_selection,
      { desc = 'Debug selection' }
    )
    vim.keymap.set('n', 'r', require('dap').run, { desc = 'run' })
    vim.keymap.set('n', 'c', require('dap').continue, { desc = 'continue' })
    vim.keymap.set('n', 'n', require('dap').step_over, { desc = 'next' })
    vim.keymap.set('n', 's', require('dap').step_into, { desc = 'step' })
    vim.keymap.set('n', 'o', require('dap').step_out, { desc = 'out' })
    vim.keymap.set('n', 'u', require('dap').up, { desc = 'step up' })
    require('dap-python').test_method()
    -- require('dapui').toggle()
  end, { desc = 'Debugy', nargs = '*' })
end
return { config = config, adaptor = adaptor }
