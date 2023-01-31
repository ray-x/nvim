local config = {}

function config.autopairs()
  local has_autopairs, autopairs = pcall(require, "nvim-autopairs")
  if not has_autopairs then
    print("autopairs not loaded")

    local loader = require("packer").loader
    loader("nvim-autopairs")
    has_autopairs, autopairs = pcall(require, "nvim-autopairs")
    if not has_autopairs then
      print("autopairs not installed")
      return
    end
  end
  local npairs = require("nvim-autopairs")
  local Rule = require("nvim-autopairs.rule")
  npairs.setup({
    disable_filetype = { "TelescopePrompt", "guihua", "guihua_rust", "clap_input" },
    autopairs = { enable = true },
    ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""), -- "[%w%.+-"']",
    enable_check_bracket_line = false,
    html_break_line_filetype = { "html", "vue", "typescriptreact", "svelte", "javascriptreact" },
    check_ts = true,
    ts_config = {
      lua = { "string" }, -- it will not add pair on that treesitter node
      -- go = {'string'},
      javascript = { "template_string" },
      java = false, -- don't check treesitter on java
    },
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'", "`" },
      pattern = string.gsub([[ [%'%"%`%+%)%>%]%)%}%,%s] ]], "%s+", ""),
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      hightlight = "Search",
    },
  })
  local ts_conds = require("nvim-autopairs.ts-conds")
  -- you need setup cmp first put this after cmp.setup()

  npairs.add_rules({
    Rule(" ", " "):with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({ "()", "[]", "{}" }, pair)
    end),
    Rule("(", ")"):with_pair(function(opts)
      return opts.prev_char:match(".%)") ~= nil
    end):use_key(")"),
    Rule("{", "}"):with_pair(function(opts)
      return opts.prev_char:match(".%}") ~= nil
    end):use_key("}"),
    Rule("[", "]"):with_pair(function(opts)
      return opts.prev_char:match(".%]") ~= nil
    end):use_key("]"),
    Rule("%", "%", "lua") -- press % => %% is only inside comment or string
      :with_pair(ts_conds.is_ts_node({ "string", "comment" })),
    Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node({ "function" })),
  })

  -- If you want insert `(` after select function or method item
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  local cmp = require("cmp")
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))

  if load_coq() then
    local remap = vim.api.nvim_set_keymap
    local npairs = require("nvim-autopairs")

    npairs.setup({ map_bs = false })

    vim.g.coq_settings = { keymap = { recommended = false } }

    -- these mappings are coq recommended mappings unrelated to nvim-autopairs
    remap("i", "<esc>", [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
    remap("i", "<c-c>", [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
    remap("i", "<tab>", [[pumvisible() ? "<c-n>" : "<tab>"]], { expr = true, noremap = true })
    remap("i", "<s-tab>", [[pumvisible() ? "<c-p>" : "<bs>"]], { expr = true, noremap = true })

    -- skip it, if you use another global object
    _G.MUtils = {}

    MUtils.CR = function()
      if vim.fn.pumvisible() ~= 0 then
        if vim.fn.complete_info({ "selected" }).selected ~= -1 then
          return npairs.esc("<c-y>")
        else
          -- you can change <c-g><c-g> to <c-e> if you don't use other i_CTRL-X modes
          return npairs.esc("<c-g><c-g>") .. npairs.autopairs_cr()
        end
      else
        return npairs.autopairs_cr()
      end
    end
    remap("i", "<cr>", "v:lua.MUtils.CR()", { expr = true, noremap = true })

    MUtils.BS = function()
      if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ "mode" }).mode == "eval" then
        return npairs.esc("<c-e>") .. npairs.autopairs_bs()
      else
        return npairs.autopairs_bs()
      end
    end
    remap("i", "<bs>", "v:lua.MUtils.BS()", { expr = true, noremap = true })
  end

  -- print("autopairs setup")
  -- skip it, if you use another global object
end

local esc = function(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

function config.hydra()
  local hydra = require("modules.editor.hydra")
end
function config.hexokinase()
  vim.g.Hexokinase_optInPatterns = {
    "full_hex",
    "triple_hex",
    "rgb",
    "rgba",
    "hsl",
    "hsla",
    "colour_names",
  }
  vim.g.Hexokinase_highlighters = {
    "virtual",
    "sign_column", -- 'background',
    "backgroundfull",
    -- 'foreground',
    -- 'foregroundfull'
  }
end

function config.yanky()
  require("yanky").setup({
    highlight = {
      on_put = true,
      on_yank = true,
      timer = 500,
    },
  })
  local utils = require("yanky.utils")
  local mapping = require("yanky.telescope.mapping")
  require("telescope").load_extension("yank_history")
  require("yanky").setup({
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
          default = mapping.put("p"),
          i = {
            ["<c-p>"] = mapping.put("p"),
            ["<c-k>"] = mapping.put("P"),
            ["<c-x>"] = mapping.delete(),
            ["<c-r>"] = mapping.set_register(utils.get_default_register()),
          },
          n = {
            p = mapping.put("p"),
            P = mapping.put("P"),
            gp = mapping.put("gp"),
            gP = mapping.put("gP"),
            d = mapping.delete(),
            r = mapping.set_register(utils.get_default_register()),
          },
        },
      },
    },
  })

  -- vim.api.nvim_set_hl(0, "YankyPut", { link = "Search" })
  -- vim.api.nvim_set_hl(0, "YankyYanked", { link = "Search" })
