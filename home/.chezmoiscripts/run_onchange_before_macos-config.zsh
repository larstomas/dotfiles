#!/bin/zsh

# Inspiration:
# [dotfiles/.macos at main · mathiasbynens/dotfiles](http://mths.be/osx)
# [freshinstall/1.macos-settings.sh at master · bramus/freshinstall](https://github.com/bramus/freshinstall/blob/master/steps/1.macos-settings.sh)
# [awesome-macos-command-line - Use your macOS terminal shell to do awesome things.](https://git.herrbischoff.com/awesome-macos-command-line/about/#desktop)
# [dotfiles/setup-macos.sh at master · pawelgrzybek/dotfiles](https://github.com/pawelgrzybek/dotfiles/blob/master/setup-macos.sh)


#- Error handling
# [set -e, -u, -o, -x pipefail explanation](https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021)
# -e: exit on error
set -euf -o pipefail

#- Logging: tee all output to a shared log (also stays on the terminal)
chezmoi_log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/chezmoi"
mkdir -p "$chezmoi_log_dir"
exec > >(tee -a "$chezmoi_log_dir/install.log") 2>&1
printf '\n===== %s  %s =====\n' "$(date '+%F %T')" "$(basename -- "$0")"

echo "Running script has basename $( basename -- "$0"; ), dirname $( dirname -- "$0"; )";
echo "The present working directory is $( pwd; )";

# Best-effort `defaults`: some domains (notably Safari's sandboxed container at
# ~/Library/Containers/com.apple.Safari) reject writes unless the running terminal
# has Full Disk Access. Under `set -e` a single such failure aborts the whole
# bootstrap (and, being a run_before script, blocks every later file + script).
# Wrap those writes so they warn instead of dying.
defaults_try() {
  defaults "$@" || echo "  ⚠️  skipped 'defaults $*' — grant the terminal Full Disk Access to apply this" >&2
}


echo "# Starting macOS Setup"

# Close System Preferences
osascript -e 'tell application "System Preferences" to quit'


#- System Preferences (in macOS Ventura 13)
#-- Sound
# "Play feedback when volume is changed" : true
defaults write -g "com.apple.sound.beep.feedback" -int 1

# "Play sound on startup" : false (2026-09-08). Lives in NVRAM, so it needs sudo
# (Touch ID via the AAA script). Best-effort: a missing sudo must not abort the bootstrap.
if [[ "$(nvram StartupMute 2>/dev/null | awk '{print $2}')" != "%01" ]]; then
  sudo nvram StartupMute=%01 || echo "  ⚠️  skipped 'nvram StartupMute=%01' — run it with sudo to silence the startup chime" >&2
fi

#-- Network
# Firewall on (System Settings > Network > Firewall). Was off on lillebror 2026-09-08 (swarm check).
# Needs sudo; best-effort like StartupMute above. Signed apps are still auto-allowed (default),
# so Syncthing, ssh and screen sharing keep working; unsigned apps get the "allow incoming?" dialog.
fw=/usr/libexec/ApplicationFirewall/socketfilterfw
if [[ "$($fw --getglobalstate 2>/dev/null)" != *"enabled"* ]]; then
  sudo $fw --setglobalstate on || echo "  ⚠️  skipped 'socketfilterfw --setglobalstate on' — run it with sudo to turn the firewall on" >&2
fi

#-- Remote Login (ssh): keys only (ssh-vnc-hardning A2, 2026-09-08). ~/.ssh/authorized_keys comes from
# chezmoi (private_dot_ssh), verified from lillebror against all three Macs before this went in.
# sshd validates the file before it is kept, so a typo can never lock ssh; Screen Sharing and the
# console are untouched either way. launchd starts sshd per connection, so no restart is needed.
sshd_hardening=/etc/ssh/sshd_config.d/200-hardening.conf
if ! grep -qs '^PasswordAuthentication no' "$sshd_hardening"; then
  if printf '%s\n' 'PasswordAuthentication no' 'KbdInteractiveAuthentication no' 'PermitRootLogin no' 'MaxAuthTries 3' | sudo tee "$sshd_hardening" >/dev/null; then
    sudo /usr/sbin/sshd -t || { echo "  ⚠️  sshd rejected $sshd_hardening — removing it, passwords stay enabled" >&2; sudo rm -f "$sshd_hardening"; }
  else
    echo "  ⚠️  skipped $sshd_hardening — run chezmoi apply with sudo available to turn ssh passwords off" >&2
  fi
fi

