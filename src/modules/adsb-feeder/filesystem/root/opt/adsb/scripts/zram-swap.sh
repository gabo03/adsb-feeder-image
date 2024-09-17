#!/bin/bash

set -e
trap 'echo "[ERROR] Error in line $LINENO when executing: $BASH_COMMAND"' ERR

# only run on adsb.im images
if ! [[ -f /opt/adsb/os.adsb.feeder.image ]]; then
    exit 0
fi

if [[ -e /dev/zram0 ]]; then
    exit 1
fi

modprobe zram
echo lz4 > /sys/block/zram0/comp_algorithm

# user max quarter of memory
use=$(( $(grep -e MemTotal /proc/meminfo | tr -s ' ' | cut -d' ' -f2) / 4 ))
# never more than 1G
maxkb=$(( 1 * 1024 * 1024 ))

if (( use > maxkb )); then
    size=$maxkb
else
    size=$use
fi

# disk size
echo $(( 2 * size ))K > /sys/block/zram0/disksize
# max memory usage
echo $(( size ))K > /sys/block/zram0/mem_limit

mkswap /dev/zram0
swapon -p 100 /dev/zram0