end

-- <Space>siw replace word
-- x mode <Space>s replace virtual select.
-- dot operator  repeat
-- space-s
function config.substitute()
  require("substitute").setup({
    yank_substituted_text = true,
    range = {
      prefix = "S",
      prompt_current_text = true,
    },
    on_substitute = function(event)
      require("yanky").init_ring("p", event.register, event.count, event.vmode:match("[vV]"))
    end,
  })
end

function config.comment()
  require("Comment").setup({
    extended = true,
    pre_hook = function(ctx)
      -- print("ctx", vim.inspect(ctx))
      -- Only update commentstring for tsx filetypes
      if
        vim.bo.filetype == "typescriptreact"
        or vim.bo.filetype == "typescript"
        or vim.bo.filetype == "javascript"
        or vim.bo.filetype == "css"
        or vim.bo.filetype == "html"
        or vim.bo.filetype == "scss"
        or vim.bo.filetype == "svelte"
        or vim.bo.filetype == "uve"
        or vim.bo.filetype == "graphql"
      then
        local U = require("Comment.utils")
        -- Determine whether to use linewise or blockwise commentstring
        local type = ctx.ctype == U.ctype.linewise and "__default" or "__multiline"

        local location = nil
        if ctx.ctype == U.ctype.block then
          location = require("ts_context_commentstring.utils").get_cursor_location()
        elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
          location = require("ts_context_commentstring.utils").get_visual_start_location()
        end

        return require("ts_context_commentstring.internal").calculate_commentstring({
          key = type,
          location = location,
        })
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

function config.ufo()
  --- not all LSP support this
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = ("  %d "):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if targetWidth > curWidth + chunkWidth then
        table.insert(newVirtText, chunk)
      else
        chunkText = truncate(chunkText, targetWidth - curWidth)
        local hlGroup = chunk[2]
        table.insert(newVirtText, { chunkText, hlGroup })
        chunkWidth = vim.fn.strdisplaywidth(chunkText)
        -- str width returned from truncate() may less than 2nd argument, need padding
        if curWidth + chunkWidth < targetWidth then
          suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
        end
        break
      end
      curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, "MoreMsg" })
    return newVirtText
  end
  local whitelist = {
    ["gotmpl"] = "indent",
    ["python"] = "lsp",
    ["html"] = "indent",
  }
  require("ufo").setup({
    -- fold_virt_text_handler = handler,
    provider_selector = function(bufnr, filetype)
      if whitelist[filetype] then
        return whitelist[filetype]
      end
      return ""
    end,
  })
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.o.ft
  if whitelist[ft] then
    require("ufo").setVirtTextHandler(bufnr, handler)
  end
end

