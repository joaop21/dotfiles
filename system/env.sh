# Dotfiles
export DOTFILES="$HOME/.dotfiles"

# User Directories
export XDG_CONFIG_HOME="$DOTFILES"			# Where user-specific configurations are written
export XDG_CACHE_HOME="$HOME/.cache"			# Where user-specific non-essential (cached) data is written
export XDG_DATA_HOME="$HOME/.local/share"		# Where user-specific data files is written

# FZF
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --ignore-file $DOTFILES/ripgrep/.ripgrepignore"

# GnuPG
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"	# Default GnuPG home directory
export GPG_TTY=$(tty)				# Required for gpg-agent daemon

# OpenSSL3
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"

# Ripgrep
export RIPGREP_CONFIG_PATH="$DOTFILES/ripgrep/.ripgreprc"

# Z
export _Z_DATA="$XDG_DATA_HOME/z/.z"	# Datafile location
