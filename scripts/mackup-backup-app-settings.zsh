#!/bin/zsh

#- Error handling 
# [set -e, -u, -o, -x pipefail explanation](https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021)
# -e: exit on error
set -euf -o pipefail

mackup --force backup
sleep 1
cd $HOME/.config/
zip -r $HOME/Downloads/mackup-backup.zip ./Mackup -x "*.DS_Store"
mackup --force uninstall
mv $HOME/.config/Mackup $HOME/Downloads/