function config.orgmode()
  local loader = require("packer").loader
  if not packer_plugins["nvim-treesitter"].loaded then
    loader("nvim-treesitter")
  end
  vim.cmd("set foldlevel=2")

  require("orgmode").setup_ts_grammar()
  require("nvim-treesitter.configs").setup({
    -- If TS highlights are not enabled at all, or disabled via `disable` prop,
    -- highlighting will fallback to default Vim syntax highlighting
    highlight = {
      enable = true,
      -- Required for spellcheck, some LaTex highlights and
      -- code block highlights that do not have ts grammar
      additional_vim_regex_highlighting = { "org" },
    },
    ensure_installed = { "org" }, -- Or run :TSUpdate org
  })
  require("orgmode").setup({
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
    org_todo_keywords = { "TODO", "WIP", "|", "DONE", "WAITING", "PENDING", "HOLD", "CANCELLED", "ASSIGNED" },
    org_todo_keyword_faces = {
      WAITING = ":foreground yellow",
      TODO = ":foreground coral",
      DONE = ":foreground chartreuse",
      WIP = ":foreground cyan", -- overrides builtin color for `TODO` keyword
      HOLD = ":foreground ivory", -- overrides builtin color for `TODO` keyword
      PENDING = ":foreground yellow", -- overrides builtin color for `TODO` keyword
      ASSIGNED = ":foreground lightgreen", -- overrides builtin color for `TODO` keyword
      CANCELLED = ":foreground darkgreen", -- overrides builtin color for `TODO` keyword
      -- DELEGATED = ':background #FFFFFF :slant italic :underline on :forground #000000',
    },
    org_capture_templates = {
      v = {
        description = "Visual todo (reg v)",
        template = '* TODO %(return vim.fn.getreg "v")\n %u',
      },
      m = {
        description = "Meeting notes",
        template = "#+TITLE: %?\n#+AUTHER: Ray\n#+TAGS: @metting \n#+DATE: %t\n\n*** %^{PROMPT|Meeting|LOGGING WGM} %U \n - %?\n<%<%Y-%m-%d %a %H:%M>>",
      },
      r = {
        description = "ritual",
        template = '* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string "%<<%Y-%m-%d %a .+1d/3d>>")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n',
        target = string.format("~/Desktop/logseq/pages/%s.org", vim.fn.strftime("%Y-%m-%d")),
      },
      n = {
        description = "Notes",
        template = "#+TITLE: %?\n#+AUTHER: Ray\n#+TAGS: @note \n#+DATE: %t\n",
        target = string.format("~/Desktop/logseq/pages/%s.org", vim.fn.strftime("%Y-%m-%d")),
      },
      j = {
        description = "Journal",
        template = "#+TITLE: %?\n#+TAGS: @journal \n#+DATE: %t\n",
        target = string.format("~/Desktop/logseq/journals/%s.org", vim.fn.strftime("%Y-%m-%d")),
      },
    },
    notifications = {
      reminder_time = { 0, 1, 5, 10 },
      repeater_reminder_time = { 0, 1, 5, 10 },
      deadline_warning_reminder_time = { 0 },
      cron_notifier = function(tasks)
        for _, task in ipairs(tasks) do
          local title = string.format("%s (%s)", task.category, task.humanized_duration)
          local subtitle = string.format("%s %s %s", string.rep("*", task.level), task.todo, task.title)
          local date = string.format("%s: %s", task.type, task.time:to_string())

          if vim.fn.executable("notify-send") then
            vim.loop.spawn("notify-send", {
              args = {
                "--icon=/home/kristijan/.local/share/nvim/lazy/orgmode/assets/orgmode_nvim.png",
                string.format("%s\n%s\n%s", title, subtitle, date),
              },
            })
          end
        end
      end,
    },
  })
  vim.opt.conceallevel = 2
  vim.cmd("set foldlevel=2")
end
function config.neorg()
  local loader = require("packer").loader
  if not packer_plugins["nvim-treesitter"].loaded then
    loader("nvim-treesitter")
  end
  if not packer_plugins["neorg-telescope"].loaded then
    loader("telescope.nvim")
    loader("neorg-telescope")
  end

  require("neorg").setup({
    -- Tell Neorg what modules to load
    load = {
      ["core.defaults"] = {}, -- Load all the default modules
      ["core.norg.concealer"] = {}, -- Allows for use of icons
      ["core.norg.dirman"] = { -- Manage your directories with Neorg
        config = { workspaces = { my_workspace = "~/neorg" } },
      },
      ["core.keybinds"] = { -- Configure core.keybinds
        config = {
          default_keybinds = true, -- Generate the default keybinds
          neorg_leader = "<Leader>o", -- This is the default if unspecified
        },
      },
      ["core.norg.completion"] = { config = { engine = "nvim-cmp" } },
      ["core.integrations.telescope"] = {}, -- Enable the telescope module
    },
  })
  local neorg_callbacks = require("neorg.callbacks")

  neorg_callbacks.on_event("core.keybinds.events.enable_keybinds", function(_, keybinds)
    -- Map all the below keybinds only when the "norg" mode is active
    keybinds.map_event_to_mode("norg", {
      n = { -- Bind keys in normal mode
        { "<C-s>", "core.integrations.telescope.find_linkable" },
      },

      i = { -- Bind in insert mode
        { "<C-l>", "core.integrations.telescope.insert_link" },
      },
    }, { silent = true, noremap = true })
  end)
