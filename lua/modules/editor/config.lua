local config = {}

function config.hydra()
  --require('modules.editor.hydra')
  local gitrepo = vim.fn.isdirectory('.git/index')
  if gitrepo then
    require('modules.editor.hydra').hydra_git()
  end
end

function config.hexokinase()
  vim.g.Hexokinase_optInPatterns = {
    'full_hex',
    'triple_hex',
    'rgb',
    'rgba',
    'hsl',
    'hsla',
    'colour_names',
  }
  vim.g.Hexokinase_highlighters = {
    'virtual',
    'sign_column', -- 'background',
    'backgroundfull',
    -- 'foreground',
    -- 'foregroundfull'
  }
end

function config.yanky()
  require('yanky').setup({
    highlight = {
      on_put = true,
      on_yank = true,
      timer = 500,
    },
  })
  local utils = require('yanky.utils')
  local mapping = require('yanky.telescope.mapping')
  require('telescope').load_extension('yank_history')
  require('yanky').setup({
    highlight = {
      on_put = true,
      on_yank = true,
      timer = 500,
    },
    preserve_cursor_position = {
      enabled = true,
    },
    picker = {
      -- select = {
      -- 	action = require("yanky.picker").actions.put("p"),
      -- },
      telescope = {
        mappings = {
          default = mapping.put('p'),
          i = {
            ['<c-p>'] = mapping.put('p'),
            ['<c-k>'] = mapping.put('P'),
            ['<c-x>'] = mapping.delete(),
            ['<c-r>'] = mapping.set_register(utils.get_default_register()),
          },
          n = {
            p = mapping.put('p'),
            P = mapping.put('P'),
            gp = mapping.put('gp'),
            gP = mapping.put('gP'),
            d = mapping.delete(),
            r = mapping.set_register(utils.get_default_register()),
          },
        },
      },
    },
  })

  vim.api.nvim_set_hl(0, 'YankyPut', { link = 'Search' })
  vim.api.nvim_set_hl(0, 'YankyYanked', { link = 'Search' })
end

-- <Space>siw replace word
-- x mode <Space>s replace virtual select.
-- dot operator  repeat
-- space-s
function config.substitute()
  require('substitute').setup({
    -- yank_substituted_text = true,
    range = {
      prefix = 'S',
      prompt_current_text = true,
    },
    on_substitute = function(event)
      require('yanky').init_ring('p', event.register, event.count, event.vmode:match('[vV]'))
    end,
  })
end

function config.comment()
  require('Comment').setup({
    extended = true,
    pre_hook = function(ctx)
      -- print("ctx", vim.inspect(ctx))
      -- Only update commentstring for tsx filetypes
      if
        vim.tbl_contains({'typescriptreact', 'typescript', 'javascript', 'css', 'html', 'scss', 'svelte', 'uve', 'graphql'}, vim.bo.filetype)
      then
        local hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
        hook(ctx)
      end
    end,
    post_hook = function(ctx)
      -- lprint(ctx)
      if ctx.range.scol == -1 then
        -- do something with the current line
      else
        -- print(vim.inspect(ctx), ctx.range.srow, ctx.range.erow, ctx.range.scol, ctx.range.ecol)
        if ctx.range.ecol > 400 then
          ctx.range.ecol = 1
        end
        if ctx.cmotion > 1 then
          -- 322 324 0 2147483647
          vim.fn.setpos("'<", { 0, ctx.range.srow, ctx.range.scol })
          vim.fn.setpos("'>", { 0, ctx.range.erow, ctx.range.ecol })
          vim.cmd([[exe "norm! gv"]])
        end
      end
    end,
  })
end

