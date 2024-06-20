local function daylight()
  local h = tonumber(os.date('%H'))
  if h > 8 and h < 17 then
    return 'light'
  else
    return 'dark'
  end
end

local loading_theme

local function randomscheme()
  math.randomseed(os.time())
  local themes = {
    'starry.nvim',
    'aurora',
    'starry.nvim',
    'aurora',
    'catppuccin',
    'galaxy',
  }
  local style = daylight()

  if style == 'light' then
    -- vim.o.background = "light"
    themes = { 'starry.nvim', 'catppuccin' }
  end

  -- themes = { "starry.nvim", "starry.nvim", "aurora", "galaxy", "catppuccin", "tokyonight.nvim" }
  -- themes = { 'starry.nvim', 'aurora', 'galaxy' }
  themes = { 'starry.nvim' }
  -- themes = { 'aurora' }
  -- themes = { 'galaxy' }
  -- themes = { 'catppuccin' }
  local v = math.random(1, #themes)

  loading_theme = themes[v]
  return loading_theme
end

local function load_colorscheme(theme)
  if not theme then
    theme = randomscheme()
  end
  lprint('loading theme: ' .. theme)
  if theme == 'galaxy' then
    require('modules.ui.galaxy').shine()
  else
    require('lazy').load({ plugins = { theme } })
    vim.api.nvim_set_hl(0, 'ColorColumn', {})
  end
  -- vim.api.nvim_set_hl(0, '@lsp.type.string.go', { fg = 'NONE' })
end

return {
  randomscheme = randomscheme,
  load_colorscheme = load_colorscheme,
  current_theme = loading_theme,
}