end

function config.move()
  require("gomove").setup({
    -- whether or not to map default key bindings, (true/false)
    map_defaults = true,
    -- what method to use for reindenting, ("vim-move" / "simple" / ("none"/nil))
    reindent_mode = "vim-move",
    -- whether to not to move past line when moving blocks horizontally, (true/false)
    move_past_line = false,
    -- whether or not to ignore indent when duplicating lines horizontally, (true/false)
    ignore_indent_lh_dup = true,
  })
end

function config.hlslens()
  -- body
  require("hlslens").setup({
    calm_down = true,
    -- nearest_only = true,
    nearest_float_when = "auto",
  })
  local kopts = { noremap = true, silent = true }

  vim.api.nvim_set_keymap(
    "n",
    "n",
    [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
    kopts
  )
  vim.api.nvim_set_keymap(
    "n",
    "N",
    [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
    kopts
  )
  vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
  vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
  vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
  vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

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

function config.searchx()
  vim.cmd([[
    " Overwrite / and ?.
    nnoremap ? <Cmd>call searchx#start({ 'dir': 0 })<CR>
    nnoremap / <Cmd>call searchx#start({ 'dir': 1 })<CR>
    xnoremap ? <Cmd>call searchx#start({ 'dir': 0 })<CR>
    xnoremap / <Cmd>call searchx#start({ 'dir': 1 })<CR>
    cnoremap ; <Cmd>call searchx#select()<CR>

    " Move to next/prev match.
    nnoremap N <Cmd>call searchx#prev_dir()<CR>
    nnoremap n <Cmd>call searchx#next_dir()<CR>
    xnoremap N <Cmd>call searchx#prev_dir()<CR>
    xnoremap n <Cmd>call searchx#next_dir()<CR>
    nnoremap <C-k> <Cmd>call searchx#prev()<CR>
    nnoremap <C-j> <Cmd>call searchx#next()<CR>
    xnoremap <C-k> <Cmd>call searchx#prev()<CR>
    xnoremap <C-j> <Cmd>call searchx#next()<CR>
    cnoremap <C-k> <Cmd>call searchx#prev()<CR>
    cnoremap <C-j> <Cmd>call searchx#next()<CR>

    " Clear highlights
    nnoremap <C-l> <Cmd>call searchx#clear()<CR>

    let g:searchx = {}

    " Auto jump if the recent input matches to any marker.
    let g:searchx.auto_accept = v:true

    " The scrolloff value for moving to next/prev.
    let g:searchx.scrolloff = &scrolloff

    " To enable scrolling animation.
    let g:searchx.scrolltime = 500

    " Marker characters.
    let g:searchx.markers = split('ABCDEFGHIJKLMNOPQRSTUVWXYZ', '.\zs')

    " Convert search pattern.
    function g:searchx.convert(input) abort
      if a:input !~# '\k'
        return '\V' .. a:input
      endif
      return join(split(a:input, ' '), '.\{-}')
    endfunction


  ]])
end

config.headline = function()
  vim.cmd([[highlight Headline1 guibg=#042030]])
  vim.cmd([[highlight Headline2 guibg=#141030]])
  -- vim.cmd([[highlight link Headline2 Function]])
  vim.cmd([[highlight CodeBlock guibg=#10101c]])
  vim.cmd([[highlight Dash guibg=#D19A66 gui=bold]])
  require("headlines").setup({
    markdown = { fat_headlines = true, headline_highlights = { "Headline1", "Headline2" } },
    org = { fat_headlines = false, headline_highlights = { "Headline1", "Headline2" } },
    neorg = { fat_headlines = true, headline_highlights = { "Headline1", "Headline2" } },
  })
end

return config
