local config = {}

local function load_env_file()
  local env_file = os.getenv("HOME") .. "/.env"
  local env_contents = {}
  if vim.fn.filereadable(env_file) ~= 1 then
    print(".env file does not exist")
    return
  end
  local contents = vim.fn.readfile(env_file)
  for _, item in pairs(contents) do
    local line_content = vim.fn.split(item, "=")
    env_contents[line_content[1]] = line_content[2]
  end
  return env_contents
end

function config.session()
  local opts = {
    log_level = 'info',
    auto_session_enable_last_session = false,
    auto_session_root_dir = vim.fn.stdpath('data') .. "/sessions/",
    auto_session_enabled = true,
    auto_save_enabled = nil,
    auto_restore_enabled = nil,
    auto_session_suppress_dirs = nil
  }
  require('auto-session').setup(opts)
end

local function load_dbs()
  local env_contents = load_env_file()
  local dbs = {}
  for key, value in pairs(env_contents) do
    if vim.fn.stridx(key, "DB_CONNECTION_") >= 0 then
      local db_name = vim.fn.split(key, "_")[3]:lower()
      dbs[db_name] = value
    end
  end
  return dbs
end

function config.diffview()
  local cb = require"diffview.config".diffview_callback
  require"diffview".setup {
    diff_binaries = false, -- Show diffs for binaries
    file_panel = {
      width = 35,
      use_icons = true -- Requires nvim-web-devicons
    },
    key_bindings = {
      -- The `view` bindings are active in the diff buffers, only when the current
      -- tabpage is a Diffview.
      view = {
        ["<tab>"] = cb("select_next_entry"), -- Open the diff for the next file
        ["<s-tab>"] = cb("select_prev_entry"), -- Open the diff for the previous file
        ["<leader>e"] = cb("focus_files"), -- Bring focus to the files panel
        ["<leader>b"] = cb("toggle_files") -- Toggle the files panel.
      },
      file_panel = {
        ["j"] = cb("next_entry"), -- Bring the cursor to the next file entry
        ["<down>"] = cb("next_entry"),
        ["k"] = cb("prev_entry"), -- Bring the cursor to the previous file entry.
        ["<up>"] = cb("prev_entry"),
        ["<cr>"] = cb("select_entry"), -- Open the diff for the selected entry.
        ["o"] = cb("select_entry"),
        ["R"] = cb("refresh_files"), -- Update stats and entries in the file list.
        ["<tab>"] = cb("select_next_entry"),
        ["<s-tab>"] = cb("select_prev_entry"),
        ["<leader>e"] = cb("focus_files"),
        ["<leader>b"] = cb("toggle_files")
      }
    }
  }
end

function config.vim_dadbod_ui()
  if packer_plugins["vim-dadbod"] and not packer_plugins["vim-dadbod"].loaded then
    require"packer".loader("vim-dadbod")
  end
  vim.g.db_ui_show_help = 0
  vim.g.db_ui_win_position = "left"
  vim.g.db_ui_use_nerd_fonts = 1
  vim.g.db_ui_winwidth = 35
  vim.g.db_ui_save_location = os.getenv("HOME") .. "/.cache/vim/db_ui_queries"
  vim.g.dbs = load_dbs()
end

function config.vim_vista()
  vim.g["vista#renderer#enable_icon"] = 1
  vim.g.vista_disable_statusline = 1

  vim.g.vista_default_executive = "ctags"
  vim.g.vista_echo_cursor_strategy = "floating_win"
  vim.g.vista_vimwiki_executive = "markdown"
  vim.g.vista_executive_for = {
    vimwiki = "markdown",
    pandoc = "markdown",
    markdown = "toc",
    typescript = "nvim_lsp",
    typescriptreact = "nvim_lsp",
    go = "nvim_lsp",
    lua = "nvim_lsp"
  }

  vim.g['vista#renderer#icons'] = {['function'] = "", ['method'] = "ℱ", variable = "כֿ"}
end

function config.far()
  -- body
  vim.cmd [[UpdateRemotePlugins]]
  vim.g["far#source"] = "rgnvim"
  vim.g["far#cmdparse_mode"] = "shell"
end

