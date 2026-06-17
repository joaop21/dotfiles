# Source the system evironment variables file
source $HOME/.dotfiles/system/env.sh
source $HOME/.dotfiles/system/secret.env.sh

# Keep zsh's standard autoload functions reachable, and never export FPATH.
# zsh ties FPATH (env scalar) <-> fpath (array). An exported FPATH carries a
# version-pinned functions dir (.../Cellar/zsh/<ver>/...) that goes stale on
# `brew upgrade zsh`; inherited by a long-lived child (e.g. a tmux pane that
# outlived the upgrade) it shadows the new dir and breaks autoload —
# add-zsh-hook, compinit, is-at-least all fail with "function definition file
# not found". Anchor the version-independent functions dir, then de-export.
[[ -d /opt/homebrew/share/zsh/functions ]] && fpath=(/opt/homebrew/share/zsh/functions $fpath)
typeset +x FPATH

# Zsh Environment variables
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_CACHE_HOME/zsh/.zhistory"    	# History filepath
export HISTSIZE=10000                   		# Maximum events for internal history
export SAVEHIST=10000		                   	# Maximum events in history file
