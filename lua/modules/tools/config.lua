local config = {}
-- function config.session()
--   local opts = {
--     bypass_session_save_file_types = {
--       'dashboard',
--       'startify',
--       'NeogitStatus',
--       'NvimTree',
--       'fugitive',
--     },
--   }
-- end

function config.worktree()
  local function git_worktree(arg)
    if arg == 'create' then
      require('telescope').extensions.git_worktree.create_git_worktree()
    else
      require('telescope').extensions.git_worktree.git_worktrees()
    end
  end

  require('git-worktree').setup({})
  vim.api.nvim_create_user_command(
    'Worktree',
    "lua require'modules.tools.config'.worktree()(<f-args>)",
    {
      nargs = '*',
      complete = function()
        return { 'create' }
      end,
    }
  )

  local Worktree = require('git-worktree')
  Worktree.on_tree_change(function(op, metadata)
    if op == Worktree.Operations.Switch then
      print('Switched from ' .. metadata.prev_path .. ' to ' .. metadata.path)
    end

    if op == Worktree.Operations.Create then
      print('Create worktree ' .. metadata.path)
    end

    if op == Worktree.Operations.Delete then
      print('Delete worktree ' .. metadata.path)
    end
  end)
  return { git_worktree = git_worktree }
end

function config.diffview()
  local cb = require('diffview.config').diffview_callback
  require('diffview').setup({
    diff_binaries = false, -- Show diffs for binaries
    use_icons = true, -- Requires nvim-web-devicons
    enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
    signs = { fold_closed = '', fold_open = '' },
    file_panel = {
      win_config = {
        position = 'left', -- One of 'left', 'right', 'top', 'bottom'
        width = 35, -- Only applies when position is 'left' or 'right'
      },
    },
    key_bindings = {
      -- The `view` bindings are active in the diff buffers, only when the current
      -- tabpage is a Diffview.
      view = {
        ['<tab>'] = cb('select_next_entry'), -- Open the diff for the next file
        ['<s-tab>'] = cb('select_prev_entry'), -- Open the diff for the previous file
        ['<leader>e'] = cb('focus_files'), -- Bring focus to the files panel
        ['<leader>b'] = cb('toggle_files'), -- Toggle the files panel.
      },
      file_panel = {
        ['j'] = cb('next_entry'), -- Bring the cursor to the next file entry
        ['<down>'] = cb('next_entry'),
        ['k'] = cb('prev_entry'), -- Bring the cursor to the previous file entry.
        ['<up>'] = cb('prev_entry'),
        ['<cr>'] = cb('select_entry'), -- Open the diff for the selected entry.
        ['o'] = cb('select_entry'),
        ['R'] = cb('refresh_files'), -- Update stats and entries in the file list.
        ['<tab>'] = cb('select_next_entry'),
        ['<s-tab>'] = cb('select_prev_entry'),
        ['<leader>e'] = cb('focus_files'),
        ['<leader>b'] = cb('toggle_files'),
      },
    },
  })
end

function config.vim_dadbod_ui()
  -- require('utils.helper').loader('vim-dadbod')

  local sep = require('core.global').path_sep
  vim.g.db_ui_show_help = 0
  vim.g.db_ui_execute_on_save = 0 -- use <leader>S to save
  vim.g.db_ui_win_position = 'left'
  vim.g.db_ui_use_nerd_fonts = 1
  vim.g.db_ui_winwidth = 35
  -- vim.g.db_ui_save_location = require('core.global').home .. '/.cache/vim/db_ui_queries'
  vim.g.db_ui_save_location =  vim.fn.getcwd() .. sep .. 'db'
  vim.cmd([[
  set shiftwidth=2
  " set tabstop=2
  " set smartindent
  ]])
  if vim.fn.exists('g:connections') == 0 then
    require('utils.database').load_dbs()
  end
end

function config.project()
  require('project_nvim').setup({
    datapath = vim.fn.stdpath('data'),
    ignore_lsp = { 'efm' },
    exclude_dirs = { '~/.cargo/*' },
    silent_chdir = true,
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  })
  require('telescope').load_extension('projects')
