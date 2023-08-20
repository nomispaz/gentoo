# https://wiki.archlinux.org/title/zsh
# https://github.com/Chrysostomus/manjaro-zsh-config/blob/master/manjaro-zsh-config

#includes
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

#options
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt inc_append_history                                       # save commands are added to the history immediately, otherwise only when shell exits.
setopt histignorespace                                          # Don't save commands that start with space
setopt correct                                                  # Auto correct mistakes
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing

#autoload functions
autoload -Uz compinit && compinit
autoload -Uz promptinit && promptinit

#define output of working directory or in addition user and hostname
# %n for user
#PROMPT='%n %~ %# '
# %B% for bold, %F for coloured working folder
PROMPT='%B%F{cyan}%~ %# '

# hit tab twice to show list of options and select option
zstyle ':completion:*' menu select
#hit tab once to show list of options or if completion is not ambigous, complete
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion 

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
#save history
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000

#Keybindings
bindkey '^[[H' beginning-of-line                                # Pos1 key
bindkey '^[[F' end-of-line                                      # End key
bindkey '^[[A' history-substring-search-up						# Arrow up
bindkey '^[[B' history-substring-search-down					# Arrow down
bindkey '^[[C' forward-char                                     # Right key
bindkey '^[[D' backward-char                                    # Left key

# Navigate words with ctrl+arrow keys
bindkey '^[[1;5D' backward-word                                 # STRG + Arrow left
bindkey '^[[1;5C' forward-word                                  # STRG + ARROW right

# Colour man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-R

# File and Dir colours for ls and other outputs
export LS_OPTIONS='--color=auto'
eval "$(dircolors -b)"
alias ls='ls $LS_OPTIONS'
