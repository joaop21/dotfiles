# +-----+
# | Cat |
# +-----+

alias cat='bat --paging=never'

# +-----+
# | Git |
# +-----+

alias g='git'
alias ga='git add'
alias gamend='git commit --amend --no-edit'
alias gb='git branch'
alias gbd='git branch -d'
alias gc='git commit'
alias gcam='git commit -am'
alias gcm='git commit -m'
alias gch='git checkout'
alias gchb='git checkout -b'
alias gchm='git checkout main'
alias gcl='git clone'
alias gd='git diff'
alias gdf='git diff --staged'
alias gl='git log'
alias glast='git log -1 --stat'
alias glog='g log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'
alias gpup='git push --set-upstream origin $(git branch --show-current)'
alias grb='git rebase'
alias grbm='git rebase main'
alias gs='git status'
alias gsp='git stash pop'
alias gss='git stash'
alias gst='git status'
alias gsw='git switch'
alias gundo='git reset HEAD~1 --soft'

# +----+
# | gh |
# +----+

alias gpr='gh pr view --web 2>/dev/null || gh pr create --web'

# +----+
# | ls |
# +----+

alias ll='eza -alh --git --icons'

# +------+
# | nvim |
# +------+

alias nv='nvim'

# +------+
# | tmux |
# +------+

alias tmux='tmux -f "$TMUX_CONF"'
alias vi='nvim'
alias vim='nvim'
