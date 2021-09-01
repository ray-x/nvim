local config = {}

function config.autopairs()
  local has_autopairs, autopairs = pcall(require, "nvim-autopairs")
  if not has_autopairs then
    print("autopairs not loaded")
    vim.cmd([[packadd nvim-autopairs]])
    has_autopairs, autopairs = pcall(require, "nvim-autopairs")
    if not has_autopairs then
      print("autopairs not installed")
      return
    end
  end
  local npairs = require("nvim-autopairs")
  local Rule = require("nvim-autopairs.rule")
  npairs.setup({
    disable_filetype = {"TelescopePrompt", "guihua", "clap_input"},
    autopairs = {enable = true},
    ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""), -- "[%w%.+-"']",
    enable_check_bracket_line = false,
    html_break_line_filetype = {'html', 'vue', 'typescriptreact', 'svelte', 'javascriptreact'},
    check_ts = true,
    ts_config = {
      lua = {'string'}, -- it will not add pair on that treesitter node
      -- go = {'string'},
      javascript = {'template_string'},
      java = false -- don't check treesitter on java
    },
    fast_wrap = {
      map = '<M-e>',
      chars = {'{', '[', '(', '"', "'", "`"},
      pattern = string.gsub([[ [%'%"%`%+%)%>%]%)%}%,%s] ]], '%s+', ''),
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      hightlight = 'Search'
    }
  })
  local ts_conds = require('nvim-autopairs.ts-conds')
  -- you need setup cmp first put this after cmp.setup()

  npairs.add_rules {
    Rule(" ", " "):with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({"()", "[]", "{}"}, pair)
    end), Rule("(", ")"):with_pair(function(opts)
      return opts.prev_char:match ".%)" ~= nil
    end):use_key ")", Rule("{", "}"):with_pair(function(opts)
      return opts.prev_char:match ".%}" ~= nil
    end):use_key "}", Rule("[", "]"):with_pair(function(opts)
      return opts.prev_char:match ".%]" ~= nil
    end):use_key "]", Rule("%", "%", "lua") -- press % => %% is only inside comment or string
    :with_pair(ts_conds.is_ts_node({'string', 'comment'})),
    Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node({'function'}))
  }

  require("nvim-autopairs.completion.cmp").setup({
    map_cr = true, --  map <CR> on insert mode
    map_complete = true -- it will auto insert `(` after select function or method item
  })

  -- print("autopairs setup")
  -- skip it, if you use another global object

end

local esc = function(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

function config.hexokinase()
  vim.g.Hexokinase_optInPatterns = {
    "full_hex", "triple_hex", "rgb", "rgba", "hsl", "hsla", "colour_names"
  }
  vim.g.Hexokinase_highlighters = {
    "virtual", "sign_column", -- 'background',
    "backgroundfull"
    -- 'foreground',
    -- 'foregroundfull'
  }
end

function config.lightspeed()
    -- you can configure Hop the way you like here; see :h hop-config
    require"lightspeed".setup {
      jump_to_first_match = true,
      jump_on_partial_input_safety_timeout = 400,
      -- This can get _really_ slow if the window has a lot of content,
      -- turn it on only if your machine can always cope with it.
      highlight_unique_chars = false,
      grey_out_search_area = true,
      match_only_the_start_of_same_char_seqs = true,
      limit_ft_matches = 5,
      full_inclusive_prefix_key = '<c-x>',
      -- For instant-repeat, pressing the trigger key again (f/F/t/T)
      -- always works, but here you can specify additional keys too.
      instant_repeat_fwd_key = ';',
      instant_repeat_bwd_key = ':',
      -- By default, the values of these will be decided at runtime,
      -- based on `jump_to_first_match`.
      labels = nil,
      cycle_group_fwd_key = ']',
      cycle_group_bwd_key = '[',
    }
    function repeat_ft(reverse)
      local ls = require'lightspeed'
      ls.ft['instant-repeat?'] = true
      ls.ft:to(reverse, ls.ft['prev-t-like?'])
    end
    vim.api.nvim_set_keymap('n', ';', '<cmd>lua repeat_ft(false)<cr>',
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap('x', ';', '<cmd>lua repeat_ft(false)<cr>',
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap('n', ',', '<cmd>lua repeat_ft(true)<cr>',
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap('x', ',', '<cmd>lua repeat_ft(true)<cr>',
                            {noremap = true, silent = true})
    -- vim.cmd([[nunmap s]])
    -- vim.cmd([[vunmap s]])
    -- local bind = require("keymap.bind")
    -- local keys = {
    --   ["n|s"] = map_cr("HopChar1AC"),
    --   ["n|S"] = map_cr("HopChar1BC"),
    -- }
    -- bind.nvim_load_mapping(keys)
end

function config.nerdcommenter()
  vim.g.NERDCreateDefaultMappings = 1
  -- Add spaces after comment delimiters by default
  vim.g.NERDSpaceDelims = 1

  -- Use compact syntax for prettified multi-line comments
  vim.g.NERDCompactSexyComs = 1

  -- Align line-wise comment delimiters flush left instead of following code indentation
  vim.g.NERDDefaultAlign = "left"

  -- Set a language to use its alternate delimiters by default
  -- vim.g.NERDAltDelims_java = 1

  -- Add your own custom formats or override the defaults
  -- vim.g.NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

  -- Allow commenting and inverting empty lines (useful when commenting a region)
  vim.g.NERDCommentEmptyLines = 1

  -- Enable trimming of trailing whitespace when uncommenting
  vim.g.NERDTrimTrailingWhitespace = 1

  -- Enable NERDCommenterToggle to check all selected lines is commented or not
  vim.g.NERDToggleCheckAllLines = 1
end

function config.hlslens()
  -- body
  -- vim.cmd([[packadd nvim-hlslens]])
  vim.cmd(
      [[noremap <silent> n <Cmd>execute('normal! ' . v:count1 . 'n')<CR> <Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd(
      [[noremap <silent> N <Cmd>execute('normal! ' . v:count1 . 'N')<CR> <Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap * *<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap # #<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap g* g*<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap g# g#<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[nnoremap <silent> <leader>l :noh<CR>]])
  require("hlslens").setup({
    calm_down = true,
    -- nearest_only = true,
    nearest_float_when = "always"
  })
  vim.cmd([[aug VMlens]])
  vim.cmd([[au!]])
  vim.cmd([[au User visual_multi_start lua require('utils.vmlens').start()]])
  vim.cmd([[au User visual_multi_exit lua require('utils.vmlens').exit()]])
  vim.cmd([[aug END]])
end

-- Exit                  <Esc>       quit VM
-- Find Under            <C-n>       select the word under cursor
-- Find Subword Under    <C-n>       from visual mode, without word boundaries
-- Add Cursor Down       <M-Down>    create cursors vertically
-- Add Cursor Up         <M-Up>      ,,       ,,      ,,
-- Select All            \\A         select all occurrences of a word
-- Start Regex Search    \\/         create a selection with regex search
-- Add Cursor At Pos     \\\         add a single cursor at current position
-- Reselect Last         \\gS        reselect set of regions of last VM session

-- Mouse Cursor    <C-LeftMouse>     create a cursor where clicked
-- Mouse Word      <C-RightMouse>    select a word where clicked
-- Mouse Column    <M-C-RightMouse>  create a column, from current cursor to
--                                   clicked position
function config.vmulti()
  vim.g.VM_mouse_mappings = 1
  -- mission control takes <C-up/down> so remap <M-up/down> to <C-Up/Down>
  vim.api.nvim_set_keymap("n", "<M-n>", "<C-n>", {silent = true})
  -- vim.api.nvim_set_keymap("n", "<M-Down>", "<C-Down>", {silent = true})
  -- vim.api.nvim_set_keymap("n", "<M-Up>", "<C-Up>", {silent = true})
  -- for mac C-L/R was mapped to mission control
  -- print('vmulti')

  vim.g.VM_maps = {
    ["Add Cursor Down"] = "<M-Down>",
    ["Add Cursor Up"] = "<M-Up>",
    ["Mouse Cursor"] = "<m-leftmouse>",
    ["Mouse Word"] = "<m-rightmouse>",
    ["Add Cursor At Pos"] = '<M-i>'
  }
  vim.g.VM_mouse_mappings = true

end

return config
