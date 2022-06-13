# +---------------+
# | Powerlevel10k |
# +---------------+

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.dotfiles/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $DOTFILES/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f $DOTFILES/zsh/themes/p10k.zsh ]] || source $DOTFILES/zsh/themes/p10k.zsh
