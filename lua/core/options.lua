local global = require('core.global')
local sep = require('core.global').path_sep

local function bind_option(options)
  for k, v in pairs(options) do
    if v == true or v == false then
      vim.cmd('set ' .. k)
    else
      vim.cmd('set ' .. k .. '=' .. v)
    end
  end
end

-- stylua: ignore start
local function load_options()
  local global_local = {
    termguicolors  = true;
    errorbells     = false;
    visualbell     = true;
    hidden         = true;
    fileformats    = "unix,mac,dos";
    -- fileformat    = "unix";
    -- magic          = true; -- already default
    virtualedit    = "onemore";
    encoding       = "utf-8";
    viewoptions    = "folds,cursor,curdir,slash,unix";
    sessionoptions = "curdir,help,tabpages,winsize";
    clipboard      = "unnamedplus";
    wildignorecase = true;
    wildignore     = ".git/**,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**";
    backup         = true;
    writebackup    = true;
    undofile       = true;
    swapfile       = false;
    directory      = global.cache_dir .. sep .. "swag" .. sep;
    undodir        = global.cache_dir .. sep .. "undo" .. sep;
    backupdir      = global.cache_dir .. sep .. "backup" .. sep;
    viewdir        = global.cache_dir .. sep .. "view" .. sep;
    -- spellfile      = global.cache_dir .. sep .. "spell" .. sep .. "en.uft-8.add";
    history        = 4000;
    shada          = "!,'1000,f1,<500,@100,/100,:100,s10,h";
    backupskip     = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim";
    -- smarttab       = true;
    smartindent    = true;
    shiftround     = true;
    -- lazyredraw     = true;
    timeout        = true;
    -- ttimeout       = true;
    timeoutlen     = 500;
    ttimeoutlen    = 10;
    updatetime     = 500;
    redrawtime     = 100;
    ignorecase     = true;
    smartcase      = true;
    infercase      = true;
    incsearch      = true, -- Shows the match while typing
    wrap           = true;
    wrapscan       = true;
    complete       = ".,w,b,k";
    inccommand     = "nosplit";  --split
    grepformat     = "%f:%l:%m,%m\\ %f\\ match%ts,%f", -- "%f:%l:%c:%m";
    grepprg        = 'rg --hidden --vimgrep --smart-case --glob "!{.git,node_modules,*~}/*" --';
    breakat        = [[\ \	;:,!?]];
    startofline    = false;
    whichwrap      = "h,l,<,>,[,],~";
    splitbelow     = true;
    splitright     = true;
    switchbuf      = "useopen,usetab";
    backspace      = "indent,eol,start";
    diffopt        = "filler,iwhite,internal,algorithm:patience";
    completeopt    = "menu,menuone,noselect", -- Show popup menu, even if there is one entry  menuone?
    jumpoptions    = "stack";
    showmode       = false;
    shortmess      = "aotTIcFC";
    scrolloff      = 2;
    sidescrolloff  = 5;
    foldlevel      = 99;
    foldlevelstart = 99;
    ruler          = false;
    list           = true;
    showtabline    = 1;
    winwidth       = 30;
    winminwidth    = 10;
    pumheight      = 15;
    helpheight     = 12;
    previewheight  = 12;
    showcmd        = true;
    showcmdloc     = 'statusline';
    cmdwinheight   = 5;
    equalalways    = false;
    laststatus     = 3;
    display        = "lastline";
    showbreak      = "󱞩";
    listchars      = "tab:┊ ,nbsp:+,trail:·,extends:→,precedes:←"; -- tab:»·,
    pumblend       = 10;
    winblend       = 10;
    title          = true;

    background     = "dark";
    mousemodel     = "extend";
-- --------------------------------------
    ttyfast        = true, -- Indicate fast terminal conn for faster redraw
    fileencoding   = "utf-8",
    mouse          = "a",
    textwidth      = 120, -- wrap lines at 120 chars. 80 is somewaht antiquated with nowadays displays.
    hlsearch       = true, -- Highlight found searches
    -- showcmd     = false;
    cmdheight      = 1,
    autowrite      = true, -- Automatically save before :next, :make etc.
    autoread       = true, -- Automatically read changed files
    breakindent    = true, -- Make it so that long lines wrap smartly
    breakindentopt = "shift:2,min:20";
    showmatch      = true, -- highlight matching braces
    numberwidth    = 3,
    relativenumber = true,
    conceallevel   = 2;
    concealcursor  = "niv";
    linebreak      = true;
    colorcolumn    = "110";
    foldenable     = true;
    signcolumn     = "auto:1";  --auto auto:2  "number"
    cursorline     = false;
    number         = true;
    splitkeep      = "screen";
  }

  local bw_local  = {
    synmaxcol = 2000, -- handle long lines, esp html
    formatoptions  = "1jcroql";
    textwidth = 120,
    expandtab      = true;
    autoindent     = true;
    tabstop        = 2;
    shiftwidth     = 2;
    softtabstop    = -1;
  }

  if global.is_mac then
    vim.g.clipboard = {
      name = "macOS-clipboard",
      copy = {
        ["+"] = "pbcopy",
        ["*"] = "pbcopy",
      },
      paste = {
        ["+"] = "pbpaste",
        ["*"] = "pbpaste",
      },
      cache_enabled = 0
    }
    vim.g.python3_host_prog = '/opt/homebrew/bin/python3'
  elseif global.is_linux then
    vim.g.python3_host_prog = '/usr/bin/python3'
  elseif global.is_mingw then
    vim.g.python3_host_prog = 'C:\\msys64\\mingw64\\bin\\python3.exe'
  else
    -- windows
    vim.g.python3_host_prog = 'C:\\Python312\\python.exe'
    if vim.fn.executable(vim.g.python3_host_prog)  == 0 then
      local p = vim.fn.system('where python')
      if p ~= '' then
        p = vim.fn.split(p, '\n')[1]
        if p ~= '' then
          vim.g.python3_host_prog = vim.trim(p)
        else
          print('could not find python install path')
        end
      end

      print('please setup python path in options.lua')
    end
  end
  for name, value in pairs(global_local) do
    vim.o[name] = value
  end
  local window_local = {
      foldmethod = "expr",
      relativenumber = true,
      number = true,
      foldenable = true,
    }

  if vim.opt.diff:get() then
    global_local = vim.tbl_extend('force', global_local, {
      foldmethod = "diff", diffopt = 'context:0', foldlevel = 10, mouse = 'a'
    })
  end

  for name, value in pairs(window_local) do
    vim.wo[name] = value
  end

  for name, value in pairs(bw_local) do
    vim.bo[name] = value
  end
  local opts = {
    foldmethod = "expr",
    foldenable = true,
    foldcolumn = "1",  -- I feel the fold column is distracting
    foldexpr = "v:lua.vim.treesitter.foldexpr()",  -- will be overwrite by navigator
    -- alternatives = ⣿ ░ ─
    -- stylua: ignore
    fillchars = { foldclose = "", foldopen = "", vert = "│", fold = " ", diff = "░", msgsep = "", foldsep = "│" , eob = ' '},
  }
  opts.foldtext = ""
  for n, v in pairs(opts) do
    vim.opt[n] = v
  end
