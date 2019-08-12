#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/bootdevice/by-name/recovery:20988432:96b72086317e338dac8b4a3936c5840d4444b985; then
  applypatch EMMC:/dev/block/bootdevice/by-name/boot:16833040:ac272aaa1d293a86c9cb50ea893829df49b87e90 EMMC:/dev/block/bootdevice/by-name/recovery 96b72086317e338dac8b4a3936c5840d4444b985 20988432 ac272aaa1d293a86c9cb50ea893829df49b87e90:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || echo 454 > /cache/fota/fota.status
else
  log -t install_recovery "Recovery image already installed"
fi

if [ -e /cache/recovery/command ] ; then
  PACKAGE_PATH=""
  SEARCH_COMMAND="--update_package"
  PATH_POS=16
  if [ -e '/system/bin/grep' ] ; then
    PACKAGE_PATH=`cat /cache/recovery/command | grep 'update_package'`
    PACKAGE_ORG_PATH=`cat /cache/recovery/command | grep 'update_org_package'`
    if [ "$PACKAGE_ORG_PATH" != "" ] ; then
      PACKAGE_PATH=$PACKAGE_ORG_PATH
      SEARCH_COMMAND="--update_org_package"
      PATH_POS=20
    fi
    if [ -e /cache/recovery/saved" ] ; then
      rm -rf /cache/recovery/saved
    fi

    if [ -e /data/.recovery/saved" ] ; then
      rm -rf /data/.recovery/saved
    fi
  fi
  if [ "$PACKAGE_PATH" != "" ] ; then
    for PACKAGE_LINE in $PACKAGE_PATH
    do
      if [ ${PACKAGE_LINE:0:$PATH_POS} == $SEARCH_COMMAND ] ; then
        break
      fi
    done
    let PATH_POS+=1
    PACKAGE_PATH=${PACKAGE_LINE:$PATH_POS}
    if [ "$PACKAGE_PATH" != "" ] ; then
      rm $PACKAGE_PATH
      log -t install_recovery "install_recovery tried to remove the delta"
      if [ -e "$PACKAGE_PATH" ]; then
        log -t install_recovery "The delta was not removed in install-recovery.sh"
      else
        log -t install_recovery "The delta was removed in install-recovery.sh"
      fi
    fi
  fi
  if [ ${PACKAGE_PATH:0:5} == "/data" ] ; then
    echo $PACKAGE_PATH > /cache/fota/fota_path_command
    chown system:system /cache/fota/fota_path_command
  fi
  rm /cache/recovery/command
fi
