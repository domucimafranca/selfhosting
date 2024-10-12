# Vim and Tux configuration files

## vim

My vim configurations are configured to turn it into a passable code
editor.  At its core is Vundle.vim, plus some plugins that Vundle
can manage later on.

For its base, we need an upgraded version of vim with python3 support.
vim-nox meets this requirement.

> sudo apt-get install vim-nox
    
Then we install the Vundle package.
    
> git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    
Finally, set .vimrc in the home directory, fire up vim, and run PluginInstall.

For added effect, download and install a glyph-enabled font from 
https://www.nerdfonts.com/font-downloads.  (I prefer Agave.)  This shows the
proper icons required by the vim-devicons plugin.

Note: Having vim-tmux-navigator without the properly configured tmux on the
system will result in some squiggly artifacts on the vim screen.  Either 
remove the plugin or set up tmux.

## tmux

tmux provides the tiling capabilities within the terminal.  It makes for a good
combination with vim.  tmux plugins are managed by tpm.

Since tmux is not installed by default, first we install it.

> sudo apt-get install tmux

Then we install tpm, the tmux plugin manager

> git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

Set .tmux.conf in the home directory.

Finally, fire up tmux and run \<C-b>\,i to install the plugins.

Works best with a glyph-enabled font to show the icons in tmux-powerline.

More instructions from https://github.com/tmux-plugins/tpm

In my current configuration, \<C-h\>, \<C-j\>, \<C-k\>, and \<C-l\> allow you to
move between panes. This is same behavior is consistent with a vim
window.
