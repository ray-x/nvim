# vim as a programming IDE

## 🏎 🏎 🏎 Need for speed! 🏎 🏎 🏎

This neovim configure file is highly optimized for the impatient. Super lazy loading + After syntax highlight rendering. Render multiple files with treesitter in less than 45ms with ~170 plugins installed
(e.g. Open both util.lua(1686 loc) and lsp.lua(1538 loc) from neovim source code in 58.6ms)
The setup set all plugins to be lazy loaded and trigger when it needed.

The `Packer` config locates in branch [Packer branch](https://github.com/ray-x/nvim/tree/packer)
It serves as my personal nvim setup. I am using it as my daily driver. The structure can be messy so it is not a setup for beginner

- nvim Telescope preview:
  ![telescope](https://user-images.githubusercontent.com/1681295/214219526-dfb3cd22-7b67-475b-9294-914590d2913b.jpg)

- nvim+kitty + cmp :

  ![vim_ide with
nvim+kitty](https://user-images.githubusercontent.com/1681295/109258178-db2e6d80-784d-11eb-9cef-8b1cc6435e01.png?raw=true)

## Battery included

About 150 plugins and 14000 lines of lua and vim code.

### Commands

- Keymaps : floating windows show all keymaps defined in this repo
- Jsonfmt: format json file
- LG: lazygit
- FZF: fzf
- Spell: spell check
- Gram: Grammar check
- Kwdb: better `bdelete`
- Gd: gitdiff(with fzf and delta)
- Rg: ripgrep with telescope

## Neovim Plugins

There are lots of amazing plugins,
I used following plugin a lots

- `Plug` -> `Dein` -> `Lua-Packer` -> [lazy.nvim](https://github.com/folke/lazy.nvim)

  I followed Glepnir https://github.com/glepnir/nvim dotfiles when I start this repo. 
  A.T.M. nvim-cmp as a completion engine with LSP, LSP saga. vim-multi-cursor, telescope. treesitter,
  lazy load vim-go. So, other than module folder, I could copy/paste everything else from glepnir's configure file,
  which make my life easier.

- Telescope + fzf

  One of the best plugin for search anything. I used it to replace fzf, leaderF, leaderP, defx, Ag/Ack/Rg, yank(ring), project management. undolist and many more. Telescope is awesome, only issue is performance.

- nvim-lsp with [navigator.lua](https://github.com/ray-x/navigator.lua)

  vim-go and coc add around 200ms time and some of the extensions
  might crash when I using (but it hard to check which because ~4 node.js services coc forked)
  Some useful script from TJ, and [glepnir](https://github.com/glepnir)

  nvim-tree: file-explorer (lightweight and fast)
  hrsh7th/nvim-cmp: auto-complete
  vsnip + luasnips: code snipts(Load snippet from VSCode extension). It is a full featured IDE.

  ![document symbol](https://github.com/ray-x/files/blob/master/img/navigator/doc_symbol.gif?raw=true)

- ALE -> Efm -> null-ls

Lint and format moved to null-ls.

- Programming support:
  Treesitter, nvim-lsp and [navigator.lua](https://github.com/ray-x/navigator.lua), for go, [go.nvim](https://github.com/ray-x/go.nvim)

- Debug:

  dlv, nvim-dap

- Theme, look&feel:

  home cooked Aurora, windline (lua), devicons(lua), blankline(indent), bufferline

- Color:

  Primary with treesitter from nvim nightly (nvim-lsp and this make it hard for me to turn back to vim), log-highlight, limelight, interestingwords,
  hexokinase as a replacement for colorizer (display hex and color in highlight)

- Git:

  fugitive, nvimtree, gitsigns.nvim, diffview.nvim

- Format:

  tabular, lsp based code formating (or, sometimes prettier), auto-pair

- Menu and tab:

  - guihua.lua the UI I created for personal use
  - nvim-bufferline.lua: Yes, with lua and neovim only

- Tools: Toggleterm, scrollview

- Move and Edit:

  easymotion -> hop&lightspeed, vim-multi-cursor, navigator.lua (better treesitter folding), Sad for complex find and replace

## Install

Note: I tested it on Mac and linux, not sure about window

Clone the repo

Link nvim to $HOME/.config/

e.g.

```
ls ~/.config/nvim

~/.config/nvim -> /Users/rayx/github/dotfiles/nvim

```

On windows the config path is
`C:\Users\your_user_name\AppData\Local\nvim`
You need to link or replace above folder

Please install Nerd Fonts(I am using VictorMono) and kitty so font setting in GUI will work as expected

Startup nvim

If you saw error message "Error in packer_compiled: ..." Please press `Enter`, that will allow packer install the plugins.
After all plugins install restart the nvim.

Note:
The packages and data will be install to
`~/.local/share/nvim`

Please backup this folder if necessary

The setup needs nvim0.8+. For earlier release, please check packer branch. A patched nerd font is needed. Also if you start nvim from terminal,
make sure it support nerdfont and emoji

### missing sqlite, libsqlite3

Some of the plugin I am using depends on sqlite.
By default sqlite was installed on MacOS. For other operating system, if you saw error message about sqlite, please
following the instruction [here to install sqlite](https://github.com/kkharji/sqlite.lua#windows)

### Youtube video recording of install process

[Install process](https://youtu.be/5XB28yocmuw)

## Configure

If you would like to sync to my branch. You can add you own setup in lua/overwrite folder

You can put your own plugins setup in `modules/user` folder

## Shell

- fish + spaceship + kitty. It is cooool and faster.
  nvim+kitty split view:

  ![vim_ide with nvim+kitty](https://github.com/ray-x/dotfiles/blob/master/img/kitty.jpg)

## External tools

You may need to install following tools to make best of the setup

- git
- build tools (e.g. gcc, make etc)
- fzf
- bat
- delta
- lazgit
- ranger
- write-good
- proselint
- ispell
- zodide
- node.js
- develop language: python(and pynvim), go, rust etc
- package management: pip, cater, npm etc
- exa
- ...

## Parking lots

These tools are good, but due to confliction, less use, or, not suite to my workflow

- vim/gvim
- YCM you complete me
- easymotion
- vim-clap
- oh-my-zh, iterm2
- zpreztor
- defx
- ALE
