#!/bin/bash
#Testline for SSH
#/usr/bin/ssh -o BatchMode=yes dockerhost true || exit 99
#exec >> /root/tdarr_vcpu.log 2>&1
#set -x
#echo "=== $(date) ==="

# CONFIG
VMID=100                     # your dockerhost VM
LOW=6                        # vCPUs when idle
HIGH=12                       # vCPUs when transcoding
IDLE_REQUIRED=3              # how many idle checks before reducing
STATEFILE="/root/tdarr_vcpu.state"
IDLEFILE="/root/tdarr_vcpu_idle_count"
APPRISE_URL="http://192.168.x.x:xxxx/notify/apprise"

# Detect transcoding
if /usr/bin/ssh -o Batchmode=yes dockerhost \
 "docker exec tdarr sh -c 'ps aux | grep -i ffmpeg | grep -vq grep'"; then
    transcoding=1
else
    transcoding=0
fi
# Load last applied vCPU count
last=$(/usr/sbin/qm config "$VMID" | awk '/^vcpus:/ {print $2}')
# Load idle counter
idle_count=0
[ -f "$IDLEFILE" ] && idle_count=$(cat "$IDLEFILE")
# Apprise notification
notify_high() {
    curl -s -X POST \
         -F "tags=all" \
         -F "body=vCPUs for Tdarr raised to $HIGH" \
         "$APPRISE_URL" >/dev/null 2>&1
}
# If transcoding → go HIGH immediately
if [ "$transcoding" -eq 1 ]; then
    if [ "$last" != "$HIGH" ]; then
        echo "Tdarr active → setting VM $VMID vCPUs to $HIGH"
        /usr/sbin/qm set "$VMID" -vcpus "$HIGH"
        echo "$HIGH" > "$STATEFILE"
        #Notification
        notify_high
    fi
    echo 0 > "$IDLEFILE"
    exit 0
fi


# If idle → increase idle counter
idle_count=$((idle_count + 1))
echo "$idle_count" > "$IDLEFILE"

# Not idle long enough → do nothing yet
if [ "$idle_count" -lt "$IDLE_REQUIRED" ]; then
    exit 0
fi

# Idle threshold reached → drop to LOW if not already there
if [ "$last" != "$LOW" ]; then
    echo "Tdarr idle for $IDLE_REQUIRED mins → setting VM $VMID vCPUs to $LOW"
    /usr/sbin/qm set "$VMID" -vcpus "$LOW"
    echo "$LOW" > "$STATEFILE"
    echo 0 > "$IDLEFILE"
fi

exit 0