function config.clap()
  vim.g.clap_preview_size = 10
  vim.g.airline_powerline_fonts = 1
  vim.g.clap_layout = {width = "80%", row = "8%", col = "10%", height = "34%"} -- height = "40%", row = "17%", relative = "editor",
  -- vim.g.clap_popup_border = "rounded"
  vim.g.clap_selected_sign = {text = "", texthl = "ClapSelectedSign", linehl = "ClapSelected"}
  vim.g.clap_current_selection_sign = {
    text = "",
    texthl = "ClapCurrentSelectionSign",
    linehl = "ClapCurrentSelection"
  }
  -- vim.g.clap_always_open_preview = true
  vim.g.clap_preview_direction = "UD"
  -- if vim.g.colors_name == 'zephyr' then
  vim.g.clap_theme = 'material_design_dark'
  -- end
  -- vim.api.nvim_command("autocmd FileType clap_input call compe#setup({ 'enabled': v:false }, 0)")
end

function config.clap_after()
  if not packer_plugins["nvim-compe"].loaded
    then require"packer".loader("nvim-compe")
  end
end
function config.neogit()

  require("neogit").setup({
    disable_signs = false,
    disable_context_highlighting = false,
    disable_commit_confirmation = false,
    -- customize displayed signs
    signs = {
      -- { CLOSED, OPENED }
      section = { ">", "v" },
      item = { ">", "v" },
      hunk = { "", "" },
    },
    integrations = {
      -- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `sindrets/diffview.nvim`.
      -- The diffview integration enables the diff popup, which is a wrapper around `sindrets/diffview.nvim`.
      --
      -- Requires you to have `sindrets/diffview.nvim` installed.
      -- use {
      --   'TimUntersberger/neogit',
      --   requires = {
      --     'nvim-lua/plenary.nvim',
      --     'sindrets/diffview.nvim'
      --   }
      -- }
      --
      diffview = true,
    },
    -- override/add mappings
    mappings = {
      -- modify status buffer mappings
      status = {
        -- Adds a mapping with "B" as key that does the "BranchPopup" command
        ["B"] = "BranchPopup",
        -- Removes the default mapping of "s"
        ["s"] = "",
      },
    },
  })
end

function config.gitsigns()
  -- if not packer_plugins["plenary.nvim"].loaded then
  --   require'packer'.loader("plenary.nvim")
  -- end
  require("gitsigns").setup {
    signs = {
      add = {hl = "GitGutterAdd", text = "│", numhl = "GitSignsAddNr"},
      change = {hl = "GitGutterChange", text = "│", numhl = "GitSignsChangeNr"},
      delete = {hl = "GitGutterDelete", text = "ﬠ", numhl = "GitSignsDeleteNr"},
      topdelete = {hl = "GitGutterDelete", text = "ﬢ", numhl = "GitSignsDeleteNr"},
      changedelete = {hl = "GitGutterChangeDelete", text = "┊", numhl = "GitSignsChangeNr"}
    },
    numhl = false,
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,
      ["n ]c"] = {expr = true, '&diff ? \']c\' : \'<cmd>lua require"gitsigns".next_hunk()<CR>\''},
      ["n [c"] = {expr = true, '&diff ? \'[c\' : \'<cmd>lua require"gitsigns".prev_hunk()<CR>\''},
      ["n <leader>hs"] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
      ["n <leader>hu"] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
      ["n <leader>hr"] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
      ["n <leader>hp"] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
      ["n <leader>hb"] = '<cmd>lua require"gitsigns".blame_line()<CR>',
      -- Text objects
      ["o ih"] = ':<C-U>lua require"gitsigns".text_object()<CR>',
      ["x ih"] = ':<C-U>lua require"gitsigns".text_object()<CR>'
    },
    watch_index = {interval = 1000, follow_files = true},
    sign_priority = 6,
    status_formatter = nil, -- Use default
    debug_mode = false,
    current_line_blame = true,
    current_line_blame_opts = {delay = 1500},
    update_debounce = 300,
    word_diff = true,
    use_internal_diff = true
  }
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
      border_chars = {'┃', '┃', '━', '━', '┏', '┓', '┗', '┛', '█'}
    },
    func_map = {vsplit = '', ptogglemode = 'z,', stoggleup = ''},
    filter = {
      fzf = {
        action_for = {['ctrl-s'] = 'split'},
        extra_opts = {'--bind', 'ctrl-o:toggle-all', '--prompt', '> '}
      }
    }
  })
end

