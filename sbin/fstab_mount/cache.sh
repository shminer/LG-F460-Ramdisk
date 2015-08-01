#!/sbin/busybox sh

BB=/sbin/busybox

CACHE=$($BB blkid /dev/block/bootdevice/by-name/cache | $BB grep "f2fs" | $BB wc -l);

if [ ! -e /cache ]; then
	mkdir /cache;
	chown system:cache /cache;
	chmod 0770 /cache;
fi;

if [ "$CACHE" -eq "1" ]; then
	/system/bin/fsck.f2fs -a /dev/block/platform/msm_sdcc.1/by-name/cache;
	$BB mount -t f2fs -o nosuid,nodev /dev/block/bootdevice/by-name/cache /cache;
else
	/system/bin/e2fsck -y /dev/block/bootdevice/by-name/cache
	$BB mount -t ext4 -o noatime,nosuid,nodev,noauto_da_alloc,errors=continue /dev/block/bootdevice/by-name/cache /cache;
fi;

if [ ! -e /cache/lost+found ]; then
	mkdir /cache/lost+found;
	chmod 0770 /cachelost+found;
fi;
