M = {}
local ns = vim.api.nvim_create_namespace("color_galaxy")
local function hl(name, val)
  vim.api.nvim_set_hl(ns, name, val)
end
-- TODO:
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/master/doc/nvim-treesitter.txt#L450

local c = {
  black = "#101010",
  black_two = "#282828",
  white = "#FFFFFF",
  white_two = "#CECECE",

  gray_one = "#B5B5B5",

  green_one = "#BCFF7B",
  green_two = "#66FF61",
  green_three = "#B8BB26",
  green_four = "#9ABB26",
  green_five = "#59DE73",
  green_six = "#3AF8B7",

  blue_one = "#3572A5",
  blue_two = "#519ABA",
  blue_three = "#73EACC",
  blue_four = "#5BD0DE",
  blue_five = "#316AD0",
  blue_six = "#3FC0D0",
  blue_seven = "#4B93D1",

  purple_one = "#95179C",
  purple_two = "#D9ACF4",
  purple_four = "#755799",

  yellow_one = "#ECF683",

  red_one = "#FF7263",
  red_two = "#FF91A4",
  red_three = "#D82B26",
  red_four = "#FB4934",

  pink = "#FFB5F3",

  orange_one = "#FE8019",

  background_one = "#3C3836",
  background_two = "#262729",
  background_three = "#504945",
  background_three_two = "#546442",
}

local back = nil

local Usual = {
  UsualHighlights = {
    Normal = { bg = back },
    NormalFloat = { bg = c.background_two, fg = c.white_two },
    Identifier = { fg = c.green_two },
    Keyword = { fg = c.purple_two },
    FloatBorder = { fg = c.blue_four, bg = c.background_one },
    netrwDir = { fg = c.green_six },
    netrwList = { fg = c.green_four },
    NonText = { bg = back },
    LineNr = { fg = c.background_two },
    SignColumn = { bg = nil },
    CursorLine = { bg = c.purple_four },
    CursorColumn = { bg = c.purple_four },
    CursorLineNr = { fg = c.yellow_one, bold = true, underline = true },
    StatusLine = { fg = c.white_two, bg = c.background_three },
    StatusLineNC = { fg = c.white_two, bg = c.background_three_two },
    ModeMsg = { fg = c.green },
    Question = { fg = c.blue },
    WarningMsg = { fg = c.pink },
    WildMenu = { fg = c.white_two, bg = c.background_three },
    Title = { fg = c.white_two, bold = true },
    Cursor = { bg = c.orange_one },
    SpecialKey = { fg = c.green_five },
    Search = { fg = c.black_two, bg = c.yellow_one, bold = true },
    IncSearch = { fg = c.black_two, bg = c.orange_one, bold = true },
    Folded = { fg = c.blue_seven, bold = true, italic = true },
    Visual = { reverse = true },
    VisualNOS = { bg = c.background_three },
    EndOfBuffer = { bg = back },
    Comment = { fg = c.blue_seven, bold = true, italic = true },
    preProc = { fg = c.blue_four },
    Matchparen = { underline = true },
    Pmenu = { fg = c.white_two, bg = c.background_two },
    Pmenusel = { fg = c.white, bg = c.purple_one },
    VertSplit = { fg = c.background_three_two },
  },
  Vim = {
    VimCommand = { fg = c.purple_two },
    VimVar = { fg = c.blue_three },
    VimString = { fg = c.white },
    VimAttrib = { fg = c.green_one },
    VimHiAttrib = { fg = c.green_one },
    VimOption = { fg = c.green_four },
    VimIsCommand = { fg = c.orange_one },
    VimUsrCmd = { fg = c.orange_one },
    VimHiGroup = { fg = c.blue_five },
    VimGroup = { fg = c.blue_five },
    VimHiGuiFgBg = { fg = c.yellow_one, bold = true },
    VimHiCtermFgBg = { fg = c.yellow_one, bold = true },
    VimHiCterm = { fg = c.yellow_one, bold = true },
    VimHiTermFgBg = { fg = c.yellow_one, bold = true },
    VimFgBgAttrib = { fg = c.green_five },
  },
  Diff = {
    diffAdded = { fg = c.green_two, bold = true },
    diffRemoved = { fg = c.purple_two, bold = true },
    gitDiff = { fg = c.white },
    diffLine = { fg = c.blue_three },
  },
  TSHighlights = {
    NodeNumber = { fg = c.blue_five },
    NodeOp = { fg = c.red_four },
    TSVariable = { fg = c.yellow_one },
    TSComment = { fg = c.blue_seven, bold = true, italic = true },
    TSInclude = { fg = c.blue_four, italic = true, bold = true },
    TSKeywordOperator = { fg = c.purple_two },
    TSConditional = { fg = c.purple_two },
    TSNumber = { fg = c.pink },
    TSFloat = { fg = c.pink },
    TSOperator = { fg = c.green_six },
    TSKeyword = { fg = c.purple_two, italic = true },
    TSString = { fg = c.green_five },
    TSConstant = { fg = c.blue_three },
    TSProperty = { fg = c.blue_three },
    TSField = { fg = c.pink },
    TSBoolean = { fg = c.purple_one, bold = true, italic = true },
    TSRepeat = { fg = c.red_two },
    TSKeywordFunction = { fg = c.red_two },
    TSFunction = { fg = c.blue_one, bold = true },
    TSMethod = { fg = c.green_two, bold = true },
    TSType = { fg = c.red_two },
    TSTypeBuiltin = { fg = c.purple_two, italic = true },
    TSException = { fg = c.blue_four },
    TSEnvironmentName = { fg = c.blue_four },
    TSTitle = { fg = c.green_one },
    TSEnvironment = { fg = c.red_two },
  },

  LspRelated = {
    DiagnosticsDefaultError = { bg = back, fg = c.red_four },
    DiagnosticsDefaultHint = { bg = back, fg = c.pink },
    DiagnosticsDefaultWarning = { bg = back, fg = c.orange_one },
    DiagnosticsDefaultInformation = { bg = back, fg = c.yellow_one },

    DiagnosticError = { fg = c.red_one, bold = true }, -- used to underline "Error" diagnostics.
    DiagnosticWarn = { fg = c.orange_one, bold = true }, -- used to underline "Error" diagnostics.
    DiagnosticInfo = { fg = c.green_one }, -- used to underline "Error" diagnostics.
    DiagnosticUnderlineError = { bold = true, undercurl = true, sp = c.red }, -- used to underline "Error" diagnostics.
    DiagnosticUnderlineWarn = { bold = true, undercurl = true, sp = c.orange_one }, -- used to underline "Error" diagnostics.
    DiagnosticUnderlineInfo = { bold = true, undercurl = true, sp = c.yellow }, -- used to underline "Error" diagnostics.
  },
  Packer = { packerStatusSuccess = { fg = c.blue_three }, packerString = { fg = c.blue_three } },
}

