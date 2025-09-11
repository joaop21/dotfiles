# Dotfiles
export DOTFILES="$HOME/.dotfiles"

# User Directories
export XDG_CONFIG_HOME="$DOTFILES"        # Where user-specific configurations are written
export XDG_CACHE_HOME="$HOME/.cache"      # Where user-specific non-essential (cached) data is written
export XDG_DATA_HOME="$HOME/.local/share" # Where user-specific data files is written
#export XDG_CONFIG_HOME="$HOME/.config"      # Where user-specific configurations are stored

# +--------------------+
# |                    |
# | Add New Envs Above |
# |                    |
# + -------------------+

# ASDF
export ASDF_DATA_DIR="$XDG_DATA_HOME/.asdf"
export ASDF_CONFIG_FILE="$DOTFILES/asdf/.asdfrc"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Bat
export BAT_CONFIG_PATH="$DOTFILES/bat/config"

# Cargo
export CARGO_HOME="$XDG_DATA_HOME/.cargo"

# Foundry
export FOUNDRY_DIR="$XDG_DATA_HOME/.foundry"
export PATH="$PATH:$XDG_DATA_HOME/.foundry/bin"

# FZF
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
	export PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --ignore-file $DOTFILES/ripgrep/.ripgrepignore"

# GnuPG
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg" # Default GnuPG home directory
export GPG_TTY=$(tty)                     # Required for gpg-agent daemon

# OpenSSL3
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"

# Ripgrep
export RIPGREP_CONFIG_PATH="$DOTFILES/ripgrep/.ripgreprc"

# Rustup
export RUSTUP_HOME="$XDG_DATA_HOME/.rustup"

# Wezterm
export WEZTERM_CONFIG_FILE="$DOTFILES/wezterm/wezterm.lua"

# Z
export Z_DATA_FOLDER="$XDG_DATA_HOME/z"
mkdir -p $Z_DATA_FOLDER
export _Z_DATA="$Z_DATA_FOLDER/.z" # Datafile location

# ERLANG

export WX_CONFIG=/opt/homebrew/Cellar/wxwidgets@3.2/3.2.8.1/bin/wx-config-3.2
export KERL_BUILD_DOCS=yes
export KERL_INSTALL_MANPAGES=yes
export KERL_USE_AUTOCONF=0
# export KERL_CONFIGURE_OPTIONS="--disable-debug \
#                                --disable-hipe \
#                                --disable-sctp \
#                                --disable-silent-rules \
#                                --enable-darwin-64bit \
#                                --enable-dynamic-ssl-lib \
#                                --enable-kernel-poll \
#                                --enable-shared-zlib \
#                                --enable-smp-support \
#                                --enable-threads \
#                                --enable-wx \
#                                --with-wx-config=/usr/local/bin/wx-config \
#                                --without-javac \
#                                --without-jinterface \
#                                --without-odbc"

export KERL_CONFIGURE_OPTIONS="--without-javac --enable-wx --with-ssl=/opt/homebrew/opt/openssl@3 --with-wx-config=$WX_CONFIG"

# Zig
export PATH="/opt/homebrew/opt/zig@0.14/bin:$PATH"
