local gen_spec = require('mini.ai').gen_spec
local cache

-- Jump between text objects
local function user_textobject_id(ai_type)
  -- Get from user single character textobject identifier
  local needs_help_msg = true
  vim.defer_fn(function()
    if not needs_help_msg then
      return
    end
    local msg = string.format('Enter `%s` textobject identifier (single character) ', ai_type)
    vim.notify(msg)
  end, 1000)
  local ok, char = pcall(vim.fn.getcharstr)
  needs_help_msg = false

  -- Terminate if couldn't get input (like with <C-c>) or it is `<Esc>`
  if not ok or char == '\27' then
    return nil
  end

  if char:find('^[%w%p%s]$') == nil then
    vim.notify('Input must be single character: alphanumeric, punctuation, or space.')
    return nil
  end

  return char
end

local function jump_textobject(prev_next, left_right, ai_type)
  cache = {}

  local ok, ai = pcall(require, 'mini.ai')
  if not ok then
    vim.notify('No mini-ai found')
  end
  -- Get user input
  local tobj_id = user_textobject_id('a')
  if tobj_id == nil then
    return
  end

  -- Jump!
  ai.move_cursor(
    left_right,
    ai_type,
    tobj_id,
    { n_times = vim.v.count1, search_method = prev_next }
  )
end
return {
  setup = function()
    require('mini.ai').setup({
      custom_textobjects = {
        ['b'] = { { '%b()', '%b[]', '%b{}' }, '^.%s*().-()%s*.$' },
        -- seems not as useful
        x = require('mini.ai').gen_spec.treesitter(
          { a = '@comment.outer', i = '@comment.inner' },
          {}
        ),
        -- ts obj for following
        ['f'] = gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }), -- using ts
        ['a'] = gen_spec.treesitter({ a = '@parameter.outer', i = '@parameter.outer' }),
        o = gen_spec.treesitter({
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        }, {}),
        --
        c = gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }, {}),
        -- line selection
        -- ['L'] = function(type)
        --   if vim.api.nvim_get_current_line() == '' then
        --     return
        --   end
        --   vim.cmd.normal({ type == 'i' and '^' or '0', bang = true })
        --   local from_line, from_col = unpack(vim.api.nvim_win_get_cursor(0))
        --   local from = { line = from_line, col = from_col + 1 }
        --   vim.cmd.normal({ type == 'i' and 'g_' or '$', bang = true })
        --   local to_line, to_col = unpack(vim.api.nvim_win_get_cursor(0))
        --   local to = { line = to_line, col = to_col + 1 }
        --   return { from = from, to = to }
        -- end,
        -- entire buffer
        e = function(ai_type)
          if ai_type == 'i' then
            local first_non_blank = vim.fn.nextnonblank(1)
            local final_non_blank = vim.fn.prevnonblank(vim.fn.line('$'))
            local from = { line = first_non_blank, col = 1 }
            local to =
              { line = final_non_blank, col = math.max(vim.fn.getline(final_non_blank):len(), 1) }

            return { from = from, to = to }
          elseif ai_type == 'a' then
            local from = { line = 1, col = 1 }
            local to = { line = vim.fn.line('$'), col = math.max(vim.fn.getline('$'):len(), 1) }

            return { from = from, to = to }
          end
        end,
      },
    })

    -- Move cursor to corresponding edge of `a` textobject
    local gen_action = function(seq)
      local edge = ({ ['['] = 'left', [']'] = 'right' })[seq:sub(1, 1)]
      local ai_type = seq:sub(2, 2)
      local prev_next = ({l = 'prev', n = 'next'})[seq:sub(3, 3)]
      vim.keymap.set({ 'n', 'v' }, seq, function()
        jump_textobject(prev_next, edge, ai_type)
      end, {
        expr = true,
        desc = string.format('Jump to %s edge of %s `%s` text object', edge, ai_type, prev_next),
      })
    end
    gen_action('[al')
    gen_action(']al')
    gen_action('[an')
    gen_action(']an')
    gen_action('[in')
    gen_action(']in')
    gen_action('[il')
    gen_action(']il')

    require('mini.align').setup()

    require('mini.bufremove').setup({})
    require('mini.trailspace').setup({})
    require('mini.sessions').setup({
      force = {
        read = true,
        yank = true,
        write = true,
        delete = true,
      },
    })
    require('mini.diff').setup({})
    require('mini.splitjoin').setup({
      mappings = {
        toggle = '<space>j',
      },
    })

    -- replace booperlv/nvim-gomove
    -- <A-k>   Move current line/selection up
    -- <A-j>   Move current line/selection down
    -- <A-h>   Move current character/selection left
    -- <A-l>   Move current character/selection right

    require('mini.move').setup({})
  end,
}
