#!/bin/bash

# Copy the Keystone File over
printf "Copying Keystonercv3 file over to your home directory...\n"
sudo salt "*ctl*" cmd.run "sudo cp /root/keystonercv3 /home/$USER"
printf "Changing ownership for keystonercv3 file to your user...\n"
sudo salt "*ctl" cmd.run "sudo chown $USER:$USER /home/$USER/keystonercv3"
printf "Keystonercv3 has successfully been copied to your home directory and chowned to your user\n"