function config.dapui()
  require("dapui").setup({
    icons = {expanded = "⯆", collapsed = "⯈", circular = "↺"},
    mappings = {
      -- Use a table to apply multiple mappings
      expand = {"<CR>", "<2-LeftMouse>"},
      open = "o",
      remove = "d",
      edit = "e"
    },
    sidebar = {
      elements = {
        -- You can change the order of elements in the sidebar
        "scopes", "stacks", "watches"
      },
      width = 40,
      position = "left" -- Can be "left" or "right"
    },
    tray = {
      elements = {"repl"},
      height = 10,
      position = "bottom" -- Can be "bottom" or "top"
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil -- Floats will be treated as percentage of your screen.
    }
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
  vim.g.vim_markdown_edit_url_in = "vsplit"
  vim.g.vim_markdown_strikethrough = 1
  vim.g.vim_markdown_fenced_languages = {
    "c++=javascript", "js=javascript", "json=javascript", "jsx=javascript", "tsx=javascript"
  }
end

function config.floaterm()
  -- Set floaterm window's background to black
  -- Set floating window border line color to cyan, and background to orange
  vim.g.floaterm_wintype = "float"
  vim.g.floaterm_width = 0.9
  vim.g.floaterm_height = 0.9
  vim.cmd("hi Floaterm guibg=black")
  -- vim.cmd('hi FloatermBorder guibg=orange guifg=cyan')
  vim.cmd("command! FZF FloatermNew fzf")
  vim.cmd("command! NNN FloatermNew --height=0.96 --width=0.96 nnn")
  vim.cmd("command! FN FloatermNew --height=0.96 --width=0.96")
  vim.cmd("command! LG FloatermNew --height=0.96 --width=0.96 lazygit")
  vim.cmd("command! Sad FloatermNew --height=0.96 --width=0.96 find ./ *")
  vim.cmd("command! Ranger FloatermNew --height=0.96 --width=0.96 ranger")

  vim.g.floaterm_gitcommit = "split"
  vim.g.floaterm_keymap_new = "<F19>" -- S-f7
  vim.g.floaterm_keymap_prev = "<F20>"
  vim.g.floaterm_keymap_next = "<F21>"
  vim.g.floaterm_keymap_toggle = "<F24>"
  -- Use `git ls-files` for git files, use `find ./ *` for all files under work directory.
  vim.cmd(
      [[ command! FR let old = expand("<cword>") | let rep = input("Replace " . old . " with: ", old) | execute ":FloatermNew --height=0.95 --width=0.95  git ls-files  | sad " . old . " " . rep ]])

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
  vim.cmd("highlight def link SpelunkerSpellBad SpellBad")
  vim.cmd("highlight def link SpelunkerComplexOrCompoundWord Rare")
end

function config.spellcheck()

  vim.cmd("highlight def link SpelunkerSpellBad SpellBad")
  vim.cmd("highlight def link SpelunkerComplexOrCompoundWord Rare")

  vim.fn["spelunker#check"]()
end

function config.grammcheck()
  -- body
  if not packer_plugins["rhysd/vim-grammarous"] or not packer_plugins["rhysd/vim-grammarous"].loaded then
    require"packer".loader("vim-grammarous")
  end
  vim.cmd [[GrammarousCheck]]
end
function config.vim_test()
  vim.g["test#strategy"] = {nearest = "neovim", file = "neovim", suite = "neovim"}
  vim.g["test#neovim#term_position"] = "vert botright 60"
  vim.g["test#go#runner"] = "ginkgo"
  -- nmap <silent> t<C-n> :TestNearest<CR>
  -- nmap <silent> t<C-f> :TestFile<CR>
  -- nmap <silent> t<C-s> :TestSuite<CR>
  -- nmap <silent> t<C-l> :TestLast<CR>
  -- nmap <silent> t<C-g> :TestVisit<CR>
end

function config.mkdp()
  -- print("mkdp")
  vim.g.mkdp_command_for_global = 1
  vim.cmd(
      [[let g:mkdp_preview_options = { 'mkit': {}, 'katex': {}, 'uml': {}, 'maid': {}, 'disable_sync_scroll': 0, 'sync_scroll_type': 'middle', 'hide_yaml_meta': 1, 'sequence_diagrams': {}, 'flowchart_diagrams': {}, 'content_editable': v:true, 'disable_filename': 0 }]])
end

return config