end

function config.neogit()
  local loader = require('utils.helper').loader
  loader('diffview.nvim')
  require('neogit').setup({
    signs = {
      section = { '', '' },
      item = { '', '' },
      hunk = { '', '' },
    },
    integrations = {
      diffview = true,
    },
  })
end

function config.gitsigns()
  require('gitsigns').setup({
    signs = {
      add = {
        hl = 'GitGutterAdd',
        text = '│',
        numhl = 'GitSignsAddNr',
        linehl = 'GitSignsAddLn',
      },
      change = {
        hl = 'GitGutterChange',
        text = '│',
        numhl = 'GitSignsChangeNr',
        linehl = 'GitSignsChangeLn',
      },
      delete = {
        hl = 'GitGutterDelete',
        text = 'ﬠ',
        numhl = 'GitSignsDeleteNr',
        linehl = 'GitSignsDeleteLn',
      },
      topdelete = {
        hl = 'GitGutterDelete',
        text = 'ﬢ',
        numhl = 'GitSignsDeleteNr',
        linehl = 'GitSignsDeleteLn',
      },
      changedelete = {
        hl = 'GitGutterChangeDelete',
        text = '┊',
        numhl = 'GitSignsChangeNr',
        linehl = 'GitSignsChangeLn',
      },
    },
    -- sign_priority = 6,
    update_debounce = 400,
    numhl = false,
    word_diff = true,
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map('n', ']c', function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return '<Ignore>'
      end, { expr = true })

      map('n', '[c', function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return '<Ignore>'
      end, { expr = true })
    end,

    watch_gitdir = { interval = 1000, follow_files = true },
    status_formatter = nil, -- Use default
    debug_mode = false,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
      delay = 2000,
      virt_text_priority = 20, -- maybe the last thing I would like to see
    },
    diff_opts = { internal = true },
  })

  vim.api.nvim_set_hl(0, 'GitSignsAddInline', { underdotted = true, default = true, sp = 'green' }) -- diff mode: Deleted line |diff.txt|
  vim.api.nvim_set_hl(
    0,
    'GitSignsDeleteInline',
    { strikethrough = true, default = true, sp = 'yellow' }
  ) -- diff mode: Deleted line |diff.txt|
  vim.api.nvim_set_hl(
    0,
    'GitSignsChangeInline',
    { undercurl = true, default = true, sp = 'darkcyan' }
  ) -- diff mode: Deleted line |diff.txt|
  vim.api.nvim_create_user_command('Stage', "'<,'>Gitsigns stage_hunk", { range = true })
end

local function round(x)
  return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

function config.bqf()
  require('bqf').setup({
    auto_enable = true,
    preview = {
      win_height = 12,
      win_vheight = 12,
      delay_syntax = 80,
      border_chars = { '┃', '┃', '━', '━', '┏', '┓', '┗', '┛', '█' },
    },
    func_map = { vsplit = '', ptogglemode = 'z,', stoggleup = '' },
    filter = {
      fzf = {
        action_for = { ['ctrl-s'] = 'split' },
        extra_opts = { '--bind', 'ctrl-o:toggle-all', '--prompt', '> ' },
      },
    },
  })
end

function config.dapui()
  require('dapui').setup({
    icons = { expanded = '⯆', collapsed = '⯈', circular = '↺' },

    mappings = {
      -- Use a table to apply multiple mappings
      expand = { '<CR>', '<2-LeftMouse>' },
      open = 'o',
      remove = 'd',
      edit = 'e',
    },
    sidebar = {
      elements = {
        -- You can change the order of elements in the sidebar
        'scopes',
        'stacks',
        'watches',
      },
      width = 40,
      position = 'left', -- Can be "left" or "right"
    },
    tray = {
      elements = { 'repl' },
      height = 10,
      position = 'bottom', -- Can be "bottom" or "top"
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil, -- Floats will be treated as percentage of your screen.
    },
  })
end

