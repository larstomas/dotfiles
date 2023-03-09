#!/bin/zsh


#- Error handling 
# [set -e, -u, -o, -x pipefail explanation](https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021)
# -e: exit on error
set -euf -o pipefail

export HOMEBREW_CASK_OPTS="--no-quarantine" 
export HOMEBREW_BUNDLE_FILE="$DOTFILES/Brewfile"

time brew bundle 