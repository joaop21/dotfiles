# zsh-completions plugin
fpath=($DOTFILES/zsh/plugins/zsh-completions/src $fpath)

# asdf
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)

# Homebrew autosuggestions
if type brew &>/dev/null; then
  export FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"

  autoload -Uz compinit
  compinit
fi

# FZF
[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null

# +---------+
# | Options |
# +---------+

setopt AUTO_LIST		# Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD	# Complete from both ends of a word.
setopt MENU_COMPLETE		# Automatically highlight first element of completion menu

# +-----------------+
# | ZStyle Patterns |
# +-----------------+

# Define completers
zstyle ':completion:*' completer _extensions _complete _approximate

# Use cache for commands using cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

# Case-insensitive path-completion 
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

# Use menu selection instead of tab cycle
zstyle ':completion:*' menu select

# Pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# Format messages
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'
zstyle ':completion:*:*:*:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:*:*:*:warnings' format ' %F{red}-- no matches found --%f'
