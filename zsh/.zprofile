# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Openssl3 - flags for compilers
LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"

# Z
. /opt/homebrew/etc/profile.d/z.sh

# JAVA
JAVA_HOME="$XDG_DATA_HOME/.asdf/plugins/java/set-java-home.zsh"
if [ -f $JAVA_HOME ]; then
  . $JAVA_HOME
fi

# Cargo
CARGO_HOME="$XDG_DATA_HOME/.cargo/env"
if [ -f $CARGO_HOME ]; then
  . $CARGO_HOME
fi

# Go
GO_PATH="$XDG_DATA_HOME/.asdf/plugins/golang/set-go-path.zsh"
if [ -f $GO_PATH ]; then
  . $GO_PATH
fi

# Direnv
eval "$(direnv hook zsh)"


#####################
#                   #
# Profile Dependant #
#                   #
#####################

# asdf - yarn
export PATH="$(yarn global bin):$PATH"
