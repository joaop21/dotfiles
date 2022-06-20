# Dotfiles
export DOTFILES="$HOME/.dotfiles"

# User Directories
export XDG_CONFIG_HOME="$DOTFILES"			# Where user-specific configurations are written
export XDG_CACHE_HOME="$HOME/.cache"			# Where user-specific non-essential (cached) data is written
export XDG_DATA_HOME="$HOME/.local/share"		# Where user-specific data files is written

# GnuPG
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"	# Default GnuPG home directory
export GPG_TTY=$(tty)				# Required for gpg-agent daemon

# OpenSSL3
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"

# Z
export _Z_DATA="$XDG_DATA_HOME/z/.z"	# Datafile location
