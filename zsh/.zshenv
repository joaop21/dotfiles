# Dotfiles
export DOTFILES="$HOME/.dotfiles"

# User Directories
export XDG_CONFIG_HOME="$DOTFILES"			# Where user-specific configurations are written
export XDG_CACHE_HOME="$HOME/.cache"			# Where user-specific non-essential (cached) data is written
export XDG_DATA_HOME="$HOME/.local/share"		# Where user-specific data files is written

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Zsh Environment variables
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_CACHE_HOME/.zhistory"    	# History filepath
export HISTSIZE=10000                   	# Maximum events for internal history
export SAVEHIST=10000                   	# Maximum events in history file

# GnuPG
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"	# Default GnuPG home directory
export GPG_TTY=$(tty)				# Required for gpg-agent daemon

# PATH
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"	# OpenSSL3
