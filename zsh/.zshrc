# Aliases
source $DOTFILES/system/aliases.sh

# Completion
source $DOTFILES/zsh/options/completion.zsh

# Expansion and Globbing
source $DOTFILES/zsh/options/expansion_globbing.zsh

# Bindings
source $DOTFILES/zsh/bindings.zsh

# Theme - SHOULD BE SOURCED BEFORE PLUGINS
source $DOTFILES/zsh/themes/.themes.zsh

# Plugins - SHOULD BE AT THE END OF THIS FILE
source $DOTFILES/zsh/plugins/.plugins.zsh
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/joao/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
