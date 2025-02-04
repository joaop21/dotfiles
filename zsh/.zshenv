# Source the system evironment variables file
source $HOME/.dotfiles/system/env.sh
source $HOME/.dotfiles/system/secret.env.sh

# Zsh Environment variables
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_CACHE_HOME/zsh/.zhistory"    	# History filepath
export HISTSIZE=10000                   		# Maximum events for internal history
export SAVEHIST=10000		                   	# Maximum events in history file
