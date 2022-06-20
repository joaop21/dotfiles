# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# asdf
. $(brew --prefix asdf)/libexec/asdf.sh

# Openssl3 - flags for compilers
LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"

# Z
. /opt/homebrew/etc/profile.d/z.sh
