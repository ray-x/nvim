local function daylight()
  local h = tonumber(os.date("%H"))
  if h > 8 and h < 17 then
    return "light"
  else
    return "dark"
  end
end

local loading_theme

local function randomscheme()
  math.randomseed(os.time())
  local themes = {
    "starry.nvim",
    "aurora",
    "tokyonight.nvim",
    "starry.nvim",
    "aurora",
    "gruvbox-material",
    "sonokai",
    "catppuccin",
    "github-nvim-theme",
    "vim-nightfly-colors",
    "galaxy",
  }
  local style = daylight()

  if style == "light" then
    -- vim.o.background = "light"
    themes = { "starry.nvim", "catppuccin", "gruvbox-material", "sonokai" }
  end

  -- themes = { 'vim-nightfly-colors', "starry.nvim", "starry.nvim", "aurora", "galaxy" }
  local v = math.random(1, #themes)

  loading_theme = themes[v]
  return loading_theme
end

local function load_colorscheme(theme)
  if not theme then
    theme = randomscheme()
  end
  lprint("loading theme: " .. theme)
  if theme == "galaxy" then
    require("modules.ui.galaxy").shine()
  else
    require("packer").loader(theme)
  end
end

return {
  randomscheme = randomscheme,
  load_colorscheme = load_colorscheme,
  current_theme = loading_theme,
}
