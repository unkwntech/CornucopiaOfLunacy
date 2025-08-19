#!/bin/bash

# This script is set to run once on VM Templates, when the template is cloned and started this uses the proxmox
# api to fetch the name of the VDI and uses that to set teh hostname.

# Requires
# curl
# jq
# Proxmox User with API Key

APIUSER='api@pam'
APIPASS='hunter2'
APIHOST='https://proxmox.local'

uid=`id -u`
if [ $uid -gt 0 ]; then
	echo "Must be run as root."
	exit 1;
fi

LOCALIP=`ip a s ens18 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
ticketres=`curl $APIHOST"/api2/json/access/ticket" -d "username=$APIUSER" -d "password=$APIPASS" -k -s -X POST`
csrf=`echo $ticketres | jq ".data.CSRFPreventionToken"`
ticket=`echo $ticketres | jq ".data.ticket" | jq @uri | tr -d '"'`
targetID=-1;

#get node name
curl -k -s -b PVEAuthCookie=$ticket $HOST"/api2/json/nodes" | jq -c ".data[].node" - |  while read nodeData; do
	node=`echo $nodeData | tr -d '"'`
	curl -k -s -b  PVEAuthCookie=$ticket $HOST"/api2/json/nodes/$node/qemu" | jq -c ".data[]" - | while read vmData; do
		status=`echo $vmData | jq ".status" | tr -d '"'`
		if [ "running" =  "$status" ]; then
			vmid=`echo $vmData | jq ".vmid" | tr -d '"'`
			curl -k -s -b PVEAuthCookie=$ticket $HOST"/api2/json/nodes/$node/qemu/$vmid/agent/network-get-interfaces" | jq -c ".data.result[]" - | while read interface; do
				addresses=`echo $interface | sed -r 's/-/_/g' | jq ".ip_addresses[].ip_address"`
				for i in $addresses; do
					address=`echo $i | tr -d '"'`
					if [ $address = $LOCALIP ]; then
						hn=`echo $vmData | jq ".name" | tr -d '"'`
						old=`hostname`
						hostname -b $hn
						echo $hn > /etc/hostname
						sed -i -e "s/$old/$hn/g" /etc/hosts
					fi
				done
			done
		fi
	done
done