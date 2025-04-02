local loading_theme
if vim.o.diff then
  loading_theme = 'default'
  return
end

local function daylight()
  local h = tonumber(os.date('%H'))
  if h > 8 and h < 17 then
    return 'light'
  else
    return 'dark'
  end
end


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
  elseif theme == 'default' then
    vim.cmd.colorscheme('default')
  else
    require('lazy').load({ plugins = { theme } })
    vim.api.nvim_set_hl(0, 'ColorColumn', {})
  end

  vim.api.nvim_set_hl(0, '@lsp.type.variable.go', {}) -- use treesitter
  -- vim.api.nvim_set_hl(0, '@lsp.type.string.go', { fg = 'NONE' })

  -- override default colorscheme
  -- incase you want transparent background but the colorscheme does not allow you to do so
  -- vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'None' })
  -- vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'None' })
  -- vim.api.nvim_set_hl(0, 'Normal', { bg = 'None' })
  -- vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'None' })
  -- vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'None' })
  -- vim.api.nvim_set_hl(0, 'FoldColumn', { bg = 'None' })
  ---
end

return {
  randomscheme = randomscheme,
  load_colorscheme = load_colorscheme,
  current_theme = loading_theme,
}
