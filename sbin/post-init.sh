#APQ8084 tune
echo 4 > /sys/module/lpm_levels/enable_low_power/l2
echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu2/power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu3/power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu2/power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu3/power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu0/retention/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu1/retention/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu2/retention/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu3/retention/idle_enabled
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo "alucard" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "alucard" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "alucard" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo "alucard" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
echo 120 > /sys/module/cpu_boost/parameters/boost_ms
echo 1497600 > /sys/module/cpu_boost/parameters/sync_threshold
echo 1497600 > /sys/module/cpu_boost/parameters/input_boost_freq
echo 980 > /sys/module/cpu_boost/parameters/input_boost_ms
echo 1 > /dev/cpuctl/cpu.notify_on_migrate
echo 268000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 268000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo 268000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
echo 268000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
echo 2649600 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 2649600 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
echo 2649600 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
echo 2649600 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
echo 16650 > /sys/class/devfreq/qcom,cpubw.35/max_freq
echo 1728000 > /sys/class/devfreq/qcom,cache.34/max_freq
echo 1 > /sys/module/msm_thermal/core_control/enabled
chown -h  system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
chown -h root.system /sys/devices/system/cpu/cpu1/online
chown -h root.system /sys/devices/system/cpu/cpu2/online
chown -h root.system /sys/devices/system/cpu/cpu3/online
chmod -h 664 /sys/devices/system/cpu/cpu1/online
chmod -h 664 /sys/devices/system/cpu/cpu2/online
chmod -h 664 /sys/devices/system/cpu/cpu3/online
chmod 444 /sys/class/graphics/fb0/dynamic_fps
chmod 666 /sys/class/kgsl/kgsl-3d0/max_gpuclk
chmod 666 /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/governor
chmod 666 /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/*_freq
echo "100000000" > /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/min_freq
echo "600000000" > /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/max_freq
echo 1 > /sys/class/kgsl/kgsl-3d0/max_pwrlevel

CGROUP_ROOT=/dev/cpuctl
mkdir $CGROUP_ROOT/native
echo 150000 > $CGROUP_ROOT/native/cpu.rt_runtime_us

# We could be racing with task creation, as a result of which its possible that
# we may fail to move all tasks from root cgroup to native cgroup in one shot.
# Retry few times before giving up.

for loop_count in 1 2 3
do
	for i in $(cat $CGROUP_ROOT/tasks)
	do
		echo $i > $CGROUP_ROOT/native/tasks
	done

	root_tasks=$(cat $CGROUP_ROOT/tasks)
	if [ -z "$root_tasks" ]
	then
		break
	fi
done

# Check if we failed to move all tasks from root cgroup
if [ ! -z "$root_tasks" ]
then
	echo "Error: Could not move all tasks to native cgroup"
fi

#=====================================================

# Mount root as RW to apply tweaks and settings
mount -o remount,rw /;
mount -o remount,rw, /system;

# WIFI MAC address
start wififtmd

# Permissions for LMK
chmod 0664 /sys/module/lowmemorykiller/parameters/adj
chmod 0664 /sys/module/lowmemorykiller/parameters/minfree
chmod 0664 /sys/module/lowmemorykiller/parameters/cost
chmod 0664 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
chmod 0664 /sys/module/lowmemorykiller/parameters/vmpressure_file_min

# Tune LMK with values we love
echo "12288,15360,18432,21504,24576,30720" > /sys/module/lowmemorykiller/parameters/minfree
echo 32 > /sys/module/lowmemorykiller/parameters/cost

# Adaptive LMK
echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
echo 53059 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min

# Process Reclaim
echo 1 > /sys/module/process_reclaim/parameters/enable_process_reclaim
echo 100 > /sys/module/process_reclaim/parameters/pressure_max

# Tweak VM
echo 200 > /proc/sys/vm/dirty_expire_centisecs
echo 20 > /proc/sys/vm/dirty_background_ratio
echo 40 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/swappiness

CLEAN_BUSYBOX()
{
	for f in *; do
		case "$(readlink "$f")" in *usybox*)
			rm "$f"
		;;
		esac
	done;
}
if [ ! -e /system/etc/busybox_installed ];then
	# Cleanup the old busybox symlinks
	cd /system/xbin/;
	CLEAN_BUSYBOX;

	cd /system/bin/;
	CLEAN_BUSYBOX;

	cd /;

	# Install latest busybox to ROM
	cp /sbin/busybox /system/xbin/;

	/system/xbin/busybox --install -s /system/xbin/

	chmod 06755 /system/xbin/busybox;

	touch /system/etc/busybox_installed;
fi

# Make tmp folder
mkdir /tmp;

# Give permissions to execute
chown -R root:system /tmp/;
chmod -R 777 /tmp/;
chmod -R 777 /res/;
chmod 6755 /res/synapse/actions/*;
chmod 6755 /sbin/*;
chmod 6755 /system/xbin/*;
echo "Boot initiated on $(date)" > /tmp/bootcheck;

echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
echo 53059 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min

if [ ! -e /jz_tune ]; then
	mkdir /jz_tune;
	chmod -R 777 /jz_tune;
	ln -s /sys/devices/system/cpu/cpu0/cpufreq/ /jz_tune/cpufreq;
	ln -s /sys/module/msm_thermal/parameters/ /jz_tune/thermal;
	ln -s /sys/kernel/alucard_hotplug/ /jz_tune/alucard;
fi;


chown system /sys/devices/system/cpu/cpu0/cpufreq/*
chown system /sys/devices/system/cpu/cpu1/online
chown system /sys/devices/system/cpu/cpu2/online
chown system /sys/devices/system/cpu/cpu3/online
chmod 666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
chmod 666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
chmod 666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq
chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/stats/*
chmod 666 /sys/devices/system/cpu/cpu1/online
chmod 666 /sys/devices/system/cpu/cpu2/online
chmod 666 /sys/devices/system/cpu/cpu3/online
chmod 666 /sys/module/msm_thermal/parameters/*
chmod 666 /sys/class/kgsl/kgsl-3d0/max_gpuclk

# tune I/O controls to boost I/O performance
echo "0" > /sys/devices/msm_sdcc.1/mmc_host/mmc0/mmc0:0001/block/mmcblk0/queue/add_random;
echo "1" > /sys/devices/msm_sdcc.1/mmc_host/mmc0/mmc0:0001/block/mmcblk0/queue/nomerges;
echo "1" > /sys/devices/msm_sdcc.1/mmc_host/mmc0/mmc0:0001/block/mmcblk0/mmcblk0rpmb/queue/nomerges;
echo "1" > /sys/devices/msm_sdcc.1/mmc_host/mmc0/mmc0:0001/block/mmcblk0/queue/rq_affinity;
echo "1" > /sys/devices/msm_sdcc.1/mmc_host/mmc0/mmc0:0001/block/mmcblk0/mmcblk0rpmb/queue/rq_affinity;

# tune I/O controls to boost I/O performance
echo "0" > /sys/devices/msm_sdcc.2/mmc_host/mmc1/mmc1:*/block/mmcblk1/queue/add_random;
echo "1" > /sys/devices/msm_sdcc.2/mmc_host/mmc1/mmc1:*/block/mmcblk1/queue/nomerges;
echo "1" > /sys/devices/msm_sdcc.2/mmc_host/mmc1/mmc1:*/block/mmcblk1/queue/rq_affinity;

