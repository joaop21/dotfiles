# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# asdf
. $(brew --prefix asdf)/libexec/asdf.sh

# Openssl3 - flags for compilers
LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"

# Z
. /opt/homebrew/etc/profile.d/z.sh

# JAVA
. $XDG_DATA_HOME/.asdf/plugins/java/set-java-home.zsh

# Cargo
. $XDG_DATA_HOME/.cargo/env

# Go
. $XDG_DATA_HOME/.asdf/plugins/golang/set-env.zsh

# Direnv
eval "$(direnv hook zsh)"


#####################
#                   #
# Profile Dependant #
#                   #
#####################

# asdf - yarn
export PATH="$(yarn global bin):$PATH"