#-- Screen Sharing: no legacy VNC password (ssh-vnc-hardning B1, 2026-09-08). The 8-character DES
# "VNC viewers may control screen with password" mode lets any VNC client in; macOS-account login
# (Screen Sharing app, Screens) is unaffected. Guard on the pref only: kickstart leaves the old
# password file (VNCSettings.txt) behind, harmless once the pref is 0, so the file is no signal.
kickstart=/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart
if [[ "$(defaults read /Library/Preferences/com.apple.RemoteManagement VNCLegacyConnectionsEnabled 2>/dev/null)" == "1" ]]; then
  sudo $kickstart -configure -clientopts -setvnclegacy -vnclegacy no >/dev/null || echo "  ⚠️  skipped 'kickstart -setvnclegacy -vnclegacy no' — run with sudo to turn the legacy VNC password off" >&2
fi

# No weak Diffie-Hellman in Apple's Screen Sharing auth either (ssh-vnc-hardning B5, 2026-09-08): allowInsecureDH
# lets old clients negotiate weak DH; modern macOS clients are unaffected. screensharingd only reads it on restart.
if [[ "$(defaults read /Library/Preferences/com.apple.RemoteManagement allowInsecureDH 2>/dev/null)" == "1" ]]; then
  if sudo defaults write /Library/Preferences/com.apple.RemoteManagement allowInsecureDH -bool false; then
    sudo launchctl kickstart -k system/com.apple.screensharing 2>/dev/null || true
  else
    echo "  ⚠️  skipped 'allowInsecureDH -bool false' — run with sudo to turn weak DH off for Screen Sharing" >&2
  fi
fi

#-- Appearance
# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

#-- Desktop & Dock
# Always prefer tabs
defaults write -g AppleWindowTabbingMode -string "always"

# Ask to keep changes on close
defaults write NSGlobalDomain NSCloseAlwaysConfirmsChanges -int 1

# Disable "Close windows when quitting an application" f
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# When switching applications, switch to respective space
defaults write -g AppleSpacesSwitchOnActivate -bool true

# Dock icon size of 36 pixels.
defaults write com.apple.dock "tilesize" -int "36"

# Dock stays visible (decision 2026-09-07 — was auto-hide; turned off on every Mac in practice)
defaults write com.apple.dock autohide -bool false

# System Preferences > Dock > Automatically hide and show the Dock (duration)
defaults write com.apple.dock autohide-time-modifier -float 0.4

# System Preferences > Dock > Automatically hide and show the Dock (delay)
defaults write com.apple.dock autohide-delay -float 0

#--- Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen
# bl, br, tl, tr
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0


#-- Keyboard
# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Key repeat and init key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable popup showing accented characters when holding down a key
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

#- Finder
# Finder showX settings
#defaults write com.apple.finder ShowRecentTags -bool false
defaults write com.apple.finder ShowSidebar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
#defaults write com.apple.finder ShowTabView -bool true
#defaults write com.apple.finder ShowPreviewPane -bool false
defaults write com.apple.finder ShowPathbar -bool true

# Unhide and alias in home dir
chflags nohidden $HOME/Library

# Show all file extensions inside the Finder
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# Show path bar
defaults write com.apple.finder "ShowPathbar" -bool "true"

# Default view style - List view
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"

# Default search scope - Search the current folder, SCcf = current folder
defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"

# Automatically empty bin after 30 days
defaults write com.apple.finder "FXRemoveOldTrashItems" -bool "true"

# Changing file extension warning - Set to false
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"

# Finder > Preferences > Show warning before removing from iCloud Drive
defaults write com.apple.finder "FXEnableRemoveFromICloudDriveWarning" -bool false

# Save to disk or iCloud by default
defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false"

# Show connected servers
defaults write com.apple.finder "ShowMountedServersOnDesktop" -bool "true"

# Finder > Preferences > General and set ‘New Finder windows show’ to path : Desktop = PfDe, Documents = PfDo, Home = PfHm, Downloads = PfLo
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/Downloads/"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false


#- Safari
# Safari's prefs live in its sandboxed container, which `defaults` cannot write
# unless the terminal has Full Disk Access — so these are best-effort (see
# defaults_try above); a fresh machine will skip them with a warning, not abort.
# Start with all windows from last session
defaults_try write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool true

defaults_try write com.apple.Safari AlwaysShowTabBar -bool true
defaults_try write com.apple.Safari IncludeDevelopMenu -bool true
defaults_try write com.apple.Safari ShowFavoritesBar-v2 -bool true
defaults_try write com.apple.Safari ShowStatusBar -bool true
defaults_try write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults_try write com.apple.Safari AutoOpenSafeDownloads -bool false

# Make a new tab or window active when it opens.
defaults_try write com.apple.Safari OpenNewTabsInFront -bool true

# Private Browsing searches with DuckDuckGo; normal browsing keeps its own engine (2026-09-07)
defaults_try write com.apple.Safari PrivateSearchEngineUsesNormalSearchEngineToggle -bool false
defaults_try write com.apple.Safari PrivateSearchProviderShortName -string "DuckDuckGo"

#- General
# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true


#- Finish macOS Setup
killall Finder
killall Dock


echo "\n<<< macOS Setup Complete.
    A logout or restart might be necessary. >>>\n"