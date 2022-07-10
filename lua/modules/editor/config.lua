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
end

function config.substitute()
  require("substitute").setup({
    yank_substituted_text = true,
    on_substitute = function(event)
      require("yanky").init_ring("p", event.register, event.count, event.vmode:match("[vV�]"))
    end,
  })
  vim.keymap.set("n", "<Space>s", "<cmd>lua require('substitute').operator()<cr>", { noremap = true })
  -- vim.keymap.set("n", "<Space>ss", "<cmd>lua require('substitute').line()<cr>", { noremap = true })
  vim.keymap.set("n", "<Space>S", "<cmd>lua require('substitute').eol()<cr>", { noremap = true })
  vim.keymap.set("x", "<Space>s", "<cmd>lua require('substitute').visual()<cr>", { noremap = true })

  vim.keymap.set(
    "n",
    "<Leader>S",
    "<cmd>lua require('substitute.range').operator({ prefix = 'S' })<cr>",
    { noremap = true, desc = "substitute" }
  )
  vim.keymap.set(
    "x",
    "<leader>S",
    "<cmd>lua require('substitute.range').visual()<cr>",
    { noremap = true, desc = "substitute range" }
  )
  vim.keymap.set(
    "n",
    "<Leader>ss",
    "<cmd>lua require('substitute.range').word()<cr>",
    { noremap = true, desc = "substitute range" }
  )
end

function config.lightspeed()
  -- you can configure Hop the way you like here; see :h hop-config
  require("lightspeed").setup({
    jump_to_first_match = true,
    jump_on_partial_input_safety_timeout = 400,
    -- This can get _really_ slow if the window has a lot of content,
    -- turn it on only if your machine can always cope with it.
    highlight_unique_chars = false,
    grey_out_search_area = true,
    match_only_the_start_of_same_char_seqs = true,
    limit_ft_matches = 5,
    full_inclusive_prefix_key = "<c-x>",
    -- For instant-repeat, pressing the trigger key again (f/F/t/T)
    -- always works, but here you can specify additional keys too.
    instant_repeat_fwd_key = ";",
    instant_repeat_bwd_key = ":",
    -- By default, the values of these will be decided at runtime,
    -- based on `jump_to_first_match`.
    labels = nil,
    cycle_group_fwd_key = "]",
    cycle_group_bwd_key = "[",
  })
  function repeat_ft(reverse)
    local ls = require("lightspeed")
    ls.ft["instant-repeat?"] = true
    ls.ft:to(reverse, ls.ft["prev-t-like?"])
  end
  vim.api.nvim_set_keymap("n", ";", "<cmd>lua repeat_ft(false)<cr>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("x", ";", "<cmd>lua repeat_ft(false)<cr>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", ",", "<cmd>lua repeat_ft(true)<cr>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("x", ",", "<cmd>lua repeat_ft(true)<cr>", { noremap = true, silent = true })
end

function config.comment()
  require("Comment").setup({
    extended = true,
    pre_hook = function(ctx)
      -- print("ctx", vim.inspect(ctx))
      -- Only update commentstring for tsx filetypes
      if
        vim.bo.filetype == "typescriptreact"
        or vim.bo.filetype == "javascript"
        or vim.bo.filetype == "css"
        or vim.bo.filetype == "html"
      then
        require("ts_context_commentstring.internal").update_commentstring()
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
  -- vim.cmd([[packadd nvim-hlslens]])
  vim.cmd([[noremap <silent> n <Cmd>execute('normal! ' . v:count1 . 'n')<CR> <Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap <silent> N <Cmd>execute('normal! ' . v:count1 . 'N')<CR> <Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap * *<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap # #<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap g* g*<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap g# g#<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[nnoremap <silent> <leader>l :noh<CR>]])
  require("hlslens").setup({
    calm_down = true,
    -- nearest_only = true,
    nearest_float_when = "always",
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
  -- vim.api.nvim_set_keymap("n", "<M-n>", "<C-n>", {silent = true})
  -- vim.api.nvim_set_keymap("n", "<M-Down>", "<C-Down>", {silent = true})
  -- vim.api.nvim_set_keymap("n", "<M-Up>", "<C-Up>", {silent = true})
  -- for mac C-L/R was mapped to mission control
  -- print('vmulti')
  vim.g.VM_silent_exit = 1
  vim.g.VM_show_warnings = 0
  vim.g.VM_default_mappings = 1
  vim.cmd([[
      let g:VM_maps = {}
      let g:VM_maps['Find Under'] = '<C-n>'
      let g:VM_maps['Find Subword Under'] = '<C-n>'
      let g:VM_maps['Select All'] = '<C-M-n>'
      let g:VM_maps['Seek Next'] = 'n'
      let g:VM_maps['Seek Prev'] = 'N'
      let g:VM_maps["Undo"] = 'u'
      let g:VM_maps["Redo"] = '<C-r>'
      let g:VM_maps["Remove Region"] = '<cr>'
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

return config
