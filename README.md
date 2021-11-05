# vim as a programming IDE

This neovim configure file is highly optimized for loading performance. Packer lazy loading + After rendering async plugin loading. Maybe the
only nvim setup in github that can render multiple files with treesitter in less than 80ms with ~80 plugins installed
(e.g. Open both util.lua(1686 loc) and lsp.lua(1538 loc) from neovim source code in 80.6ms)

The `Plug` config is located in branch [Plug branch](https://github.com/ray-x/dotfiles/tree/zprezto-plug)

- nvim+kitty configured with pop menu:

  ![vim_ide with nvim+kitty](https://github.com/ray-x/dotfiles/blob/master/img/menu.jpg?raw=true)

- nvim clap preview:

  ![vim_ide with nvim+kitty](https://github.com/ray-x/dotfiles/blob/master/img/clap.jpg?raw=true)

- nvim+kitty + compe (cmp) :

  ![vim_ide with
nvim+kitty](https://user-images.githubusercontent.com/1681295/109258178-db2e6d80-784d-11eb-9cef-8b1cc6435e01.png?raw=true)

## Neovim Plugins

There are lots of amazing plugins,
I used following plugin a lots

- `Plug` -> `Dein` -> `Lua-Packer`
  Change to Lua-Packer does not
  decrease startup time as Plug -> Dein. But still about 80ms faster for Golang codes loading.
  If you interested in Dein version, Please refer to [Dein](https://github.com/ray-x/dotfiles/tree/nvim-comple).
  This was the last Dein/Packer dual supports version I have (init.vim has a flag to choose).
  ATM, minium support for vim. Most plugins only works under neovim 0.5.0+.

  I followed Raphael(a.k.a glepnir) https://github.com/glepnir/nvim dotfiles. He provides a good wrapper for
  Packer. I have an `overwrite` folder which will override the settings. Also, lots of changes in modules/plugins.
  luarock setup
  A.T.M. nvim-compe/cmp as a completion engine with LSP, LSP saga. vim-multi-cursor, clap/telescope. treesitter,
  lazy load vim-go. So, other than module folder, I could copy/paste everything else from glepnir's configure file,
  which make my life easier.

- vim-clap

  One of the best plugin for search anything. I used it to replace fzf, leaderF, leaderP, defx, Ag/Ack/Rg, yank(ring), project management. undolist and many more. Telescope is awesome, only issue is it is slower in large project.

- nvim-lsp with [navigator.lua](https://github.com/ray-x/navigator.lua)

  I turn off vim-go auto-complete/LSP and turn to nvim-lsp. It adds around 200ms bootup time and some of the extensions
  might crash when I using coc (but it hard to check which becuase ~4 node.js services coc forked)
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

## Configure

If you would like to sync to my branch. You can add you own setup in lua/overwrite folder

You can put your own plugins setup in `modules/user` folder

## Shell

- OhMyZshell is good, iterm2 is popular, but I turned to
  fish + spaceship + kitty. It is cooool and faster.
  nvim+kitty split view:

  ![vim_ide with nvim+kitty](https://github.com/ray-x/dotfiles/blob/master/img/kitty.jpg)

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
