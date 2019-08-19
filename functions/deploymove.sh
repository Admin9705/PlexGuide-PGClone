#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################
# NOTES
# Variable recall comes from /functions/variables.sh
################################################################################
executemove () {

# Reset Front Display
rm -rf plexguide/deployed.version

# Call Variables
pgclonevars

# to remove all service running prior to ensure a clean launch
ansible-playbook /pg/pgclone/ymls/remove.yml

# gdrive deploys by standard
echo "gd" > /pg/var/deploy.version
echo "mu" > /pg/var/deployed.version
type=gd
ansible-playbook /pg/pgclone/ymls/mount.yml -e "\
  vfs_bs=$vfs_bs
  vfs_dcs=$vfs_dcs
  vfs_dct=$vfs_dct
  vfs_cma=$vfs_cma
  vfs_rcs=$vfs_rcs
  vfs_rcsl=$vfs_rcsl
  drive=gd"

# deploy only if pgmove is using encryption
if [[ "$transport" == "me" ]]; then
echo "me" > /pg/var/deployed.version
type=gc
ansible-playbook /pg/pgclone/ymls/crypt.yml -e "\
  vfs_bs=$vfs_bs
  vfs_dcs=$vfs_dcs
  vfs_dct=$vfs_dct
  vfs_cma=$vfs_cma
  vfs_rcs=$vfs_rcs
  vfs_rcsl=$vfs_rcsl
  drive=gc"
fi

# deploy union
ansible-playbook /pg/pgclone/ymls/pgunity.yml -e "\
  transport=$transport \
  multihds=$multihds
  type=$type
  vfs_dcs=$vfs_dcs
  hdpath=$hdpath"

# output final display
if [[ "$type" == "gdrive" ]]; then finaldeployoutput="PG Move - Unencrypted"
else finaldeployoutput="PG Move - Encrypted"; fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💪 DEPLOYED: $finaldeployoutput
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

read -rp '↘️  Acknowledge Info | Press [ENTER] ' typed < /dev/tty

}
