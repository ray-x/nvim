# vim as a programming IDE

## 🏎 🏎 🏎 Need for speed! 🏎 🏎 🏎

This neovim configure file is highly optimized for the impatient. Packer lazy loading + After syntax highlight rendering. Maybe the
only nvim setup in github that can render multiple files with treesitter in less than 80ms with ~110 plugins installed
(e.g. Open both util.lua(1686 loc) and lsp.lua(1538 loc) from neovim source code in 80.6ms)

The `Plug` config is located in branch [Plug branch](https://github.com/ray-x/dotfiles/tree/zprezto-plug)

- nvim+kitty configured with pop menu:

  ![vim_ide with nvim+kitty](https://github.com/ray-x/dotfiles/blob/master/img/menu.jpg?raw=true)

- nvim clap preview:

  ![vim_ide with nvim+kitty](https://github.com/ray-x/dotfiles/blob/master/img/clap.jpg?raw=true)

- nvim+kitty + compe (cmp) :

  ![vim_ide with
nvim+kitty](https://user-images.githubusercontent.com/1681295/109258178-db2e6d80-784d-11eb-9cef-8b1cc6435e01.png?raw=true)

## Battery included

About 120 plugins and 1600 lines of lua and vim code.

### Commands

- Keymaps : floating windows show all keymaps defined in this repo
- Jsonformat: format json file
- LG: lazygit
- FZF: fzf
- Spell: spell check
- Gram: Grammar check
- Kwdb: better `db`
- Rg: ripgrep with telescope

## Neovim Plugins

There are lots of amazing plugins,
I used following plugin a lots

- `Plug` -> `Dein` -> `Lua-Packer`
  Change to Lua-Packer does not
  decrease startup time as Plug -> Dein. But still about 80ms faster for Golang codes loading.
  If you interested in Dein version, Please refer to [Dein](https://github.com/ray-x/dotfiles/tree/nvim-comple).
  This was the last Dein/Packer dual supports version I have (init.vim has a flag to choose).
  ATM, minium support for vim. Most plugins only works under neovim 0.5.1+.

  I followed Raphael(a.k.a glepnir) https://github.com/glepnir/nvim dotfiles. He provides a good wrapper for
  Packer. I have an `overwrite` folder which will override the settings. Also, lots of changes in modules/plugins.
  setup
  A.T.M. nvim-compe/cmp as a completion engine with LSP, LSP saga. vim-multi-cursor, clap/telescope. treesitter,
  lazy load vim-go. So, other than module folder, I could copy/paste everything else from glepnir's configure file,
  which make my life easier.

- Telescope + Vim-Clap

  One of the best plugin for search anything. I used it to replace fzf, leaderF, leaderP, defx, Ag/Ack/Rg, yank(ring), project management. undolist and many more. Telescope is awesome, only issue is performance.

- nvim-lsp with [navigator.lua](https://github.com/ray-x/navigator.lua)

  I turn off vim-go auto-complete/LSP and turn to nvim-lsp. It adds around 200ms time and some of the extensions
  might crash when I using (but it hard to check which because ~4 node.js services coc forked)
  Some useful script from TJ, and [glepnir](https://github.com/glepnir)

  nvim-tree: file-explorer (lightweight and fast)
  hrsh7th/nvim-cmp: auto-complete
  vsnip: code snipts(Load snippet from VSCode extension). It is a full featured IDE.

  ![document symbol](https://github.com/ray-x/files/blob/master/img/navigator/doc_symbol.gif?raw=true)

- ALE -> Efm

Lint and format moved to efm-server

- Programming support:
  Treesitter, nvim-lsp and [navigator.lua](https://github.com/ray-x/navigator.lua), for golang, use [go.nvim](https://github.com/ray-x/go.nvim)

- Debug:

  dlv, nvim-dap

- Theme, look&feel:

  home cooked Aurora, windline (lua), devicons(lua), blankline(indent), bufferline

- Color:

  Primary with treesitter from nvim nightly (nvim-lsp and this make it hard for me to turn back to vim), log-highlight, limelight, interestingwords,
  hexokinase as a replacement for colorizer (display hex and color in highlight)

- Git:

  fugitive, nvimtree, gitsigns.nvim, VGit.nvim

- Format:

  tabular, lsp based code formating (or, sometimes prettier), auto-pair

- Menu and tab:

  - quickui(created a menu for the function/keybind I used less often. I can not remember all the commands and keybinds....)
    But Damn, I spend lots of time configuring it, however, it was used rarely. So I end up delete the plugin.
  - nvim-bufferline.lua: Yes, with lua and neovim only

- Tools: floatterm, scrollview

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

The setup should work with nvim0.5.1+ or nvim0.6+. A patched nerd font is needed. Also if you start nvim from terminal,
make sure it support nerdfont and emoji

### missing sqlite, libsqlite3

Some of the plugin I am using depends on sqlite.
By default sqlite was installed on MacOS. For other operating system, if you saw error message about sqlite, please
following the instruction [here to install sqlite](https://github.com/tami5/sqlite.lua#windows)

### Youtube video recording of install process

[Install process](https://youtu.be/5XB28yocmuw)

## Configure

If you would like to sync to my branch. You can add you own setup in lua/overwrite folder

You can put your own plugins setup in `modules/user` folder

## Shell

- OhMyZshell is good, iterm2 is popular, but I turned to
  fish + spaceship + kitty. It is cooool and faster.
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
- develop language: python, go, rust etc
- package management: pip, cater, npm etc
- exa
- ...

## Parking lots

These tools are good, but due to confliction, less use, or, not suite to my workflow

- vim/gvim
- YCM you complete me
- easymotion
- oh-my-zh, iterm2
- zpreztor
- rainbow
- defx
- ALE
