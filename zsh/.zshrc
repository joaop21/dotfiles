# Aliases
source $DOTFILES/system/aliases.sh

# Completion
source $DOTFILES/zsh/options/completion.zsh

# Expansion and Globbing
source $DOTFILES/zsh/options/expansion_globbing.zsh

# History
source $DOTFILES/zsh/options/history.zsh

# Navigation
source $DOTFILES/zsh/options/navigation.zsh

# Bindings
source $DOTFILES/zsh/bindings.zsh

# Theme - SHOULD BE SOURCED BEFORE PLUGINS
source $DOTFILES/zsh/themes/.themes.zsh

# Zoxide
eval "$(zoxide init zsh)"

# Plugins - SHOULD BE AT THE END OF THIS FILE
source $DOTFILES/zsh/plugins/.plugins.zsh
