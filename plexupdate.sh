#!/bin/bash

# Script to automagically update Plex Media Server on Debian with dpkg
#
# Must be run as root.
#
# @author @martinorob https://github.com/martinorob
# https://github.com/martinorob/plexupdate/
# Edited by Zack

#!/bin/bash
mkdir -p /tmp/plex/ > /dev/null 2>&1
token=$(cat /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml | grep -oP 'PlexOnlineToken="\K[^"]+')
url=$(echo "https://plex.tv/api/downloads/5.json?channel=plexpass&X-Plex-Token=$token")
jq=$(curl -s ${url})
newversion=$(echo $jq | jq -r .computer.Linux.version)
echo New Ver: $newversion
curversion=$(dpkg -s plexmediaserver | grep '^Version:'| cut -d' ' -f2)
echo Cur Ver: $curversion

# Space left check
mbleftusr=$(df --output=avail -k "/usr/lib/plexmediaserver" | sed '1d;s/[^0-9]//g')
mbleftvar=$(df --output=avail -k "/var/lib/plexmediaserver" | sed '1d;s/[^0-9]//g')
mblefttmp=$(df --output=avail -k "/tmp/plex" | sed '1d;s/[^0-9]//g')
if [ $mbleftusr -lt 1500000 ] || [ $mbleftvar -lt 1500000 ] || [ $mblefttmp -lt 1500000 ]
then
  echo "Exit! Less then 1,5GB left on /usr ($mbleftusr) /var ($mbleftvar) or /tmp ($mblefttmp)"
  exit
fi

if [ "$newversion" != "$curversion" ]
then
  echo New Vers Available
  rm -rf /tmp/plex/plexmediaserver_1.*_amd64.deb
  CPU=$(uname -m)
  DISTRO=$(grep "^ID" /etc/os-release | cut -d'=' -f2)
  url=$(echo "${jq}" | jq -r '.computer.Linux.releases[] | select(.distro=="'"${DISTRO}"'") | select(.build=="linux-'"${CPU}"'") | .url')
  echo "wget $url -P /tmp/plex"
  wget $url -P /tmp/plex/
  echo "dpkg -i /tmp/plex/plexmediaserver_1.*_amd64.deb"
  dpkg -i /tmp/plex/plexmediaserver_1.*_amd64.deb
  sleep 30
  rm -rf /tmp/plex/plexmediaserver_1.*_amd64.deb
else
  echo "No New Ver"
fi
exit
