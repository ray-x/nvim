M = {}
-- local ns = vim.api.nvim_create_namespace("color_galaxy")
local ns = 0
local function hl(name, val)
  vim.api.nvim_set_hl(ns, name, val)
end
-- TODO:
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/master/doc/nvim-treesitter.txt#L450

local c = {
  black = '#101015',
  black_two = '#282828',
  white = '#EFEFFF',
  white_two = '#CECECE',
  white_three = '#DECEAE',

  gray_one = '#B5B5B5',
  gray_two = '#556075',
  gray_six = '#658575',

  green = '#4CEF7B',
  green_one = '#BCFF7B',
  green_two = '#66FF61',
  green_three = '#A0BF26',
  green_four = '#8ABB26',
  green_five = '#59DE73',
  green_six = '#3AF8B7',
  green_seven = '#105017',

  blue = '#4572E5',
  blue_one = '#5582E5',
  blue_two = '#519ABA',
  blue_three = '#73EACC',
  blue_four = '#5BD0DE',
  blue_five = '#316AD0',
  blue_six = '#3FC0D0',
  blue_seven = '#4B93D1',

  purple_one = '#95179C',
  purple_two = '#D9ACF4',
  purple_three = '#A98CD4',
  purple_four = '#755799',

  yellow = '#ECE683',
  yellow_one = '#ECF683',
  yellow_two = '#FCF6A3',
  yellow_three = '#CCD663',

  red = '#FF3263',
  red_one = '#FF7263',
  red_two = '#FF91A4',
  red_three = '#D82B26',
  red_four = '#FB4934',
  dark_red = '#400024',

  pink = '#D57780',
  pink_one = '#AF95A3',
  pink_two = '#FFB5F3',

  orange = '#FE8019',
  orange_one = '#FE6019',
  orange_two = '#FE9059',

  background = '#121825',
  background_one = '#1d2e38',
  background_two = '#2e2f3f',
  background_g = '#1e321f',
  background_b = '#1e123f',
  background_three = '#323e43',
  background_four = '#445462',

  lime = '#98EE64',
  cyan = '#89DDFF',
}

local back = nil

