#!/bin/bash
# Headless Xcode Command Line Tools install, run INSIDE the VM. Equivalent of
# clicking "Install" in the xcode-select --install dialog: the sentinel file makes
# softwareupdate list the on-demand CLT package so it can be installed non-interactively.
set -x
sudo touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
PROD=$(softwareupdate -l 2>&1 | awk -F'Label: ' '/Label: Command Line Tools/ {print $2}' | tail -1)
echo "CLT product: ${PROD}"
if [ -n "$PROD" ]; then
  sudo softwareupdate -i "$PROD" --verbose
fi
sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
xcode-select -p && echo "CLT_READY"
