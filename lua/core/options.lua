local global = require("core.global")

local function bind_option(options)
  for k, v in pairs(options) do
    if v == true or v == false then
      vim.cmd("set " .. k)
    else
      vim.cmd("set " .. k .. "=" .. v)
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
    magic          = true;
    virtualedit    = "block";
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
    directory      = global.cache_dir .. "swag/";
    undodir        = global.cache_dir .. "undo/";
    backupdir      = global.cache_dir .. "backup/";
    viewdir        = global.cache_dir .. "view/";
    spellfile      = global.cache_dir .. "spell/en.uft-8.add";
    history        = 4000;
    shada          = "!,'300,<50,@100,s10,h";
    backupskip     = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim";
    smarttab       = true;
    smartindent    = true;
    shiftround     = true;
    lazyredraw     = true;
    timeout        = true;
    ttimeout       = true;
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
    switchbuf      = "useopen";
    backspace      = "indent,eol,start";
    diffopt        = "filler,iwhite,internal,algorithm:patience";
    completeopt = "menuone,noselect,noinsert", -- Show popup menu, even if there is one entry  menuone?
    jumpoptions    = "stack";
    showmode       = false;
    shortmess      = "aotTIcF";
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
    showcmd        = false;
    cmdwinheight   = 5;
    equalalways    = false;
    laststatus     = 3;
    display        = "lastline";
    showbreak      = "﬌  ";
    listchars = "tab:┊ ,nbsp:+,trail:·,extends:→,precedes:←"; -- tab:»·,
    pumblend       = 10;
    winblend       = 10;
    syntax         = "off";
    title          = true;
    background     = "dark";
--------------------------------------
    ttyfast = true, -- Indicate fast terminal conn for faster redraw
    fileencoding = "utf-8", -- fenc
    mouse = "a",
    textwidth = 120, -- wrap lines at 120 chars. 80 is somewaht antiquated with nowadays displays.
    hlsearch = true, -- Highlight found searches
    -- showcmd        = false;
    -- cmdheight = 0,
    autowrite = true, -- Automatically save before :next, :make etc.
    autoread = true, -- Automatically read changed files
    breakindent = true, -- Make it so that long lines wrap smartly
    breakindentopt = "shift:2,min:20";
    showmatch = true, -- highlight matching braces
    numberwidth = 3,
    relativenumber = true,
    conceallevel   = 2;
    concealcursor  = "niv";
    linebreak      = true;
    colorcolumn    = "110";
    foldenable     = true;
    signcolumn     = "auto:1";  --auto auto:2  "number"
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
    vim.g.python3_host_prog = '/usr/local/bin/python3'
  else
    vim.g.python3_host_prog = '/usr/bin/python3'
  end
  for name, value in pairs(global_local) do
    vim.o[name] = value
  end
  local window_local = {
      -- foldmethod = "indent", -- indent? expr?  expr is slow for large files
      relativenumber = true,
      number = true,
      foldenable = true,
    }

  for name, value in pairs(window_local) do
    vim.wo[name] = value
  end

  for name, value in pairs(bw_local) do
    vim.bo[name] = value
  end
end

-- stylua: ignore end

vim.cmd([[syntax off]])
vim.cmd([[set viminfo-=:42 | set viminfo+=:1000]])

load_options()