local Usual = {
  UsualHighlights = {
    Normal = { fg = c.white, bg = c.black },
    NormalFloat = { fg = c.white_two },
    Type = { fg = c.blue_three }, -- int, long, char, etc.
    StorageClass = { fg = c.blue_five }, -- static, register, volatile, etc.
    Identifier = { fg = c.white_three, bold = true },
    Keyword = { fg = c.purple_two, bold = true },
    FloatBorder = { fg = c.blue_four },
    Constant = { fg = c.orange_two }, -- any constant
    String = { fg = c.green }, -- Any string
    Character = { fg = c.orange_one }, -- any character constant: 'c', '\n'
    Number = { fg = c.yello }, -- a number constant: 5
    Boolean = { fg = c.orange_two, italic = true, bold = true }, -- a boolean constant: TRUE, false
    Float = { fg = c.red_four }, -- a floating point constant: 2.3e10
    Statement = { fg = c.blue_seven }, -- any statement
    Label = { fg = c.label }, -- case, default, etc.
    Operator = { fg = c.red_four }, -- sizeof", "+", "*", etc.
    Exception = { fg = c.purple_two }, -- try, catch, throw
    PreProc = { fg = c.purple_four }, -- generic Preprocessor
    Include = { fg = c.blue_three }, -- preprocessor #include
    Define = { fg = c.pink_two }, -- preprocessor #define
    Macro = { fg = c.cyan }, -- same as Define
    Typedef = { fg = c.orange_one }, -- A typedef
    PreCondit = { fg = c.blue_seven }, -- preprocessor #if, #else, #endif, etc.
    Conditional = { fg = c.blue_seven, bold = true }, -- preprocessor #if, #else, #endif, etc.
    Repeat = { fg = c.blue_three, bold = true }, -- preprocessor #if, #else, #endif, etc.
    Special = { fg = c.red }, -- any special symbol
    SpecialChar = { link = 'Define' }, -- special character in a constant
    Tag = { fg = c.lime, underline = true }, -- you can use CTRL-] on this
    Delimiter = { fg = c.blue_three }, -- character that needs attention like , or .
    SpecialComment = { fg = c.gray_one }, -- special things inside a comment
    Debug = { link = 'Special' }, -- debugging statements
    Ignore = { fg = c.gray_one }, -- left blank, hidden
    Error = { link = 'DiagnosticError', undercurl = true, sp = c.pink }, -- any erroneous construct
    Todo = { fg = c.yellow, bg = c.bg_alt, bold = true, italic = true },
    netrwDir = { fg = c.green_six },
    netrwList = { fg = c.green_four },
    NonText = { fg = c.gray_two },
    LineNr = { fg = c.gray_two },
    SignColumn = { bg = 'None' },
    CursorLine = { bg = c.background_one, bold = true },
    CursorColumn = { bg = c.purple_four },
    CursorLineNr = { fg = c.yellow_one, bold = true, underline = true },
    StatusLine = { fg = c.white_two, bg = c.background_three },
    StatusLineNC = { fg = c.white_two, bg = c.background_four },
    Structure = { fg = c.purple_three },
    ModeMsg = { fg = c.green },
    Question = { fg = c.blue },
    Function = { fg = c.blue_one, bold = true },
    WarningMsg = { fg = c.pink_one },
    Warnings = { fg = c.yellow_two },
    WildMenu = { fg = c.white_two, bg = c.background_three },
    Title = { fg = c.white_two, bold = true },
    Cursor = { bg = c.orange_one },
    SpecialKey = { fg = c.green_five },
    SpellBad = { fg = c.orange, bold = true, undercurl = true },
    SpellCap = { fg = c.yellow, underdotted = true },
    SpellRare = { fg = c.white, underdotted = true },
    Search = { fg = c.yellow, reverse = true, bold = true },
    IncSearch = { fg = c.green_five, reverse = true, bold = true },
    -- Search = { fg = c.black_two, bg = c.yellow_one, bold = true },
    -- IncSearch = { fg = c.black_two, bg = c.orange_one, bold = true },
    Folded = { fg = c.blue_seven, bold = true, italic = true },
    FoldColumn = { fg = c.blue_seven },
    Visual = { bg = c.background_three, bold = true },
    VisualNOS = { bg = c.background_two },
    EndOfBuffer = { bg = back },
    Comment = { fg = c.gray_two, italic = true },
    preProc = { fg = c.blue_four },
    MatchParen = { underline = true, bold = true, bg = c.background_three },
    Pmenu = { fg = c.white_two, bg = c.background_two },
    PmenuKind = { fg = c.green_five, bg = c.background_two },
    PmenuExtra = { fg = c.blue_three, bg = c.background_two },
    Pmenusel = { fg = c.white, bg = c.background_four, bold = true },
    PmenuThumb = { fg = c.blue, bg = 'Grey', bold = true, italic = true },
    VertSplit = { fg = c.background_four },
    Underlined = { fg = c.blue, underline = true, sp = c.blue }, -- text that stands out, HTML links
    ErrorMsg = { fg = c.pink_one, bold = true },

    ColorColumn = { link = 'WinSeparator' },

    Conceal = { link = 'Keyword' },
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

  Telescope = {
    TelescopeNormal = { link = 'NormalFloat' },
    TelescopePromptBorder = { link = 'Macro' },
    TelescopeSelectionCaret = { link = 'PreProc' },
    TelescopeBorder = { fg = c.pink },
    TelescopePreviewTitle = { fg = c.green },
    TelescopeSelection = { fg = c.purple, bg = c.gray_two },
    TelescopeMatching = { link = 'Macro' },
    TelescopePromptTitle = { fg = c.blue },
    TelescopeResultsTitle = { fg = c.red },
    TelescopePreviewBorder = { fg = c.blue_one },
    TelescopeResultsBorder = { fg = c.line },
  },
  Diff = {
    DiffAdd = {
      fg = c.green_two,
      bg = c.background_b,
      bold = true,
      sp = '#2284a1',
    },
    DiffChange = {
      bg = c.background_two,
      -- fg = c.yellow,
      bold = true,
    },
    DiffText = {
      reverse = true,
      bg = c.green_seven,
    },
    DiffDelete = {
      fg = c.background_four,
      bold = true,
      strikethrough = true,
      sp = c.white,
    },
  },
  Git = {
    -- GitSignsAdd = { fg = c.red }, -- diff mode: Added line |diff.txt|
    -- GitSignsChange = { fg = c.purple_two }, -- diff mode: Changed line |diff.txt|
    -- GitSignsDelete = { fg = c.red_two }, -- diff

    GitSignsAdd = { link = 'Question' }, -- diff mode: Added line |diff.txt|
    GitSignsAddNr = { link = 'Question' }, -- diff mode: Added line |diff.txt|
    GitSignsAddLn = { link = 'Question' }, -- diff mode: Added line |diff.txt|
    GitSignsChange = { link = 'Include' }, -- diff mode: Changed line |diff.txt|
    GitSignsChangeNr = { link = 'Include' }, -- diff mode: Changed line |diff.txt|
    GitSignsChangeLn = { link = 'Include' }, -- diff mode: Changed line |diff.txt|
    GitSignsDelete = { link = 'Special' }, -- diff mode: Deleted line |diff.txt|
    GitSignsDeleteNr = { link = 'Special' }, -- diff mode: Deleted line |diff.txt|
    GitSignsDeleteLn = { link = 'Special' }, -- diff mode: Deleted line |diff.txt|
    GitGutterDelete = { link = 'GitSignsDelete' },
    GitGutterChangeDelete = { link = 'GitSignsChange' },
    GitGutterAdd = { link = 'GitSignsAdd' },
    GitGutterChange = { link = 'GitSignsChange' },

    GitSignsAddInline = { underdotted = true, sp = c.green }, -- diff mode: Deleted line |diff.txt|
    GitSignsDeleteInline = { link = 'DiffDelete' }, -- diff mode: Deleted line |diff.txt|
    GitSignsChangeInline = { underdotted = true, sp = c.blue_two }, -- diff mode: Deleted line |diff.txt|
  },
  TSHighlights = {
    NodeNumber = { fg = c.blue_five },
    NodeOp = { fg = c.red_four },
    TSVariable = { link = 'Identifier' },
    TSComment = { link = 'Comment' },
    TSInclude = { fg = c.blue_four, italic = true, bold = true },
    TSKeywordOperator = { fg = c.purple_two },
    TSConditional = { fg = c.purple_two },
    TSNumber = { fg = c.pink },
    TSFloat = { fg = c.orange_two },
    TSOperator = { fg = c.green_six },
    TSKeyword = { fg = c.purple_two, italic = true },
    TSString = { fg = c.green_five },
    TSConstant = { fg = c.blue_three },
    TSProperty = { fg = c.blue_seven },
    TSField = { fg = c.pink },
    TSBoolean = { fg = c.purple_one, bold = true, italic = true },
    TSRepeat = { fg = c.red_two },
    TSKeywordFunction = { fg = c.red_two },
    TSFunction = { link = 'Function' },
    TSMethod = { fg = c.green_two, bold = true },
    TSType = { fg = c.red_two },
    TSTypeBuiltin = { fg = c.purple_two, italic = true },
    TSDefinition = { link = 'Keyword' },
    TSDefinitionUsage = { link = 'IncSearch' },
    TSException = { fg = c.blue_four },
    TSEnvironmentName = { fg = c.blue_four },
    TSTitle = { fg = c.green_one, bold = true },
    TSEnvironment = { fg = c.red_two },
  },
  Hop = {
    LeapBackdrop = { link = 'Comment' },
    FlashBackdrop = { link = 'SpecialComment' },
    FlashLabel = { link = 'DiffAdd' },
  },
  LspRelated = {
    DiagnosticError = { fg = c.red_one, bold = true }, -- used to underline "Error" diagnostics.
    DiagnosticWarn = { fg = c.orange_one, bold = true }, -- used to underline "Error" diagnostics.
    DiagnosticInfo = { fg = c.green_seven }, -- used to underline "Error" diagnostics.
    DiagnosticHint = { fg = c.gray_two }, -- used to underline "Error" diagnostics.
    DiagnosticUnderlineError = { bold = true, undercurl = true, sp = c.red }, -- used to underline "Error" diagnostics.
    DiagnosticUnderlineWarn = { bold = true, underline = true, sp = c.orange_one }, -- used to underline "Error" diagnostics.
    DiagnosticUnderlineInfo = { bold = true, underdashed = true, sp = c.blue_five }, -- used to underline "Error" diagnostics.
    DiagnosticUnderlineHint = { bold = true, underdotted = true, sp = c.gray_two }, -- used to underline "Error" diagnostics.
    LspReferenceText = { bold = true, italic = true, undercurl = true, sp = 'yellow' }, -- used for highlighting "text" references
    LspReferenceRead = {
      fg = c.green_four,
      bold = true,
      italic = true,
      underdashed = true,
      sp = 'lime',
    }, -- used for highlighting "read" references
    LspReferenceWrite = {
      fg = c.yellow_two,
      bg = c.background_one,
      bold = true,
      italic = true,
      underdouble = true,
      sp = c.red_four,
    }, -- used for highlighting "write" references
    LspSignatureActiveParameter = {
      fg = c.white_two,
      bg = c.background_four,
      bold = true,
      italic = true,
      underdouble = true,
      sp = 'violet',
    },
  },
  Cmp = {
    CmpItemAbbrMatch = { link = 'IncSearch' },
    CmpItemAbbrMatchFuzzy = { link = 'IncSearch' },
  },
  UI = {
    NeoTreeFloatTitle = { link = 'Title' },
    NeoTreeTitleBar = { link = 'TelescopePreviewTitle' },
  },
  Packer = { packerStatusSuccess = { fg = c.blue_three }, packerString = { fg = c.blue_three } },
}

