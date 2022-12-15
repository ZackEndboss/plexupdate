# Description
Automatically update Plex Media Server on Debian

# How to
Download update_plex.sh

As root:

crontab -e

Add cronjob Task for 06:01 every day:

01 6 * * * /path/update_plex.sh >> /path/update_plex.log

Thanks to https://forums.plex.tv/u/j0nsplex & https://github.com/martinorob
