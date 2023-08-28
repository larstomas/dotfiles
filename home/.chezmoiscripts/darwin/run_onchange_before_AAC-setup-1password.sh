#!/bin/sh

#- Error handling
# [set -e, -u, -o, -x pipefail explanation](https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021)
# -e: exit on error
set -euf -o pipefail

echo "Running script has basename $( basename -- "$0"; ), dirname $( dirname -- "$0"; )";
echo "The present working directory is $( pwd; )";

#- Ask for admin password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


#- Configure 1Password
open -a 1Password
echo ">>> Configure 1Password - https://developer.1password.com/docs/cli/get-started/"
read -p "Then press any key to continue"


#- Sign in to 1Password, need 1Password-CLI to be installed
SUBDOMAIN="backman"
EMAIL="larstomas@gmail.com"
op account add --address $SUBDOMAIN.1password.com --email $EMAIL
eval $(op signin --account $SUBDOMAIN)
op whoami

