#/bin/bash -e

# --- Constants

readonly HOMEDIR="/Users/chris"
readonly HOSTNAME="robot-node-04"

# --- Colors

black="\[\033[0;30m\]"        # Black
red="\[\033[0;31m\]"          # Red
green="\[\033[0;32m\]"        # Green
yellow="\[\033[0;33m\]"       # Yellow
blue="\[\033[0;34m\]"         # Blue
purple="\[\033[0;35m\]"       # Purple
cyan="\[\033[0;36m\]"         # Cyan
white="\[\033[0;37m\]"        # White

# Resets the style
reset=`tput sgr0`

# Color-echo. Improved. [credit to @joaocunha]
# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}

 # --- Get Started

# Set continue to false by default
CONTINUE=false
clear

echo ""
cecho "###############################################" $red
cecho "#        DO NOT RUN THIS SCRIPT BLINDLY       #" $red
cecho "#         YOU'LL PROBABLY REGRET IT...        #" $red
cecho "#                                             #" $red
cecho "#              READ IT THOROUGHLY             #" $red
cecho "#         AND EDIT TO SUIT YOUR NEEDS         #" $red
cecho "###############################################" $red
echo ""

echo ""
cecho "Have you read through the script you're about to run and " $red
cecho "understood that it will make changes to your computer? (y/n)" $red
read -r response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  CONTINUE=true
  echo "OK... Here we go!"
fi

if ! $CONTINUE; then
  # Check if we're continuing and output a message if not
  cecho "Please go read the script, it only takes a few minutes" $red
  exit
fi

# --- Unix Environment

# Dot Files

cecho "###############################################" $blue
echo ""
echo "Cloning .dotfiles repo..."
echo ""

git clone https://github.com/bad-mushroom/dotfiles.git $HOMEDIR/.dotfiles
$HOMEDIR/.dotfiles/setup.sh

echo ""
cecho "Done." $green
echo ""

# Directories

cecho "###############################################" $blue
echo ""
echo "Adding custom directories..."
echo ""

mkdir -p $HOMEDIR/.ssh/keys/public     ## SSH Public Key Store
mkdir -p $HOMEDIR/.ssh/keys/private    ## SSH Private Key Store
mkdir -p $HOMEDIR/Projects             ## Code Projects
mkdir -p $HOMEDIR/tmp                  ## Misc Crap

echo ""
cecho "Done." $green
echo ""

# sudo

cecho "###############################################" $blue
echo ""
echo "From here on we need root access. Enter your password."
echo ""

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Hostname

cecho "###############################################" $blue
echo ""
echo "Setting hostname to $HOSTNAME"
echo ""

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
echo "Installing MacOS updates:"
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
	xcode-select --install
fi

echo ""
cecho "Done." $green
echo ""

cecho "###############################################" $blue
echo ""
echo "Enabling Firewall..."
echo ""

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
defaults write com.apple.screencapture type jpg

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

apps=(
	atom				# Code Editor
	bash 				# Bash Shell
	caffeine			# Prevent Sleep Mode
	git					# Git Client
	google-chrome		# Chrome Browser
	iterm2				# Terminal
	lastfm				# Audioscrobbler Client
	slack				# Slack Chat/Communication
	rescuetime			# Productivity Tracking
	vagrant				# Virtual Machine Management
	vim					# CLI Editor
	virtualbox			# Virtual Machines
	wget				# CLI HTTP File Retrieval
)

brew cask install ${apps[@]}
brew cleanup

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
