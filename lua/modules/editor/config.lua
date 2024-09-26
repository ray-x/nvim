local config = {}

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
      -- stylua: ignore
      if vim.tbl_contains( { 'typescriptreact', 'typescript', 'javascript', 'css', 'html', 'scss', 'svelte', 'uve', 'graphql' }, vim.bo.filetype ) then
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

--

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

  vim.g.VM_maps = {
    ['Select All'] = '<C-M-n>',
    ['Add Cursor Down'] = '<M-Down>', -- <C-Down/Up> in mac is used
    ['Add Cursor Up'] = '<M-Up>',
    ['Mouse Cursor'] = '<M-LeftMouse>',
    ['Mouse Word'] = '<M-RightMouse>',
    -- ['Add Cursor At Pos'] = '<M-i>',
    -- ['Find Under'] = '<M-n>',
    -- ['Find Subword Under'] = '<M-n>',
    -- ['Start Regex Search'] = '<Leader>/',
  }
end

config.mini = function()
  require('modules.editor.mini').setup()
end

return config

-- config.headline = function()
--   -- vim.cmd([[highlight Headline1 guibg=NONE gui=bold]])
--   -- vim.cmd([[highlight Headline2 guibg=NONE gui=bold]])
--   -- vim.cmd([[highlight link Headline2 Function]])
--   -- vim.cmd([[highlight CodeBlock guibg=NONE]])
--   -- vim.cmd([[highlight Dash gui=bold]])
--   require('headlines').setup({
--     -- markdown = { fat_headlines = false, headline_highlights = { 'Headline1', 'Headline2' } },
--     -- org = { fat_headlines = false, headline_highlights = { 'Headline1', 'Headline2' } },
--     -- dash_string = "",
--     -- doubledash_string = "󱋰",
--   })
-- end

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