local lang = {
  lua = { RequireCall = { fg = c.purple_two, italic = true, bold = true } },
  norg = {
    NeorgHeading2 = { fg = c.yellow_one },
    NeorgMarker = { fg = c.yellow_one },
    NeorgMarkerTitle = { fg = c.yellow_one },
  },
}

local function add_highlight_table(tbl)
  for hl_grp, hl_value in pairs(tbl) do
    vim.api.nvim_set_hl(ns, hl_grp, hl_value)
  end
end

function M.Lang_high(ft)
  if vim.api.nvim_buf_is_valid(0) and vim.api.nvim_buf_is_loaded(0) then
    add_highlight_table(lang[ft] or {})
  end
end

function M.shine()
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "galaxy"

  for _, tbl in pairs(Usual) do
    add_highlight_table(tbl)
  end

  local bg = back or "none"
  vim.api.nvim__set_hl_ns(ns)
end

_G.colors = {
  red = "#BF616A",
  teal = "#97B7D7",
  one_bg = "#373D49",
  lightbg = "#3B4252",
  blue = "#81A1C1",
  cyan = "#5E81AC",
  black = "#2E3440",
  orange = "#D08770",
  one_bg2 = "#434C5E",
  foreground = "#E5E9F0",
  grey = "#4B515D",
  green = "#A3BE8C",
  purple = "#8FBCBB",
  one_bg3 = "#4C566A",
  light_grey = "#646A76",
  line = "#3A404C",
  white = "#D8DEE9",
  yellow = "#EBCB8B",
  lightbg2 = "#393F4B",
  dark_purple = "#B48EAD",
  pink = "#D57780",
  black2 = "#343A46",
  grey_fg = "#606672",
  baby_pink = "#DE878F",
  darker_black = "#2A303C",
}
vim.api.nvim__set_hl_ns(ns)
-- comment

-- vim.cmd([[packadd starry.nvim]])
-- local start = vim.loop.now()

M.shine()

-- bench test

-- local result = vim.loop.now() - start
-- vim.cmd("colorscheme starry")
-- vim.cmd("colorscheme limestone")
-- vim.cmd("colorscheme earlysummer")
-- vim.cmd("colorscheme starry")
-- vim.cmd("colorscheme limestone")
-- vim.cmd("colorscheme earlysummer")
-- vim.cmd("colorscheme starry")
-- vim.cmd("colorscheme limestone")
-- vim.cmd("colorscheme earlysummer")
-- vim.cmd("colorscheme starry")
-- vim.cmd("colorscheme limestone")
-- vim.cmd("colorscheme earlysummer")
-- result = result - vim.loop.now()
-- print(result)
return M

