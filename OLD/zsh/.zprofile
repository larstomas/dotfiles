echo "# START .zprofile: $(date)"


#eval "$(/opt/homebrew/bin/brew shellenv)"
#eval $($(which brew) shellenv)

# asdf
#. /usr/local/opt/asdf/libexec/asdf.sh
#OLD . /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash
# export ASDF_DIR="$(brew --prefix asdf)/libexec"
# source $ASDF_DIR/asdf.sh
 	export NVM_DIR="$HOME/.nvm"
 	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm 
# 	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

### Go ###
#export GOPRIVATE="gitlab.com/sendify/*,gitlab.com/sendify-api/*"
# Wherever you decide to install Go, e.g. "$HOME/go" or "$HOME/.local/share/go")
#export GOPATH=
#export GO111MODULE="on"

### Go ###
export GOPRIVATE="gitlab.com/sendify/*,gitlab.com/sendify-api/*"
# Wherever you decide to install Go, e.g. "$HOME/go" or "$HOME/.local/share/go")
export GOPATH=$HOME/go
export GO111MODULE="on"


# Enable autocompletion for zsh, via brew install zsh-completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  # Enable the completion system
  ## The -U means mark the function compinit for autoloading and suppress alias expansion. The -z means use zsh (rather than ksh) style. See also the functions command.
  autoload -Uz compaudit compinit
  # Initialize all completions on $fpath and ignore (-i) all insecure files and directories
  compinit -i
fi


echo "# END .zprofile: $(date)"