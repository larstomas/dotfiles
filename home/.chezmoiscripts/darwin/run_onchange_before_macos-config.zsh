#!/bin/zsh

# Inspiration: 
# [dotfiles/.macos at main · mathiasbynens/dotfiles](http://mths.be/osx)
# [freshinstall/1.macos-settings.sh at master · bramus/freshinstall](https://github.com/bramus/freshinstall/blob/master/steps/1.macos-settings.sh)
# [awesome-macos-command-line - Use your macOS terminal shell to do awesome things.](https://git.herrbischoff.com/awesome-macos-command-line/about/#desktop)
# [dotfiles/setup-macos.sh at master · pawelgrzybek/dotfiles](https://github.com/pawelgrzybek/dotfiles/blob/master/setup-macos.sh)

echo "# Starting macOS Setup"

#- Error handling 
# [set -e, -u, -o, -x pipefail explanation](https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021)
# -e: exit on error
set -euf -o pipefail

#- ask for admin password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Close System Preferences
osascript -e 'tell application "System Preferences" to quit'

#- Set hostnamn
computername="$(hostname)"
echo -e "\n  What should your computer be named? (default: $computername)"
echo -ne "  > \033[34m\a"
read
echo -e "\033[0m\033[1A"
[ -n "$REPLY" ] && computername=$REPLY

#-- Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName $computername
sudo scutil --set HostName $computername
sudo scutil --set LocalHostName $computername
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $computername

#- Quit System Preferences
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

# System Preferences > Dock > Automatically hide and show the Dock:
defaults write com.apple.dock autohide -bool true

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

#-- Lock Screen
# Require password immediately after sleep or screen saver begins
#TODO defaults write com.apple.screensaver askForPassword -int 1
#TODO defaults write com.apple.screensaver askForPasswordDelay -int 0

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


#- Terminal
# Use Pro Theme as default
defaults write com.apple.terminal "Startup Window Settings" -string "Pro"
defaults write com.apple.terminal "Default Window Settings" -string "Pro"

# Disable bell
TERMINAL_PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"
TERMINAL_THEME=`/usr/libexec/PlistBuddy -c "Print 'Default Window Settings'" $TERMINAL_PLIST`
#/usr/libexec/PlistBuddy -c "Set 'SecureKeyboardEntry' YES" $TERMINAL_PLIST
/usr/libexec/PlistBuddy -c "Set 'Window Settings':${TERMINAL_THEME}:Bell false" $TERMINAL_PLIST
#/usr/libexec/PlistBuddy -c "Set 'Window Settings':$TERMINAL_THEME:VisualBellOnlyWhenMuted false" $TERMINAL_PLIST

# Terminal > Preferences > Profiles > Pro > Shell > "When the shell exits" : Close terminal if shell exits cleanly
/usr/libexec/PlistBuddy -c "Set 'Window Settings':${TERMINAL_THEME}:shellExitAction 1" $TERMINAL_PLIST



#- Safari
# Start with all windows from last session
defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool true

defaults write com.apple.Safari AlwaysShowTabBar -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari ShowFavoritesBar-v2 -bool true
defaults write com.apple.Safari ShowStatusBar -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Make a new tab or window active when it opens. 
defaults write com.apple.Safari OpenNewTabsInFront -bool true 

#- General
# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true



#- Third-Party Software
#-- iTerm2 Settings
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.dotfiles/iterm2"
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true


#- Finish macOS Setup
killall Finder
killall Dock
killall cfprefsd    # Kill Safari


echo "\n<<< macOS Setup Complete.
    A logout or restart might be necessary. >>>\n"