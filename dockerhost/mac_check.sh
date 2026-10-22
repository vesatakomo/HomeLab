#!/bin/bash

docker inspect $(docker ps -q) |
jq -r '.[] | .Name as $name | .NetworkSettings.Networks | to_entries[] |
       [$name, .key, .value.IPAddress, .value.MacAddress] | @tsv' |
sort -k4 |
awk -F '\t' '
{
    mac = $4
    entries[mac] = entries[mac] sprintf("  %-25s network=%-18s IP=%-18s MAC=%s\n", $1, $2, $3, $4)
    count[mac]++
}
END {
    found = 0
    for (mac in count) {
        if (count[mac] > 1) {
            if (!found++) print "DUPLICATE MAC ADDRESSES FOUND:"
            printf "%s", entries[mac]
        }
    }
    if (!found) print "OK: No duplicate MAC addresses found among running containers."
}'
