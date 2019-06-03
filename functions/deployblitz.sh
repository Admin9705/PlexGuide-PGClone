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
executeblitz () {

# Reset Front Display
rm -rf plexguide/deployed.version

# Call Variables
pgclonevars

# to remove all service running prior to ensure a clean launch
ansible-playbook /pg/pgclone/ymls/remove.yml

# gdrive deploys by standard
echo "tdrive" > /pg/var/deploy.version
echo "bu" > /pg/var/deployed.version
type=gdrive
encryptbit=""
ansible-playbook /pg/pgclone/ymls/mount.yml -e "\
  vfs_bs=$vfs_bs
  vfs_dcs=$vfs_dcs
  vfs_dct=$vfs_dct
  vfs_cma=$vfs_cma
  vfs_rcs=$vfs_rcs
  vfs_rcsl=$vfs_rcsl
  drive=gdrive"

type=tdrive
ansible-playbook /pg/pgclone/ymls/mount.yml -e "\
  vfs_bs=$vfs_bs
  vfs_dcs=$vfs_dcs
  vfs_dct=$vfs_dct
  vfs_cma=$vfs_cma
  vfs_rcs=$vfs_rcs
  vfs_rcsl=$vfs_rcsl
  drive=tdrive"

# deploy only if pgmove is using encryption
if [[ "$transport" == "be" ]]; then
ansible-playbook /pg/pgclone/ymls/crypt.yml -e "\
  vfs_bs=$vfs_bs
  vfs_dcs=$vfs_dcs
  vfs_dct=$vfs_dct
  vfs_cma=$vfs_cma
  vfs_rcs=$vfs_rcs
  vfs_rcsl=$vfs_rcsl
  drive=gcrypt"

echo "be" > /pg/var/deployed.version
type=tcrypt
encryptbit="C"
ansible-playbook /pg/pgclone/ymls/crypt.yml -e "\
  vfs_bs=$vfs_bs
  vfs_dcs=$vfs_dcs
  vfs_dct=$vfs_dct
  vfs_cma=$vfs_cma
  vfs_rcs=$vfs_rcs
  vfs_rcsl=$vfs_rcsl
  drive=tcrypt"
fi

# builds the list
ls -la /pg/data/blitz/.blitzkeys/ | awk '{print $9}' | tail -n +4 | sort | uniq > /pg/var/.blitzlist
rm -rf /pg/var/.blitzfinal 1>/dev/null 2>&1
touch /pg/var/.blitzbuild
while read p; do
  echo $p > /pg/var/.blitztemp
  blitzcheck=$(grep "GDSA" /pg/var/.blitztemp)
  if [[ "$blitzcheck" != "" ]]; then echo $p >> /pg/var/.blitzfinal; fi
done </pg/var/.blitzlist

# deploy union
ansible-playbook /pg/pgclone/ymls/pgunion.yml -e "\
  transport=$transport \
  type=$type
  multihds=$multihds
  encryptbit=$encryptbit
  vfs_dcs=$vfs_dcs
  hdpath=$hdpath"

# output final display
if [[ "$type" == "tdrive" ]]; then finaldeployoutput="PG Blitz - Unencrypted"
else finaldeployoutput="PG Blitz - Encrypted"; fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💪 DEPLOYED: $finaldeployoutput
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

read -rp '↘️  Acknowledge Info | Press [ENTER] ' typed < /dev/tty

}
