#!/bin/bash
# sudo chmod 777 near-backup-script.sh
# run script sudo near-backup-script.sh
# run from crone:
# 0  12 *  *  * /home/near-stakewars/near-backup-script.sh >> /home/near-stakewars/.near/backups/backup.log 2>&1

DATE=$(date +%Y-%m-%d-%H-%M)
DATADIR=/home/near-stakewars/.near/data
BACKUPDIR=/home/near-stakewars/.near/backups/near_${DATE}

mkdir -p $BACKUPDIR
sudo systemctl stop neard.service
wait
echo "NEAR node was stopped" 

if [ -d "$BACKUPDIR" ]; then
    echo "Backup started" 

    cp -rf $DATADIR/ ${BACKUPDIR}/
    echo "Backup completed" 
else
    echo $BACKUPDIR is not created. Check your permissions.
    exit 0
fi

sudo systemctl start neard.service

echo "NEAR node was started" 
