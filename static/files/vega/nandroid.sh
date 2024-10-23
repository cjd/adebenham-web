#!/bin/bash
# Shell script to create/restore/check nandroid backups directly via nvflash
# Useful for when the device is unable to even boot to clockworkmod
#
# Created 10-March-2011 by Chris Debenham
# Downloaded from http://www.adebenham.com/vega/nandroid.sh
#
# Usage:
#   nandroid -s <backup_path>  - Save backup to <backup_path>
#   nandroid -r <backup_path>  - Restore backup from <backup_path>
#   nandroid -c <backup_path>  - Check backup in <backup_path>
#
if [ "$1" = "-r" ]
then echo Restoring backup from $2
  ./nvflash -w --bl ./bootloader.bin --download 6 $2/recovery.img
  ./nvflash --resume --download 7 $2/boot.img
  ./nvflash --resume --download 8 $2/system.img
  ./nvflash --resume --download 9 $2/cache.img
  ./nvflash --resume --download 11 $2/data.img
  ./nvflash --resume --sync
  echo Restore done
  echo Reboot tablet?
  read line
  if [ "$line" = "y" ]; then ./nvflash --resume --sync --go;fi
elif [ "$1" = "-s" ]
then echo Saving backup to $2
  mkdir -p $2
  ./nvflash -w --bl ./bootloader.bin --read 6 $2/recovery.img
  ./nvflash --resume --read 7 $2/boot.img
  ./nvflash --resume --read 8 $2/system.img
  ./nvflash --resume --read 9 $2/cache.img
  ./nvflash --resume --read 11 $2/data.img
  pushd $2 > /dev/null
  md5sum *.img > nandroid.md5
  popd > /dev/null
  echo Backup done
  echo Reboot tablet?
  read line
  if [ "$line" = "y" ]; then ./nvflash --resume --sync --go;fi
elif [ "$1" = "-c" ]
then echo Checking backup in $2
  pushd $2 > /dev/null
  while read LINE
  do FILE=`echo $LINE | sed -e 's/^.* //g'`
    if [ "`md5sum $FILE`" = "$LINE" ]
    then echo $FILE OK
    else echo $FILE Bad
    fi
  done < nandroid.md5
  popd > /dev/null
else echo nandroid.sh usage:
  echo "nandroid -s <backup_path>  - Save backup to <backup_path>"
  echo "nandroid -r <backup_path>  - Restore backup from <backup_path>"
  echo "nandroid -c <backup_path>  - Check backup in <backup_path>"
fi
