echo "# START .zshrc: $(date)"


# zhs manual: man zshoptions
# Zsh/Bash startup files loading order (.bashrc, .zshrc etc.) - https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/
## What is the difference between .zshrc and .zprofile? - https://www.reddit.com/r/zsh/comments/e882c4/what_is_the_difference_between_zshrc_and_zprofile/

# TODO split configuration to more files
# As in: zsh - create a minimal config (autosuggestions, syntax highlighting etc..) no oh-my-zsh required - https://youtu.be/bTLYiNvRIVI

# dotfiles
## https://github.com/Mach-OS/Machfiles/blob/master/zsh/.zshrc
  ## zsh - create a minimal config (autosuggestions, syntax highlighting etc..) no oh-my-zsh required - https://youtu.be/bTLYiNvRIVI
## https://gist.github.com/LukeSmithxyz/e62f26e55ea8b0ed41a65912fbebbe52
  ## https://youtu.be/eLEo4OQ-cuQ


# History Configuration 
####################################
HISTSIZE=5000               #How many lines of history to keep in memory
HISTFILE=~/.zsh_history     #Where to save history to disk
SAVEHIST=5000               #Number of history entries to save to disk
HISTDUP=erase               #Erase duplicates in the history file
setopt    appendhistory     #Append history to the history file (no overwriting)
setopt    sharehistory      #Share history across terminals
setopt    incappendhistory  #Immediately append to the history file, not just when a
#TODO:
#setopt EXTENDED_HISTORY
#setopt HIST_EXPIRE_DUPS_FIRST
#setopt HIST_IGNORE_DUPS
#setopt HIST_IGNORE_ALL_DUPS
#setopt HIST_IGNORE_SPACE
#setopt HIST_FIND_NO_DUPS
#setopt HIST_SAVE_NO_DUPS
#setopt HIST_BEEP #term is killed


# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit -i
_comp_options+=(globdots)		# Include hidden files.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'



# Keybindings
####################################
# Make CTRL-u not removing the hole line
bindkey \^U backward-kill-line


# Alias
####################################

# List
alias z='j'
alias ll='ls -alF'

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# easier to read disk
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB

# get top process eating memory
alias psmem='ps auxf | sort -nr -k 4 | head -5'

# get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3 | head -5'

# Git
alias commit='git add-A; git commit-m'


#zsh-prompt - https://github.com/Mach-OS/Machfiles/blob/master/zsh/.config/zsh/zsh-prompt
####################################
## autoload vcs and colors
autoload -Uz vcs_info
autoload -U colors && colors



# enable only git 
zstyle ':vcs_info:*' enable git 

# setup a hook that runs before every ptompt. 
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# add a function to check for untracked files in the directory.
# from https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
# 
+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep '??' &> /dev/null ; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[staged]+='!' # signify new files with a bang
    fi
}

zstyle ':vcs_info:*' check-for-changes true
# zstyle ':vcs_info:git:*' formats " %r/%S %b %m%u%c "
zstyle ':vcs_info:git:*' formats " %{$fg[blue]%}(%{$fg[red]%}%m%u%c%{$fg[magenta]%}%b%{$fg[blue]%})"
# zstyle ':vcs_info:git:*' formats " %{$fg[blue]%}(%{$fg[red]%}%m%u%c%{$fg[yellow]%}%{$fg[magenta]%} %b%{$fg[blue]%})"

# format our main prompt for hostname current folder, and permissions. 
PROMPT="%B%{$fg[blue]%}[%{$fg[white]%}%n%{$fg[red]%}@%{$fg[white]%}%m%{$fg[blue]%}] %(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$fg[cyan]%}%c%{$reset_color%}"
# PROMPT="%{$fg[green]%}%n@%m %~ %{$reset_color%}%#> "
#Alternative PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

PROMPT+="\$vcs_info_msg_0_ "
# TODO look into this for more colors
# https://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
# also ascii escape codes
####################################


# Functions
####################################
# #TODO - stuve


# Loads
####################################

# Load fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# Load zsh-autosuggestions
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load zsh-syntax-highlighting; should be last.
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

echo "# END .zshrc: $(date)"
