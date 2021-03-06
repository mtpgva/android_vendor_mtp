#!/sbin/sh
#
# This leverages the loki_patch utility created by djrbliss which allows us
# to bypass the bootloader checks on jfltevzw and jflteatt
# See here for more information on loki: https://github.com/djrbliss/loki
#
#
# Run loki patch on boot.img for locked bootloaders, found in loki_bootloaders
#
# Unlocked (dev edition) bootloaders found in unlocked_bootloaders file

export C=/tmp/loki_tmpdir

egrep -q -f /tmp/loki_bootloaders /proc/cmdline
if [ $? -eq 0 ];then
  mkdir -p $C
  dd if=/dev/block/platform/msm_sdcc.1/by-name/aboot of=$C/aboot.img
  /tmp/loki_patch recovery $C/aboot.img /tmp/recovery.img $C/boot.lok || exit 1
  /tmp/loki_flash recovery $C/recovery.lok || exit 1
  rm -rf $C
  exit 0
fi

egrep -q -f /tmp/unlocked_bootloaders /proc/cmdline
if [ $? -eq 0 ];then
  echo '[*] Unlocked bootloader version detected.'
  echo '[*] Flashing unmodified boot.img to device.'
  dd if=/tmp/recovery.img of=/dev/block/platform/msm_sdcc.1/by-name/recovery || exit 1
  exit 0
fi

echo '[*] Unknown bootloader version detected.'
echo '[*] Not flashing boot.img to this device.'
exit 0
