-- stylua: ignore start
local filetypes = { 'html', 'css', 'javascript', 'java', 'javascriptreact', 'vue', 'typescript', 'typescriptreact', 'go',
  'lua', 'cpp', 'c', 'markdown', 'makefile', 'python', 'bash', 'sh', 'php', 'yaml', 'json', 'sql', 'vim', 'sh',
}
-- stylua: ignore end

return function(use)
  local dev = _G.is_dev()
  local spec = require('modules.spec')

  use({
    'neovim/nvim-lspconfig',
    config = function()
      local conf = require('modules.completion.config')
      conf.nvim_lsp()
      conf.native_completion()
    end,
    lazy = false,
  })

  if false then
    use({
      _G.plugin_path('ray-x/cmd-history.nvim'),

      lazy = false,
      event = { 'InsertEnter', 'CmdlineEnter' },
      config = function()
        require('cmd_history').setup()
      end,
    })
  end

  use = spec.wrap_register(use, spec.not_diff)

  use({
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    module = true,
    config = function()
      require('modules.completion.config').autopairs()
    end,
  })

  --
  -- can not lazyload, it is also slow...
  use({
    'L3MON4D3/LuaSnip', -- need to be the first to load
    event = 'InsertEnter',
    dependencies = { 'rafamadriz/friendly-snippets', module = false, event = 'InsertEnter' }, -- , event = "InsertEnter"
    module = true,
    config = function()
      require('modules.completion.luasnip')
    end,
  })
  use({
    'kristijanhusak/vim-dadbod-completion',
    -- event = 'InsertEnter',
    ft = { 'sql' },
    init = function()
      -- vim.cmd([[autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni]])
      -- vim.cmd(
      --   [[autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }, {name = 'buffer'}, {name = 'treesitter'}} })]]
      -- )
    end,
  })

  if false then
    use({
      'mattn/emmet-vim',
      event = 'InsertEnter',
      -- stylua: ignore start
      ft = { 'html', 'css', 'javascript', 'javascriptreact', 'vue', 'typescript', 'typescriptreact',
        'scss', 'sass', 'less', 'jade', 'haml', 'elm', },
      -- stylua: ignore end
      init = function()
        local conf = require('modules.completion.config')
        conf.emmet()
      end,
    })
  end

  use({
    _G.plugin_path('ray-x/copilot-agent.nvim'),
    lazy = false,

    opts = function()
      -- if true then
      -- require('copilot_agent').setup({})
      -- return {}
      -- end
      return {
        -- base_url = 'http://127.0.0.1:8088',
        client_name = 'harness-agent',
        permission_mode = 'approve-all',
        default_provider = 'copilot', -- 'claude', -- or 'copilot'
        file_log_level = 'DEBUG',
        service = {
          auto_start = true,
          command = { 'go', 'run', '.' },
          log = {
            enabled = true,
          },
        },
        chat = {
          reasoning = { enabled = true, max_lines = 4 },
        },
        lsp = {
          enabled = true,
        },
        session = {
          model = 'gpt-5.4-mini',
          working_directory = function()
            return vim.fn.getcwd()
          end,
        },
      }
    end,
  })

  -- note: part of the code is used in navigator
  use({
    _G.plugin_path('ray-x/lsp_signature.nvim'),

    event = { 'InsertEnter' },
    opts = {
      debug = plugin_debug(), -- log output
      verbose = plugin_debug(), -- log verbose
      bind = true,
      -- doc_lines = 4,
      floating_window = true,
      -- floating_window_above_cur_line = false,
      hint_enable = true,
      fix_pos = false,
      -- floating_window_above_first = true,
      log_path = vim.fn.expand('$HOME') .. '/tmp/sig.log',
      -- hi_parameter = "Search",
      zindex = 1002,
      timer_interval = 100,
      extra_trigger_chars = {},
      handler_opts = {
        border = 'rounded', -- "shadow", --{"╭", "─" ,"╮", "│", "╯", "─", "╰", "│" },
      },
      -- hint_prefix = {
      --   inlay = '',
      --   above = '↙ ', -- when the hint is on the line above the current line
      --   current = '← ', -- when the hint is on the same line
      --   below = '↖ ', -- when the hint is on the line below the current line
      -- },
      -- hint_inline = function()
      --   if vim.fn.has('nvim-0.10') == 1 then
      --     return 'inline'
      --   else
      --     return false
      --   end
      -- end,
      max_height = 6,
      -- toggle_key = [[<M-x>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
      toggle_key = [[<D-x>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
      -- select_signature_key = [[<M-n>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
      select_signature_key = [[<M-c>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
      move_cursor_key = [[<M-n>]], -- toggle signature on and off in insert mode,  e.g. '<M-x>'
      move_signature_window_key = { '<M-Up>', '<M-Down>' },
      show_struct = { enable = true },
    },
  })

  vim.g.copilot_filetypes = {
    ['dap-repl'] = false,
    -- gitcommit = false,
  }

  if true then
    use({
      'zbirenbaum/copilot.lua',
      -- cmd = 'Copilot',
      event = 'InsertEnter',

      -- version = vim.version.range('v2.0.0'),

      opts = function()
        vim.g.copilot_proxy_strict_ssl = false
        return {
          nes = {
            enabled = false,
            -- auto_trigger = true,
            -- keymap = {
            -- accept = '<Enter>',
            -- accept_and_goto = '<Tab>',
            -- dismiss = '<Esc>',
            -- },
          },

          logger = {
            file = vim.fn.stdpath('log') .. '/copilot-lua.log',
            file_log_level = vim.log.levels.INFO,
            print_log_level = vim.log.levels.WARN,
            trace_lsp = 'off', -- "off" | "debug" | "verbose"
            trace_lsp_progress = true,
            log_lsp_messages = true,
          },
          suggestion = {
            enabled = true,
            auto_trigger = true,
            hide_during_completion = true,
            debounce = 15,
            trigger_on_accept = true,
            keymap = {
              accept = '<C-j>',
              next = '<M-]>',
              prev = '<M-[>',
              dismiss = '<C-r>',
            },
          },
        }
      end,
      -- dependencies = {
      -- 'copilotlsp-nvim/copilot-lsp', -- (optional) for NES functionality
      -- },
    })
  end
  if false then
    use({
      'github/copilot.vim',
      event = 'InsertEnter',
      init = function()
        vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
          expr = true,
          replace_keycodes = false,
        })
        vim.g.copilot_no_tab_map = true
      end,
    })
    -- the plugin is very slow on bootup
    use({
      'cursortab/cursortab.nvim',
      event = 'CursorHold',
      -- lazy = false,
      build = 'cd server && go build',
      opts = {
        provider = {
          type = 'copilot',
        },
      },
    })
  end
end