function config.markdown()
  vim.g.vim_markdown_frontmatter = 1
  vim.g.vim_markdown_strikethrough = 1
  vim.g.vim_markdown_folding_level = 6
  vim.g.vim_markdown_override_foldtext = 1
  vim.g.vim_markdown_folding_style_pythonic = 1
  vim.g.vim_markdown_conceal = 1
  vim.g.vim_markdown_conceal_code_blocks = 1
  vim.g.vim_markdown_new_list_item_indent = 0
  vim.g.vim_markdown_toc_autofit = 0
  vim.g.vim_markdown_edit_url_in = 'vsplit'
  vim.g.vim_markdown_strikethrough = 1
  vim.g.vim_markdown_fenced_languages = {
    'c++=javascript',
    'js=javascript',
    'json=javascript',
    'jsx=javascript',
    'tsx=javascript',
  }
end

--[[
Use `git ls-files` for git files, use `find ./ *` for all files under work directory.
]]
--

function config.close_buffers()
  require('close_buffers').setup({
    preserve_window_layout = { 'this' },
    next_buffer_cmd = function(windows)
      require('bufferline').cycle(1)
      local bufnr = vim.api.nvim_get_current_buf()

      for _, window in ipairs(windows) do
        vim.api.nvim_win_set_buf(window, bufnr)
      end
    end,
  })

  vim.api.nvim_create_user_command('Bd', function(opts)
    local arg = opts.fargs[1] or ''
    local force = opts.bang or false
    if arg == 'a' then
      require('close_buffers').delete({ type = 'all', force = force })
    elseif arg == 'o' then
      require('close_buffers').delete({ type = 'other', force = force })
    else
      require('close_buffers').delete({ type = 'this', force = force })
    end
  end, { range = true, nargs = '*', bang = true })
end

