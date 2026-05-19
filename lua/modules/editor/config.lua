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

--

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