function config.orgmode()
  local loader = require('utils.helper').loader
  loader('nvim-treesitter')
  vim.cmd('set foldlevel=2')

  require('orgmode').setup_ts_grammar()
  require('nvim-treesitter.configs').setup({
    -- If TS highlights are not enabled at all, or disabled via `disable` prop,
    -- highlighting will fallback to default Vim syntax highlighting
    highlight = {
      enable = true,
      -- Required for spellcheck, some LaTex highlights and
      -- code block highlights that do not have ts grammar
      additional_vim_regex_highlighting = { 'org' },
    },
    ensure_installed = { 'org' }, -- Or run :TSUpdate org
  })
  local org_path = vim.fn.expand('~/Library/CloudStorage/Dropbox/Logseq')
  local logseq_path = org_path
  require('orgmode').setup({
    -- mappings = {
    --   -- global = {
    --   --   org_agenda = { "gA", "<Leader>oa" },
    --   --   org_capture = { "gC", "<Leader>oc" },
    --   -- },
    --   -- agenda = {
    --   --   org_agenda_later = ">",
    --   --   org_agenda_earlier = "<",
    --   --   org_agenda_goto_today = { ".", "T" },
    --   -- },
    --   -- capture = {
    --   --   org_capture_finalize = "<Leader>w",
    --   --   org_capture_refile = "R",
    --   --   org_capture_kill = "Q",
    --   -- },
    --   --
    --   -- note = {
    --   --   org_note_finalize = "<Leader>w",
    --   --   org_note_kill = "Q",
    --   -- },
    -- },
    org_agenda_files = org_path .. '/journals/**/*',
    org_default_notes_file = org_path .. '/pages/refile.org',
    org_todo_keywords = {
      'TODO',
      'WIP',
      '|',
      'DONE',
      'WAITING',
      'PENDING',
      'HOLD',
      'CANCELLED',
      'ASSIGNED',
    },
    org_todo_keyword_faces = {
      WAITING = ':foreground yellow',
      TODO = ':foreground coral',
      DONE = ':foreground chartreuse',
      WIP = ':foreground cyan', -- overrides builtin color for `TODO` keyword
      HOLD = ':foreground ivory', -- overrides builtin color for `TODO` keyword
      PENDING = ':foreground yellow', -- overrides builtin color for `TODO` keyword
      ASSIGNED = ':foreground lightgreen', -- overrides builtin color for `TODO` keyword
      CANCELLED = ':foreground darkgreen', -- overrides builtin color for `TODO` keyword
      -- DELEGATED = ':background #FFFFFF :slant italic :underline on :forground #000000',
    },
    org_capture_templates = {
      v = {
        description = 'Visual todo (reg v)',
        template = '* TODO %(return vim.fn.getreg "v")\n %u',
      },
      m = {
        description = 'Meeting notes',
        template = '#+TITLE: %?\n#+AUTHER: Ray\n#+TAGS: metting \n#+DATE: %t\n\n*** %^{PROMPT|Meeting|LOGGING WGM} %U \n - %?\n<%<%Y-%m-%d %a %H:%M>>',
      },
      r = {
        description = 'ritual',
        template = '* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string "%<<%Y-%m-%d %a .+1d/3d>>")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n',
        target = string.format(logseq_path .. '/pages/%s.org', vim.fn.strftime('%Y-%m-%d')),
      },
      n = {
        description = 'Notes',
        template = '#+TITLE: %?\n#+AUTHER: Ray\n#+TAGS: @note \n#+DATE: %t\n',
        target = string.format( logseq_path .. '/pages/%s.org', vim.fn.strftime('%Y-%m-%d')),
      },
      j = {
        description = 'Journal',
        template = '#+TITLE: %?\n#+TAGS: @journal \n#+DATE: %t\n',
        target = string.format(logseq_path .. '/journals/%s.org', vim.fn.strftime('%Y-%m-%d')),
      },
    },
    notifications = {
      reminder_time = { 0, 1, 5, 10 },
      repeater_reminder_time = { 0, 1, 5, 10 },
      deadline_warning_reminder_time = { 0 },
      cron_notifier = function(tasks)
        for _, task in ipairs(tasks) do
          local title = string.format('%s (%s)', task.category, task.humanized_duration)
          local subtitle =
            string.format('%s %s %s', string.rep('*', task.level), task.todo, task.title)
          local date = string.format('%s: %s', task.type, task.time:to_string())

          -- if vim.fn.executable('notify-send') then
          --   vim.loop.spawn('notify-send', {
          --     args = {
          --       string.format('%s\n%s\n%s', title, subtitle, date),
          --     },
          --   })
          -- end
        end
      end,
    },
  })
  vim.opt.conceallevel = 2
  vim.cmd('set foldlevel=2')
end

-- function config.move()
--   require('gomove').setup({
--     -- whether or not to map default key bindings, (true/false)
--     map_defaults = true,
--     -- what method to use for reindenting, ("vim-move" / "simple" / ("none"/nil))
--     reindent_mode = 'vim-move',
--     -- whether to not to move past line when moving blocks horizontally, (true/false)
--     move_past_line = false,
--     -- whether or not to ignore indent when duplicating lines horizontally, (true/false)
--     ignore_indent_lh_dup = true,
--   })
-- end

function config.hlslens()
  -- body
  require('hlslens').setup({
    calm_down = true,
    -- nearest_only = true,
    nearest_float_when = 'auto',
  })
  local kopts = { noremap = true, silent = true }

  vim.api.nvim_set_keymap(
    'n',
    'n',
    [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
    kopts
  )
  vim.api.nvim_set_keymap(
    'n',
    'N',
    [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
    kopts
  )
  vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
  vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
  vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
  vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

  vim.cmd([[
    aug VMlens
        au!
        au User visual_multi_start lua require('modules.editor.vmlens').start()
        au User visual_multi_exit lua require('modules.editor.vmlens').exit()
    aug END
  ]])
end

-- help vm-mappings
function config.vmulti()
  vim.g.VM_mouse_mappings = 1
  vim.g.VM_silent_exit = 0
  vim.g.VM_show_warnings = 1
  vim.g.VM_default_mappings = 1

  vim.cmd([[
    let g:VM_maps = {}
    let g:VM_maps['Select All'] = '<C-M-n>'
    let g:VM_maps["Add Cursor Down"] = '<M-Down>'
    let g:VM_maps["Add Cursor Up"] = "<M-Up>"
    let g:VM_maps["Mouse Cursor"] = "<M-LeftMouse>"
    let g:VM_maps["Mouse Word"] = "<M-RightMouse>"
    let g:VM_maps["Add Cursor At Pos"] = '<M-i>'
  ]])
end

config.mini = function()
  require('modules.editor.mini').setup()
end

config.headline = function()
  vim.cmd([[highlight Headline1 guibg=#042030]])
  vim.cmd([[highlight Headline2 guibg=#141030]])
  -- vim.cmd([[highlight link Headline2 Function]])
  vim.cmd([[highlight CodeBlock guibg=#10101c]])
  vim.cmd([[highlight Dash guibg=#D19A66 gui=bold]])
  require('headlines').setup({
    markdown = { fat_headlines = true, headline_highlights = { 'Headline1', 'Headline2' } },
    org = { fat_headlines = false, headline_highlights = { 'Headline1', 'Headline2' } },
  })
end

return config
