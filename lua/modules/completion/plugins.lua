-- stylua: ignore start
local filetypes = { 'html', 'css', 'javascript', 'java', 'javascriptreact', 'vue', 'typescript', 'typescriptreact', 'go',
  'lua', 'cpp', 'c', 'markdown', 'makefile', 'python', 'bash', 'sh', 'php', 'yaml', 'json', 'sql', 'vim', 'sh',
}
-- stylua: ignore end

return function(use)
  local dev = _G.is_dev()
  use({
    'neovim/nvim-lspconfig',
    config = function()
      local conf = require('modules.completion.config')
      conf.nvim_lsp()
    end,
    lazy = true,
  })

  if vim.wo.diff then
    return
  end
  -- loading sequence LuaSnip -> nvim-cmp -> cmp_luasnip -> cmp-nvim-lua -> cmp-nvim-lsp ->cmp-buffer -> friendly-snippets
  use({
    'hrsh7th/nvim-cmp',
    module = true,
    -- lazy = true,
    event = { 'InsertEnter', 'CmdlineEnter' }, -- InsertCharPre
    -- ft = {'lua', 'markdown',  'yaml', 'json', 'sql', 'vim', 'sh', 'sql', 'vim', 'sh'},
    -- stylua: ignore start
    dependencies = {
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'hrsh7th/cmp-path' },
      { 'f3fora/cmp-spell' },
      { 'hrsh7th/cmp-cmdline' },
      { 'dmitmel/cmp-cmdline-history' },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol', event = 'CmdLineEnter' },
      -- { 'hrsh7th/cmp-copilot' },
      { 'ray-x/cmp-treesitter',                 dev = _G.is_dev() },
      { 'ray-x/cmp-sql',                        dev = _G.is_dev(),     ft = { 'sql', 'psql' } },
      { 'ray-x/shell-history.nvim',             dev = _G.is_dev() },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'kdheepak/cmp-latex-symbols',           ft = { 'markdown' } },
      { 'hrsh7th/cmp-emoji' },
      {
        "zbirenbaum/copilot-cmp",
        config = function()
          require("copilot_cmp").setup({
          })
        end
      },
      {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        module = true,
        config = function()
          require(
            'modules.completion.config').autopairs()
        end
      },
    },
    -- stylua: ignore end
    config = function()
      local conf = require('modules.completion.config')
      conf.nvim_cmp()
    end,
  })

  use({
    'CopilotC-Nvim/CopilotChat.nvim',
    event = { 'InsertEnter', 'CmdlineEnter' },
    build = 'make tiktoken',
    opts = {
      model = 'claude-opus-4.6', -- AI model to use
      temperature = 0.2, -- Lower = focused, higher = creative
      window = {
        layout = 'vertical', -- 'vertical', 'horizontal', 'float'
        width = 0.3, -- 50% of screen width
      },
      auto_insert_mode = true, -- Enter insert mode when opening
    },
  })
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
                return 'I want you to act as a senior '
                  .. context.filetype
                  .. ' developer. I will ask you specific questions and I want you to return concise explanations and codeblock examples.'
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
        chat = { adapter = { name = 'copilot', model = 'gpt-5.4' } },
        inline = { adapter = { name = 'copilot', model = 'claude-opus-4.6' } },
        agent = { adapter = { name = 'copilot', model = 'claude-opus-4.6' } },
      },
      opts = {
        log_level = 'DEBUG',
      },
    },
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
  -- note: part of the code is used in navigator
  use({
    'ray-x/lsp_signature.nvim',
    dev = dev,
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

  use({
    'carlos-algms/agentic.nvim',

    event = { 'InsertEnter', 'CmdlineEnter' },
    opts = {
      -- Any ACP-compatible provider works. Built-in: "claude-agent-acp" | "gemini-acp" | "codex-acp" | "opencode-acp" | "cursor-acp" | "copilot-acp" | "auggie-acp" | "mistral-vibe-acp" | "cline-acp" | "goose-acp"
      provider = 'copilot-acp', -- setting the name here is all you need to get started
    },

    -- these are just suggested keymaps; customize as desired
    keys = {
      {
        '<C-\\>',
        function()
          require('agentic').toggle()
        end,
        mode = { 'n', 'v', 'i' },
        desc = 'Toggle Agentic Chat',
      },
      {
        "<C-'>",
        function()
          require('agentic').add_selection_or_file_to_context()
        end,
        mode = { 'n', 'v' },
        desc = 'Add file or selection to Agentic to Context',
      },
      {
        '<C-,>',
        function()
          require('agentic').new_session()
        end,
        mode = { 'n', 'v', 'i' },
        desc = 'New Agentic Session',
      },
      {
        '<A-i>r', -- ai Restore
        function()
          require('agentic').restore_session()
        end,
        desc = 'Agentic Restore session',
        silent = true,
        mode = { 'n', 'v', 'i' },
      },
      {
        '<leader>ad', -- ai Diagnostics
        function()
          require('agentic').add_current_line_diagnostics()
        end,
        desc = 'Add current line diagnostic to Agentic',
        mode = { 'n' },
      },
      {
        '<leader>aD', -- ai all Diagnostics
        function()
          require('agentic').add_buffer_diagnostics()
        end,
        desc = 'Add all buffer diagnostics to Agentic',
        mode = { 'n' },
      },
    },
  })

  use({
    'ThePrimeagen/99',
    event = { 'InsertEnter', 'CmdlineEnter', 'CursorHold' },
    config = function()
      local _99 = require('99')

      local CopilotProvider = setmetatable({}, { __index = _99.Providers.BaseProvider })

      function CopilotProvider._build_command(_, query, context)
        return {
          'copilot',
          '-s',
          '--stream',
          'off',
          '--no-color',
          '--model',
          context.model,
          '-p',
          query,
        }
      end

      function CopilotProvider._get_provider_name()
        return 'CopilotProvider'
      end

      function CopilotProvider._get_default_model()
        return 'gpt-5.4'
      end

      function CopilotProvider.fetch_models(callback)
        callback({ CopilotProvider._get_default_model() }, nil)
      end

      -- For logging that is to a file if you wish to trace through requests
      -- for reporting bugs, i would not rely on this, but instead the provided
      -- logging mechanisms within 99.  This is for more debugging purposes
      local cwd = vim.uv.cwd()
      local basename = vim.fs.basename(cwd)
      _99.setup({
        provider = CopilotProvider,
        logger = {
          level = _99.DEBUG,
          path = '/tmp/' .. basename .. '.99.debug',
          print_on_error = true,
        },
        -- When setting this to something that is not inside the CWD tools
        -- such as claude code or opencode will have permission issues
        -- and generation will fail refer to tool documentation to resolve
        -- https://opencode.ai/docs/permissions/#external-directories
        -- https://code.claude.com/docs/en/permissions#read-and-edit
        tmp_dir = './tmp',

        --- Completions: #rules and @files in the prompt buffer
        completion = {
          -- I am going to disable these until i understand the
          -- problem better.  Inside of cursor rules there is also
          -- application rules, which means i need to apply these
          -- differently
          -- cursor_rules = "<custom path to cursor rules>"

          --- A list of folders where you have your own SKILL.md
          --- Expected format:
          --- /path/to/dir/<skill_name>/SKILL.md
          ---
          --- Example:
          --- Input Path:
          --- "scratch/custom_rules/"
          ---
          --- Output Rules:
          --- {path = "scratch/custom_rules/vim/SKILL.md", name = "vim"},
          --- ... the other rules in that dir ...
          ---
          custom_rules = {
            'scratch/custom_rules/',
          },

          --- Configure @file completion (all fields optional, sensible defaults)
          files = {
            -- enabled = true,
            -- max_file_size = 102400,     -- bytes, skip files larger than this
            -- max_files = 5000,            -- cap on total discovered files
            -- exclude = { ".env", ".env.*", "node_modules", ".git", ... },
          },
          --- File Discovery:
          --- - In git repos: Uses `git ls-files` which automatically respects .gitignore
          --- - Non-git repos: Falls back to filesystem scanning with manual excludes
          --- - Both methods apply the configured `exclude` list on top of gitignore

          --- What autocomplete engine to use. Defaults to native (built-in) if not specified.
          source = 'native', -- "native" (default), "cmp", or "blink"
        },

        --- WARNING: if you change cwd then this is likely broken
        --- ill likely fix this in a later change
        ---
        --- md_files is a list of files to look for and auto add based on the location
        --- of the originating request.  That means if you are at /foo/bar/baz.lua
        --- the system will automagically look for:
        --- /foo/bar/AGENT.md
        --- /foo/AGENT.md
        --- assuming that /foo is project root (based on cwd)
        md_files = {
          'AGENT.md',
        },
      })
    end,
    keys = {
      {
        '<leader>9v',
        function()
          require('99').visual()
        end,
        mode = { 'v' },
        desc = '99 Visual Request',
      },
      {
        '<leader>9x',
        function()
          require('99').stop_all_requests()
        end,
        mode = { 'n' },
        desc = '99 Stop All Requests',
      },
      {
        '<leader>9s',
        function()
          require('99').search()
        end,
        mode = { 'n' },
        desc = '99 Search',
      },
  }}
)


  use({
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    -- cond = function()
    -- if vim.g.network_status == nil then
    -- print('Network status unknown, skipping copilot')
    -- check_network()
    -- end
    -- return vim.g.network_status == true
    -- end,

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
  if false then
    use({
      'github/copilot.vim',
      lazy = true,
      event = 'InsertEnter',
      init = function()
        vim.g.copilot_filetypes = {
          ['dap-repl'] = false,
          NeogitCommitMessage = false,
          gitcommit = false,
        }

        vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
          expr = true,
          replace_keycodes = false,
        })
        vim.g.copilot_no_tab_map = true
      end,
    })
  end
end
