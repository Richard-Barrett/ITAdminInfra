#!/bin/bash

# Configure Directories for MacOS 
cd ~
  mkdir .ssh
  mkdir Documents
  mkdir Dart
  mkdir Flutter
  mkdir Personal
  mkdir Projects
  mkdir Scripts
cd ~

# Install Brew
cd ~/Git/ITAdminInfra
  ./install_brew.sh
cd ~

# Install Brew Packages
cd ~/Git/ITAdminInfra/Administration/MacOS/Brew
  ./install_brew_packages.sh
cd ~

# Install oh-my-zsh
echo $SHELL
cd ~/Git/ITAdminInfra
  ./install_oh_my_zsh.sh
cd ~

# Make Sym Links
# ln -s /path/to/original /path/to/link
ls -s ~/Git/Administration/Git/autopull.sh ~/git
