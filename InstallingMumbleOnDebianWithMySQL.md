# Installing Mumble on Debian

## Install Prereqs

1. `sudo apt install mumble-server mysql-common mysql-client libqt5sql5-mysql`

## Connecting to Mumble for the first time

1. Connect to server
1. Right-Click self and choose "Register", confirm.
1. Stop server
1. Set superuser password `sudo /usr/sbin/murmurd -supw [password]`
1. 