end


local function get_signs()
  local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  return vim.tbl_map(function(sign)
    return vim.fn.sign_getdefined(sign.name)[1]
  end, vim.fn.sign_getplaced(buf, { group = "*", lnum = vim.v.lnum })[1].signs)
end

function _G.column()
  local sign, git_sign
  for _, s in ipairs(get_signs()) do
    if s.name:find("GitSign") then
      git_sign = s
    else
      sign = s
    end
  end

  local nu = ""

  local number = vim.api.nvim_win_get_option(vim.g.statusline_winid, "number")
  if number and vim.wo.relativenumber and vim.v.virtnum == 0 then
    nu = vim.v.relnum == 0 and vim.v.lnum or vim.v.relnum
  end
  local gs = git_sign and git_sign.text and ("%#" .. (git_sign.texthl or '') .. "#" .. git_sign.text .. "%*") or ""
  local diag = sign and sign.text and ("%#" .. (sign.texthl or '') .. "#" .. sign.text .. "%*") or ""
  local pad = ' '
  if gs ~= '' or diag ~= '' then
    pad = ''
  end
  local components = {
    gs,
    diag,
    [[%=]],
    nu .. pad,
  }
  return table.concat(components, "")
end

if vim.fn.has("nvim-0.10.0") == 1 then
  vim.opt.completeopt    = "menu,menuone,popup" -- Show popup menu, even if there is one entry  menuone?
  -- vim.opt.statuscolumn = [[%!v:lua.column()]]
end

if vim.wo.diff then
  vim.o.cursorline = true
end
vim.cmd('set path+=**')
-- stylua: ignore end

vim.cmd([[autocmd TermOpen * setlocal nospell]])
vim.cmd([[autocmd TermOpen,BufEnter term://* startinsert]])
vim.cmd([[tnoremap <Esc>q <C-\><C-n>]])
if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0.01
  vim.g.neovide_cursor_trail_length = 0.05
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_remember_window_size = true
  vim.cmd([[set guifont=JetBrainsMono\ Nerd\ Font:h16]])
end

vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    vim.opt_local.spell = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.filetype = 'terminal'
  end,
  group = vim.api.nvim_create_augroup('terminal_settings', {}),
})

load_options()