-- vim.cmd("hi Normal guifg=" .. colors.foreground .. " guibg=" .. colors.black)
-- hl("NormalFloat", { fg = colors.foreground, bg = colors.black })
-- hl("FloatBorder", { fg = colors.lightbg })
-- hl("Bold", { bold = true })
-- hl("Debug", { fg = colors.pink })
-- hl("Directory", { fg = colors.blue })
-- hl("Error", { fg = colors.black, bg = colors.pink })
-- hl("ErrorMsg", { fg = colors.pink, bg = colors.black })
-- hl("Exception", { fg = colors.pink })
-- hl("FoldColumn", { fg = colors.teal, bg = colors.lightbg })
-- hl("Folded", { fg = colors.one_bg3, bg = colors.lightbg })
-- hl("IncSearch", { fg = colors.blue })
-- hl("Macro", { fg = colors.pink })
-- hl("MatchParen", { bg = colors.lightbg })
-- hl("ModeMsg", { fg = colors.green })
-- hl("MoreMsg", { fg = colors.green })
-- hl("Question", { fg = colors.blue })
-- hl("Search", { fg = colors.blue })
-- hl("Substitute", { fg = colors.lightbg, bg = colors.yellow })
-- hl("SpecialKey", { fg = colors.one_bg3 })
-- hl("TooLong", { fg = colors.pink })
-- hl("Underlined", { fg = colors.pink })
-- hl("Visual", { bg = colors.one_bg2 })
-- hl("VisualNOS", { fg = colors.pink })
-- hl("WarningMsg", { fg = colors.pink })
-- hl("WildMenu", { fg = colors.pink, bg = colors.yellow })
-- hl("Title", { fg = colors.blue })
-- hl("Conceal", { fg = colors.blue, bg = colors.black })
-- hl("Cursor", { fg = colors.black, bg = colors.white })
-- hl("NonText", { fg = colors.one_bg3 })
-- hl("LineNr", { fg = colors.grey })
-- hl("SignColumn", { fg = colors.one_bg3 })
-- hl("StatusLineNC", { fg = colors.one_bg3, underline = true })
-- hl("StatusLine", { fg = colors.one_bg2, underline = true })
-- hl("VertSplit", { fg = colors.one_bg2 })
-- hl("ColorColumn", { bg = colors.lightbg })
-- hl("CursorColumn", { bg = colors.lightbg })
-- hl("CursorLine", { bg = colors.lightbg })
-- hl("CursorLinenr", { fg = colors.white, bg = colors.black })
-- hl("QuickFixLine", { bg = colors.lightbg })
-- hl("Pmenu", { fg = colors.one_bg })
-- hl("PmenuSbar", { fg = colors.one_bg2 })
-- hl("PmenuSel", { fg = colors.green })
-- hl("PmenuThumb", { fg = colors.blue })
-- hl("TabLine", { fg = colors.one_bg3, bg = colors.lightbg })
-- hl("TabLineFill", { fg = colors.one_bg3, bg = colors.lightbg })
-- hl("TabLineSel", { fg = colors.green, bg = colors.lightbg })
--
-- -- Standard syntax highlighting
-- hl("Boolean", { fg = colors.orange })
-- hl("Character", { fg = colors.pink })
-- hl("Comment", { fg = colors.grey_fg, italic = true })
-- hl("Conditional", { fg = colors.green })
-- hl("Constant", { fg = colors.cyan })
-- hl("Define", { fg = colors.dark_purple })
-- hl("Delimiter", { fg = colors.dark_purple })
-- hl("Float", { fg = colors.orange })
-- hl("Function", { fg = colors.yellow })
-- hl("Identifier", { fg = colors.teal })
-- hl("Include", { fg = colors.blue })
-- hl("Keyword", { fg = colors.green })
-- hl("Label", { fg = colors.yellow })
-- hl("Number", { fg = colors.orange })
-- hl("Operator", { fg = colors.white })
-- hl("PreProc", { fg = colors.yellow })
-- hl("Repeat", { fg = colors.cyan })
-- hl("Special", { fg = colors.orange })
-- hl("SpecialChar", { fg = colors.dark_purple })
-- hl("Statement", { fg = colors.green })
-- hl("StorageClass", { fg = colors.yellow })
-- hl("String", { fg = colors.pink })
-- hl("Structure", { fg = colors.dark_purple })
-- hl("Tag", { fg = colors.yellow })
-- hl("Todo", { fg = colors.yellow, bg = colors.lightbg })
-- hl("Type", { fg = colors.yellow })
-- hl("Typedef", { fg = colors.yellow })
--
-- -- Diff highlighting
-- hl("DiffAdd", { fg = colors.green, bg = colors.lightbg })
-- hl("DiffChange", { fg = colors.one_bg3, bg = colors.lightbg })
-- hl("DiffDelete", { fg = colors.pink, bg = colors.lightbg })
-- hl("DiffText", { fg = colors.blue, bg = colors.lightbg })
-- hl("DiffAdded", { fg = colors.green, bg = colors.black })
-- hl("DiffFile", { fg = colors.pink, bg = colors.black })
-- hl("DiffNewFile", { fg = colors.green, bg = colors.black })
-- hl("DiffLine", { fg = colors.blue, bg = colors.black })
-- hl("DiffRemoved", { fg = colors.pink, bg = colors.black })
--
-- hl("TelescopeBorder", { fg = colors.one_bg })
-- hl("TelescopePreviewTitle", { fg = colors.green })
-- hl("TelescopePromptTitle", { fg = colors.blue })
-- hl("TelescopeResultsTitle", { fg = colors.red })
-- hl("TelescopePreviewBorder", { fg = colors.grey })
-- hl("TelescopePromptBorder", { fg = colors.line })
-- hl("TelescopeResultsBorder", { fg = colors.line })
