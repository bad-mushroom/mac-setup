#/bin/bash -e

# --- Constants

readonly HOMEDIR="/Users/chris"
readonly HOSTNAME="robot-node-04"


# --- Unix Environment

# Dot Files
git clone https://github.com/bad-mushroom/dotfiles.git $HOMEDIR/.dotfiles
$HOMEDIR/.dotfiles/setup.sh

# Directories
mkdir $HOMEDIR/.ssh/keys/public     ## SSH Public Key Store
mkdir $HOMEDIR/.ssh/keys/private    ## SSH Private Key Store
mkdir $HOMEDIR/Projects             ## Code Projects
mkdir $HOMEDIR/tmp                  ## Misc Crap

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Hostname
scutil –-set HostName $HOSTNAME
scutil –-set LocalHostName $HOSTNAME
scutil –-set ComputerName $HOSTNAME


# --- MacOS Updates

softwareupdate --install --all


# --- GCC/Xcode Tools

if [[ ! -e `which gcc` || ! -e `which gcc-4.2` ]]; then
	xcode-select --install
fi


# --- MacOS Preferences

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


# --- Homebrew Package Manger

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

mkdir $HOMEDIR/Applications
brew linkapps

brew install homebrew/completions/brew-cask-completion

apps=(
	1password			# Password Manager
	atom				# Code Editor
	audacity			# Audio Recorder
	bash 				# Bash Shell
	caffeine			# Prevent Sleep Mode
	git					# Git Client
	gnupg				# GPG Encryption
	google-chrome		# Chrome Browser
	google-drive		# Google Drive Client
	iterm2				# Terminal
	lastfm				# Audioscrobbler Client
	php70				# php 7.0
	slack				# Slack Chat/Communication
	transmission		# Torrent Client
	rescuetime			# Productivity Tracking
	vagrant				# Virtual Machine Management
	vim					# CLI Editor
	virtualbox			# Virtual Machines
	wget				# CLI HTTP File Retrieval
)

brew cask install ${apps[@]}
brew cleanup


# -- App Config

# Atom
cp ./apps/atom/config/ $HOMEDIR/.atom/
apm install `cat apps/atom/packages.list`

# SSH
cp ./apps/ssh/config $HOMEDIR/.ssh/


# --- Misc

# Enable Filevault
fdesetup enable


# Exit root shell
exit