# Calibrate display
echo 1 > /sys/devices/platform/kcal_ctrl.0/kcal_enable;
echo "256 256 253" > /sys/devices/platform/kcal_ctrl.0/kcal;
echo 251 > /sys/devices/platform/kcal_ctrl.0/kcal_sat;
echo 255 > /sys/devices/platform/kcal_ctrl.0/kcal_cont;
echo 4 > /sys/devices/platform/kcal_ctrl.0/kcal_hue;
echo 256 > /sys/devices/platform/kcal_ctrl.0/kcal_val;

# Install Busybox
/sbin/busybox --install -s /sbin

ln -s /res/synapse/uci /sbin/uci
/sbin/uci

if [ ! -e /data/.selinux_disabled ]; then
	setenforce 0
fi;

# Allow untrusted apps to read from debugfs
if [ -e /system/lib/libsupol.so ]; then
/system/xbin/supolicy --live \
	"allow untrusted_app debugfs file { open read getattr }" \
	"allow untrusted_app sysfs_lowmemorykiller file { open read getattr }" \
	"allow untrusted_app persist_file dir { open read getattr }" \
	"allow debuggerd gpu_device chr_file { open read getattr }" \
	"allow netd netd capability fsetid" \
	"allow netd { hostapd dnsmasq } process fork" \
	"allow { system_app shell } dalvikcache_data_file file write" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file dir { search r_file_perms r_dir_perms }" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file file { r_file_perms r_dir_perms }" \
	"allow system_server { rootfs resourcecache_data_file } dir { open read write getattr add_name setattr create remove_name rmdir unlink link }" \
	"allow system_server resourcecache_data_file file { open read write getattr add_name setattr create remove_name unlink link }" \
	"allow system_server dex2oat_exec file rx_file_perms" \
	"allow mediaserver mediaserver_tmpfs file execute" \
	"allow drmserver theme_data_file file r_file_perms" \
	"allow zygote system_file file write" \
	"allow atfwd property_socket sock_file write" \
	"allow debuggerd app_data_file dir search"
fi;

echo "1024" > /proc/sys/kernel/random/read_wakeup_threshold;
echo "256" > /proc/sys/kernel/random/write_wakeup_threshold;

# Enable Power modes
echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled

if [ ! -d /system/etc/init.d ]; then
	mkdir /system/etc/init.d;
fi
chmod 755 /system/etc/init.d/*
busybox run-parts /system/etc/init.d/

mount -o remount,rw /;
mount -o remount,rw, /system;

# stop google service and restart it on boot. this remove high cpu load and ram leak!
if [ "$(pidof com.google.android.gms | wc -l)" -eq "1" ]; then
	kill $(pidof com.google.android.gms);
fi;
if [ "$(pidof com.google.android.gms.unstable | wc -l)" -eq "1" ]; then
	kill $(pidof com.google.android.gms.unstable);
fi;
if [ "$(pidof com.google.android.gms.persistent | wc -l)" -eq "1" ]; then
	kill $(pidof com.google.android.gms.persistent);
fi;
if [ "$(pidof com.google.android.gms.wearable | wc -l)" -eq "1" ]; then
	kill $(pidof com.google.android.gms.wearable);
fi;

setprop windowsmgr.max_events_per_sec 240;
# make sure bq24296 iusb was no limited
echo 2000 > /sys/module/bq24296_charger/parameters/iusb_control;

# sharpe control
chmod 0755 /sbin/sharpening
if [ -e /data/sp_cm ];then
	chmod 0755 /data/sp_cm;
	input keyevent 26;
	sleep 1;
	input keyevent 26;
	echo `cat /data/sp_cm` > /sys/devices/virtual/graphics/fb0/lge_sharpening_level;
fi
# sharpe control

exit;