local lang = {
  lua = { RequireCall = { fg = c.purple_two, italic = true, bold = true } },
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

function M.ts_map()
  -- Misc {{{
  hl('@comment', { link = 'Comment' })
  hl('@error', { link = 'Error' })
  hl('@none', { bg = 'NONE', fg = 'NONE' })
  hl('@preproc', { link = 'PreProc' })
  hl('@define', { link = 'Define' })
  hl('@operator', { link = 'Operator' })
  -- }}}

  -- Punctuation {{{
  hl('@punctuation.delimiter', { link = 'Delimiter' })
  hl('@punctuation.bracket', { link = 'Delimiter' })
  hl('@punctuation.special', { link = 'Delimiter' })
  -- }}}

  -- Literals {{{
  hl('@string', { link = 'String' })
  hl('@string.regex', { link = 'String' })
  hl('@string.escape', { link = 'SpecialChar' })
  hl('@string.special', { link = 'SpecialChar' })

  hl('@character', { link = 'Character' })
  hl('@character.special', { link = 'SpecialChar' })

  hl('@boolean', { link = 'Boolean' })
  hl('@number', { link = 'Number' })
  hl('@float', { link = 'Float' })
  -- }}}

  -- Functions {{{
  hl('@function', { link = 'Function' })
  hl('@function.call', { link = 'Function' })
  hl('@function.builtin', { link = 'Special' })
  hl('@function.macro', { link = 'Macro' })

  hl('@method', { link = 'Function' })
  hl('@method.call', { link = 'Function' })

  hl('@constructor', { link = 'Special' })
  hl('@parameter', { link = 'Marco' })
  -- }}}

  -- Keywords {{{
  hl('@keyword', { link = 'Keyword' })
  hl('@keyword.function', { link = 'Function' })
  hl('@keyword.operator', { link = 'Keyword' })
  hl('@keyword.return', { link = 'Keyword' })

  hl('@conditional', { link = 'Conditional' })
  hl('@repeat', { link = 'Repeat' })
  hl('@debug', { link = 'Debug' })
  hl('@label', { link = 'Label' })
  hl('@include', { link = 'Include' })
  hl('@exception', { link = 'Exception' })
  -- }}}

  -- Types {{{
  hl('@type', { link = 'Type' })
  hl('@type.builtin', { link = 'Type' })
  hl('@type.qualifier', { link = 'Type' })
  hl('@type.definition', { link = 'Typedef' })

  hl('@storageclass', { link = 'StorageClass' })
  hl('@attribute', { link = 'PreProc' })
  hl('@field', { link = 'Identifier' })
  hl('@property', { link = 'Identifier' })
  -- }}}

  -- Identifiers {{{
  hl('@variable', { link = 'Normal' })
  hl('@variable.builtin', { link = 'Special' })

  hl('@constant', { link = 'Constant' })
  hl('@constant.builtin', { link = 'Special' })
  hl('@constant.macro', { link = 'Define' })

  hl('@namespace', { link = 'Include' })
  hl('@symbol', { link = 'Identifier' })
  -- }}}

  -- Text {{{
  hl('@text', { link = 'Normal' })
  hl('@text.strong', { bold = true })
  hl('@text.emphasis', { italic = true })
  hl('@text.underline', { underline = true })
  hl('@text.strike', { strikethrough = true })
  hl('@text.title', { link = 'Title' })
  hl('@text.literal', { link = 'String' })
  hl('@text.literal.markdown', { link = 'Normal' })
  hl('@text.literal.markdown_inline', { link = 'Special' })
  hl('@text.uri', { link = 'Underlined' })
  hl('@text.math', { link = 'Special' })
  hl('@text.environment', { link = 'Macro' })
  hl('@text.environment.name', { link = 'Type' })
  hl('@text.reference', { link = 'Constant' })

  hl('@text.todo', { link = 'Todo' })
  hl('@text.todo.unchecked', { link = 'Todo' })
  hl('@text.todo.checked', { link = 'Comment' })
  hl('@text.note', { link = 'SpecialComment' })
  hl('@text.warning', { link = 'WarningMsg' })
  hl('@text.danger', { link = 'ErrorMsg' })
  -- }}}

  -- Tags {{{
  hl('@tag', { link = 'Tag' })
  hl('@tag.attribute', { link = 'Identifier' })
  hl('@tag.delimiter', { link = 'Delimiter' })
  -- }}}
end

function M.lsp_map()
  local hl = function(group, opts)
    opts.default = true
    vim.api.nvim_set_hl(0, group, opts)
  end
  hl('@lsp.type.enum', { link = '@type' })
  hl('@lsp.type.keyword', { link = '@keyword' })
  hl('@lsp.type.interface', { link = 'Identifier' })
  hl('@lsp.type.namespace', { link = '@namespace' })
  hl('@lsp.type.parameter', { link = '@parameter' })
  hl('@lsp.type.property', { link = '@property' })
  hl('@lsp.type.variable', { link = '@variable' })
  hl('@lsp.typemod.function.defaultLibrary', { link = 'Special' })
end

function M.shine(reset)
  if reset then
    vim.cmd('highlight clear')
  end
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end
  vim.g.colors_name = 'galaxy'

  for _, tbl in pairs(Usual) do
    add_highlight_table(tbl)
  end

  -- local bg = back or "none"
  vim.api.nvim_set_hl_ns(ns)

  vim.defer_fn(function()
    require('utils.kitty').change_bg(c.background)
  end, 1)
end

_G.colors = {
  red = '#BF616A',
  teal = '#97B7D7',
  one_bg = '#373D49',
  lightbg = '#3B4252',
  blue = '#81A1C1',
  cyan = '#5E81AC',
  black = '#2E3440',
  orange = '#D08770',
  one_bg2 = '#434C5E',
  foreground = '#E5E9F0',
  grey = '#4B515D',
  green = '#A3BE8C',
  purple = '#8FBCBB',
  one_bg3 = '#4C566A',
  light_grey = '#646A76',
  line = '#3A404C',
  white = '#D8DEE9',
  yellow = '#EBCB8B',
  lightbg2 = '#393F4B',
  dark_purple = '#B48EAD',
  pink = '#D57780',
  black2 = '#343A46',
  grey_fg = '#606672',
  baby_pink = '#DE878F',
  darker_black = '#2A303C',
}

return M
