HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
setopt HIST_EXPIRE_DUPS_FIRST
setopt NO_BEEP
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/mikael/.zshrc'

autoload -Uz compinit && compinit
autoload -U colors && colors

# Exports
export GPG_TTY=$(tty)
export PATH="$PATH:$(go env GOPATH)/bin"
## Fix gray screen on xmaple
export _JAVA_AWT_WM_NONREPARENTING=1
## Firefox wayland support
export MOZ_ENABLE_WAYLAND=1

# Aliases 
alias icat='kitty +kitten icat'
alias clip='kitty +kitten clipboard'
alias ls='ls --color=auto'
alias grep='rg'
alias vim='nvim'
alias scrot="$HOME/.dotfiles/scrot.sh"

# Git Prompt 
# Soure: https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
source $HOME/.git-prompt.sh
setopt PROMPT_SUBST
PS1='%{$fg[magenta]%}%(4~|%-1~/.../%2~|%~)%u%{$reset_color%} %{$fg[red]%}>%{$reset_color%}%{$fg[red]%}>%{$reset_color%}%B%{$fg[blue]%}>%{$reset_color%}%b%{$fg[yellow]%}$(__git_ps1 " \ue725 %s >")%{$reset_color%} '

zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

