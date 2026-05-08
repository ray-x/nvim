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

  if false then
    use({
      'olimorris/codecompanion.nvim',
      -- cond = function()
      --   return vim.g.network_status == true
      -- end,
      dependencies = {
        {
          'ravitemer/mcphub.nvim',
          build = 'npm install -g mcp-hub@latest',
          opts = {
            port = 37373,
            config = os.getenv('HOME') .. '/.config/mcphub/servers.json',
            extensions = {
              copilotchat = {
                enabled = true,
                convert_tools_to_functions = true, -- Convert MCP tools to @functions
                convert_resources_to_functions = true, -- Convert MCP resources to @functions
                add_mcp_prefix = false, -- Add "mcp_" prefix to function names
              },
            },
          },
        },
      },
      event = { 'InsertEnter', 'CmdlineEnter' },
      opts = {
        prompt_library = {
          ['Code Expert'] = {
            strategy = 'chat',
            description = 'Get some special advice for your code',
            opts = {
              mapping = '<LocalLeader>ce',
              modes = { 'v' },
              short_name = 'expert',
              auto_submit = true,
              stop_context_insertion = true,
              user_prompt = true,
            },
            extensions = {
              mcphub = {
                callback = 'mcphub.extensions.codecompanion',
                opts = {
                  make_vars = true,
                  make_slash_commands = true,
                  show_result_in_chat = true,
                },
              },
            },
            prompts = {
              {
                role = 'system',
                content = function(context)
                  return 'I want you to act as a senior ' .. context.filetype .. ' developer. I will ask you specific questions and I want you to return concise explanations and codeblock examples.'
                end,
              },
              {
                role = 'user',
                content = function(context)
                  local text = require('codecompanion.helpers.actions').get_code(context.start_line, context.end_line)

                  return 'I have the following code:\n\n```' .. context.filetype .. '\n' .. text .. '\n```\n\n'
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
        },
        strategies = {
          chat = { adapter = { name = 'copilot_acp', model = 'gpt-5.3-codex' } },
          inline = { adapter = { name = 'copilot', model = 'claude-opus-4.6' } },
          agent = { adapter = { name = 'copilot_acp', model = 'claude-opus-4.6' } },
        },
        adapters = {
          acp = {
            -- GitHub Copilot CLI (ACP agent). Preset is named `copilot_acp`
            -- in codecompanion.nvim. Requires the `copilot` CLI installed and
            -- authenticated (run `copilot` once to log in):
            --   https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli
            copilot_acp = function()
              return require('codecompanion.adapters').extend('copilot_acp', {
                defaults = {
                  timeout = 30000,
                  mcpServers = 'inherit_from_config',
                },
              })
            end,
          },
        },
        opts = {
          log_level = 'DEBUG',
        },
      },
    })
  end
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
      return {
        -- base_url = 'http://127.0.0.1:8088',
        client_name = 'nvim-copilot',
        permission_mode = 'approve-all',
        file_log_level = 'DEBUG',
        service = {
          auto_start = true,
          command = { 'go', 'run', '.' },
        },
        chat = {
          reasoning = { enabled = true, max_lines = 4 },
        },
        session = {
          model = 'gpt-5.4',
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

  if false then
    use({
      'zbirenbaum/copilot.lua',
      cmd = 'Copilot',
      event = 'InsertEnter',

      opts = function()
        vim.g.copilot_proxy_strict_ssl = false
        return {
          nes = {
            enabled = false,
          },

          logger = {
            file = vim.fn.stdpath('log') .. '/copilot-lua.log',
            file_log_level = vim.log.levels.WARN,
            print_log_level = vim.log.levels.ERROR,
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
              dismiss = '<C-]>',
            },
          },
        }
      end,
      dependencies = {
        'copilotlsp-nvim/copilot-lsp', -- (optional) for NES functionality
      },
    })
  end
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
  if false then
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
