#!/sbin/busybox sh

BB=/sbin/busybox

SYSTEM=$($BB blkid /dev/block/bootdevice/by-name/system | $BB grep "f2fs" | $BB wc -l);

if [ "${SYSTEM}" -eq "1" ]; then
	$BB mount -t f2fs /dev/block/bootdevice/by-name/system /system;
else
	$BB mount -t ext4 -o noatime,noauto_da_alloc,errors=continue /dev/block/bootdevice/by-name/system /system;
fi;