function config.floaterm()
  -- Set floaterm window's background to black
  -- Set floating window border line color to cyan, and background to orange
  require('toggleterm').setup({
    -- size can be a number or function which is passed the current terminal
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = [[<c-\>]],
    -- on_open = fun(t: Terminal), -- function to run when the terminal opens
    -- on_close = fun(t: Terminal), -- function to run when the terminal closes
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = true,
    -- shading_factor = "<number>", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    persist_size = true,
    direction = 'float',
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
      -- The border key is *almost* the same as 'nvim_open_win'
      -- see :h nvim_open_win for details on borders however
      -- the 'curved' border is a custom border type
      -- not natively supported but implemented in this plugin.
      border = 'curved',
      -- width = <value>,
      -- height = <value>,
      winblend = 3,
    },
  })
  local Terminal = require('toggleterm.terminal').Terminal
  local lazygit = Terminal:new({ cmd = 'lazygit', hidden = true })
  local lazydocker = Terminal:new({ cmd = 'lazydocker', hidden = true })

  local function _lazygit_toggle()
    if require('core.global').is_windows then
      return require('guihua.floating').floating_term({
        cmd = { 'lazygit' },
        border = 'single',
        external = false,
      })
    end
    lazygit:toggle()
  end
  local function _lazydocker_toggle()
    lazydocker:toggle()
  end
  local function _gd_toggle(...)
    local args = { ... }
    local ver
    if #args > 0 then
      ver = args[1]
    else
      ver = ''
    end
    local cmd = { 'gd', ver }
    if ver == 'a' then
      cmd = 'git diff'
    end

    if require('core.global').is_windows then
      return require('guihua.floating').floating_term({
        cmd = { 'git', 'diff' },
        border = 'single',
      })
    else
      local gd = Terminal:new({ cmd = cmd, hidden = true })
      gd:toggle()
    end
    vim.cmd('normal! a')
  end

  local last_line = ''
  local function _cmd_hist_toggle(...)
    Terminal:new({
      cmd = 'echo $(history | fzf --print0 | string split0)',
      on_stdout = function(_, _, data, name)
        for i, v in ipairs(data) do
          v = vim.trim(v)
          if v ~= '' and v:match('%a') == 1 then
            last_line = v
            data[i] = last_line
            lprint('execute: ', last_line)
          end
        end
      end,
      on_exit = function(_)
        print('exit', last_line)
        if last_line ~= '' then
          local ret = vim.fn.systemlist(last_line)
          vim.notify(last_line .. ': ' .. vim.inspect(ret))
        end
        last_line = ''
      end,
    }):toggle()
  end

  local function _jest_test()
    local cmd = 'npx vue-cli-service test:unit --testPathPattern='
      .. [["]]
      .. vim.fn.expand('%:t')
      .. [["]]
    local gd = Terminal:new({ cmd = cmd, hidden = true })
    gd:toggle()
  end

  local function _gitstatus()
    local gd = Terminal:new({ cmd = 'gs', hidden = true, close_on_exit = false })
    gd:toggle()
  end

  local function _fzf_toggle()
    local fzf = Terminal:new({ cmd = 'fzf', hidden = true })
    fzf:toggle()
  end
  vim.api.nvim_create_user_command('LG', function()
    _lazygit_toggle()
  end, { nargs = '*' })
  vim.api.nvim_create_user_command('Gst', function()
    _gitstatus()
  end, { nargs = '*' })
  vim.api.nvim_create_user_command('LD', function()
    _lazydocker_toggle()
  end, { nargs = '*' })
  vim.api.nvim_create_user_command('C', function()
    _cmd_hist_toggle()
  end, { nargs = '*' })
  vim.api.nvim_create_user_command('Jest', function()
    _jest_test()
  end, { nargs = '*' })

  vim.api.nvim_create_user_command('FZF', function()
    _fzf_toggle()
  end, { nargs = '*' })
  -- vim.cmd("command! NNN FloatermNew --autoclose=1 --height=0.96 --width=0.96 nnn")
  -- vim.cmd("command! FN FloatermNew --autoclose=1 --height=0.96 --width=0.96")
  -- vim.cmd("command! LG FloatermNew --autoclose=1 --height=0.96 --width=0.96 lazygit")
  -- vim.cmd("command! Ranger FloatermNew --autoclose=1 --height=0.96 --width=0.96 ranger")

  -- vim.g.floaterm_gitcommit = "split"
  -- vim.g.floaterm_keymap_new = "<F19>" -- S-f7
  -- vim.g.floaterm_keymap_prev = "<F20>"
  -- vim.g.floaterm_keymap_next = "<F21>"
  -- vim.g.floaterm_keymap_toggle = "<F24>"
  -- Use `git ls-files` for git files, use `find ./ *` for all files under work directory.
  -- grep -rli 'old-word' * | xargs -i@ sed -i 's/old-word/new-word/g' @
  --  rg -l 'old-word' * | xargs -i@ sed -i 's/old-word/new-word/g' @
end

function config.spelunker()
  -- vim.cmd("command! Spell call spelunker#check()")
  vim.g.enable_spelunker_vim_on_readonly = 0
  vim.g.spelunker_check_type = 2
  vim.g.spelunker_highlight_type = 2
  vim.g.spelunker_disable_uri_checking = 1
  vim.g.spelunker_disable_account_name_checking = 1
  vim.g.spelunker_disable_email_checking = 1
  -- vim.cmd("highlight SpelunkerSpellBad cterm=underline ctermfg=247 gui=undercurl guifg=#F3206e guisp=#EF3050")
  -- vim.cmd("highlight SpelunkerComplexOrCompoundWord cterm=underline gui=undercurl guisp=#EF3050")
  vim.cmd('highlight def link SpelunkerSpellBad SpellBad')
  vim.cmd('highlight def link SpelunkerComplexOrCompoundWord Rare')
  vim.fn['spelunker#check'] = function(...)
    vim.fn['spelunker#check'] = nil
    require('lazy').load({ plugins = { 'spelunker.vim' } })
    return vim.fn['spelunker#check'](...)
  end
end

function config.spellcheck()
  vim.cmd('highlight def link SpelunkerSpellBad SpellBad')
  vim.cmd('highlight def link SpelunkerComplexOrCompoundWord Rare')
  vim.cmd('command! Spell call spelunker#check()')
  vim.fn['spelunker#check']()
end

function config.grammcheck()
  -- body
  require('utils.helper').loader('vim-grammarous')
  vim.cmd([[GrammarousCheck]])
end
function config.vim_test()
  vim.g['test#strategy'] = { nearest = 'neovim', file = 'neovim', suite = 'kitty' }
  vim.g['test#neovim#term_position'] = 'vert botright 60'
  vim.g['test#go#runner'] = 'ginkgo'
  vim.g['test#javascript#runner'] = 'jest'
  -- nmap <silent> t<C-n> :TestNearest<CR>
  -- nmap <silent> t<C-f> :TestFile<CR>
  -- nmap <silent> t<C-s> :TestSuite<CR>
  -- nmap <silent> t<C-l> :TestLast<CR>
  -- nmap <silent> t<C-g> :TestVisit<CR>
end

function config.neotest()
  require('neotest').setup({
    adapters = {
      require('neotest-python')({
        dap = { justMyCode = false },
        runner = 'pytest',
      }),
      require('neotest-plenary'),
      -- require("neotest-vim-test")({
      --   ignore_file_types = { "vim", "lua" },
      -- }),
      require('neotest-jest')({
        jestCommand = 'npm test --',
        jestConfigFile = 'custom.jest.config.ts',
        env = { CI = true },
        cwd = function(path)
          return vim.fn.getcwd()
        end,
      }),
    },
    quickfix = {
      enable = true,
      open = function()
        vim.cmd('Trouble quickfix')
      end,
    },
  })
  vim.api.nvim_create_user_command('Neotest', function()
    require('neotest').run.run()
  end, { nargs = '*' })
  vim.api.nvim_create_user_command('NeotestFile', function()
    require('neotest').run.run(vim.fn.expand('%'))
  end, { nargs = '*' })
  vim.api.nvim_create_user_command('NeoResult', function()
    require('neotest').output_panel.toggle()
  end, { nargs = '*' })
end

function config.mkdp()
  -- print("mkdp")
  vim.g.mkdp_command_for_global = 1
  vim.cmd(
    [[let g:mkdp_preview_options = { 'mkit': {}, 'katex': {}, 'uml': {}, 'maid': {}, 'disable_sync_scroll': 0, 'sync_scroll_type': 'middle', 'hide_yaml_meta': 1, 'sequence_diagrams': {}, 'flowchart_diagrams': {}, 'content_editable': v:true, 'disable_filename': 0 }]]
  )
end

function config.git_conflict()
  require('git-conflict').setup()
end

function config.rest()
  require('rest-nvim').setup({})
  -- local set = vim.keymap.set
  -- local rest = require("rest-nvim")
  -- local bufnr = tonumber(vim.fn.expand("<abuf>"), 10)

  vim.api.nvim_create_user_command(
    'RestRun',
    "lua require('rest-nvim').run({verbose=false})",
    { nargs = '*' }
  )
  vim.api.nvim_create_user_command(
    'RestPreview',
    "lua require('rest-nvim').run({verbose=true})",
    { nargs = '*' }
  )
  vim.api.nvim_create_user_command('RestFile', function(_)
    require('rest-nvim').run_file(vim.fn.expand('%f:%h'), { verbose = true })
  end, { nargs = '*' })
  vim.api.nvim_create_user_command('RestLast', "lua require('rest-nvim').last()", { nargs = '*' })
end

vim.api.nvim_create_user_command('LspClients', function(opts)
  if opts.fargs ~= nil then
    for _, client in pairs(vim.lsp.get_active_clients()) do
      if client.name == opts.fargs[1] then
        lprint(client)
      end
    end
  else
    lprint(vim.lsp.get_active_clients())
  end
end, { nargs = '*' })

config.hologram = function()
  if vim.fn.exists('linux') then
    return
  end
  require('hologram').setup({
    auto_display = true, -- WIP automatic markdown image display, may be prone to breaking
  })
end

config.hurl = function()
  require('hurl').setup() -- add hurl to the nvim-treesitter config
  require('nvim-treesitter.config').setup({
    ensure_installed = { 'hurl' }, -- ensure that hurl gets installed
    highlight = {
      enable = true, -- hurl plugin provides tree-sitter highlighting
    },
    indent = {
      enable = true, -- hurl plugin provides tree-sitter indenting
    },
  })
end

return config
