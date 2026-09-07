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