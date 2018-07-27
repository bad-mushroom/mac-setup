#/bin/bash -e

# -----------------------------------------------------------------------------
#    Configuration
#
#    Set configuration options in this section.
#       - Home directory
#       - Hostname
#       - Apps to install
#       - Directories to create
# -----------------------------------------------------------------------------

# Set the full path to your user's home directory
readonly HOMEDIR="/Users/chris"

# Set the hostname for the computer
readonly HOSTNAME="robot-node-04"

# Apps to install via Homebrew Package Manager
declare -a BREW_APPS=(
  bash              # Bash Shell
  git               # Git Client
  google-drive      # Google Cloud Storage
  nodejs            # Node
  npm               # Node Package Manager
  vagrant           # Virtual Machine Management
  vim               # CLI Editor
  wget              # CLI HTTP File Retrieval
)

# GUI Apps to install via Homebrew Package Manager using Cask
declare -a BREW_CASK_APPS=(
  atom              # Code Editor
  caffeine          # Prevent Sleep Mode
  dashlane          # Password Manager
  docker            # Docker for Mac
  google-chrome     # Chrome Browser
  iterm2            # Terminal
  lastfm            # Audioscrobbler Client
  macdown           # Markdown Editor
  sequel-pro        # MySQL GUI
  slack             # Chat/Communication
  rescuetime        # Productivity Tracking
  transmit          # File Transfers
  virtualbox        # Virtual Machines
)

# Directories to create

declare -a DIRS=(
  $HOMEDIR/.ssh/keys/public     ## SSH Public Key Store
  $HOMEDIR/.ssh/keys/private    ## SSH Private Key Store
  $HOMEDIR/Projects             ## Code Projects
  $HOMEDIR/tmp                  ## Misc Crap
)

# -----------------------------------------------------------------------------
#    End Configuration
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
#    Get Started
# -----------------------------------------------------------------------------

# --- Terminal Colors

export CLICOLOR=1
export TERM=xterm-color

black="\[\033[0;30m\]"
red="\[\033[0;31m\]"
green="\[\033[0;32m\]"
yellow="\[\033[0;33m\]"
blue="\[\033[0;34m\]"
purple="\[\033[0;35m\]"
cyan="\[\033[0;36m\]"
white="\[\033[0;37m\]"

# Resets the style
reset=`tput sgr0`

# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}

 # --- Prompt to run

# Set continue to false by default
CONTINUE=false
clear

echo ""
cecho "Are you ready to get started? (y/n)" $red
read -r response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  CONTINUE=true
  echo "OK... Here we go!"
fi

if ! $CONTINUE; then
  exit
fi

# --- Unix Environment

# sudo

cecho "###############################################" $blue
echo ""
echo "From here on we need root access. "
echo "Enter your password..."
echo ""

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Hostname

cecho "###############################################" $blue
echo ""
echo "Setting hostname to $HOSTNAME..."
echo ""
cecho "###############################################" $blue

sudo scutil --set ComputerName $HOSTNAME
sudo scutil --set HostName $HOSTNAME
sudo scutil --set LocalHostName $HOSTNAME
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $HOSTNAME

echo ""
cecho "Done." $green
echo ""

# --- MacOS Updates

cecho "###############################################" $blue
echo ""
echo "Installing MacOS updates..."
echo ""

softwareupdate --install --all

echo ""
cecho "Done." $green
echo ""

# --- GCC/Xcode Tools

cecho "###############################################" $blue
echo ""
echo "Checking for Xcode..."
echo ""

if [[ ! -e `which gcc` || ! -e `which gcc-4.2` ]]; then
  echo "Installing Xcode"
  echo ""
  xcode-select --install
fi

echo ""
cecho "Done." $green
echo ""

cecho "###############################################" $blue
echo ""
echo "Enabling Firewall..."
echo ""

# --- Firewall

# Enable Filevault
fdesetup enable

echo ""
cecho "Done." $green
echo ""

# --- MacOS Preferences

cecho "###############################################" $blue
echo ""
echo "Setting Mac OS preferences..."
echo ""

# Expand the save and print panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Finder
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowStatusBar -bool true
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
chflags nohidden ~/Library/

# Show battery percentage/time remaining
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
defaults write com.apple.menuextra.battery ShowTime -string "NO"

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Disable opening Photos on device plug in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Login screen message
defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "What is thy bidding, my master?"

# Show all device icons in finder
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

# Default screenshot format
defaults write com.apple.screencapture type png

# Kill affected applications
for app in Finder Dock; do killall "$app"; done
killall SystemUIServer

echo ""
cecho "Done." $green
echo ""

# --- Homebrew Package Manger

cecho "###############################################" $blue
echo ""
echo "Installing Homebrew..."
echo ""

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo ""
cecho "Done." $green
echo ""

cecho "###############################################" $blue
echo ""
echo "Installing apps..."
echo ""

brew install ${BREW_APPS[@]}
brew cask install ${BREW_CASK_APPS[@]}
brew cleanup

# --- Directories

cecho "###############################################" $blue
echo ""
echo "Adding custom directories..."
echo ""

for dir in "${DIRS[@]}"
do
  if [ ! -d $dir ]; then
    mkdir -p $dir
  fi
done

echo ""
cecho "Done." $green
echo ""

# --- Dot Files

cecho "###############################################" $blue
echo ""
echo "Cloning .dotfiles repo..."
echo ""

git clone https://github.com/bad-mushroom/dotfiles.git $HOMEDIR/.dotfiles
$HOMEDIR/.dotfiles/setup.sh
source $HOMEDIR/.bashrc

echo ""
cecho "Done." $green
echo ""

# --- Done!

echo ""
echo ""
echo "That's all folks..."
echo ""
echo ""
cecho "################################################################################" $white
echo ""
echo ""
cecho "Note that some of these changes require a logout/restart to take effect." $red
cecho "Killing some open applications in order to take effect." $red
echo ""

find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete

for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer"; do
  killall "${app}" > /dev/null 2>&1
done

# Exit root shell
exit
