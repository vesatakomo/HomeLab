#!/usr/bin/env python3
import os
import subprocess
import urllib.request
import urllib.error
import xml.etree.ElementTree as ET
from html import escape

OPNSENSE = "xxxx@192.168.1.1"
SSH_KEY = "/xxxx/.ssh/opnsense_inventory"
TRILIUM = "http://192.168.1.5:8001"
NOTE_ID = "xxxxxxxxxx"
TOKEN_FILE = "/srv/docker/network-inventory/trilium.token"

def get_mappings():
    result = subprocess.run(
        [
            "ssh", "-i", SSH_KEY,
            "-o", "IdentitiesOnly=yes",
            "-o", "BatchMode=yes",
            "-o", "ConnectTimeout=15",
            OPNSENSE, "cat /conf/config.xml",
        ],
        check=True, capture_output=True, text=True, timeout=60
    )
    root = ET.fromstring(result.stdout)
    mappings = []

    for m in root.findall("./dhcpd/lan/staticmap"):
        mappings.append({
            "ip": (m.findtext("ipaddr") or "").strip(),
            "hostname": (m.findtext("hostname") or "").strip(),
            "mac": (m.findtext("mac") or "").strip(),
            "description": (m.findtext("descr") or "").strip(),
        })

    def sort_key(item):
        ip = item["ip"]
        if not ip:
            return (1, ())
        try:
            import ipaddress
            return (0, int(ipaddress.ip_address(ip)))
        except ValueError:
            return (0, ip)

    return sorted(mappings, key=sort_key)

def make_html_table(mappings):
    rows = []
    for m in mappings:
        cells = [
            escape(m["ip"]),
            escape(m["hostname"]),
            escape(m["mac"]),
            escape(m["description"]),
        ]
        rows.append(
            "<tr>" + "".join(f"<td>{cell}</td>" for cell in cells) + "</tr>"
        )

    return (
        "<h2>Network Inventory</h2>\n"
        f"<p>Static DHCP mappings: {len(mappings)}</p>\n"
        "<table><thead><tr>"
        "<th>IP address</th><th>Hostname</th>"
        "<th>MAC address</th><th>Description</th>"
        "</tr></thead><tbody>"
        + "".join(rows)
        + "</tbody></table>\n"
    )

def update_trilium(content):
    with open(TOKEN_FILE, encoding="utf-8") as f:
        token = f.read().strip()

    request = urllib.request.Request(
        f"{TRILIUM}/etapi/notes/{NOTE_ID}/content",
        data=content.encode("utf-8"),
        headers={
            "Authorization": token,
            "Content-Type": "text/plain",
        },
        method="PUT",
    )

    with urllib.request.urlopen(request, timeout=30) as response:
        return response.status

def main():
    mappings = get_mappings()
    if not mappings:
        raise RuntimeError("No static mappings found; refusing to update note")

    status = update_trilium(make_html_table(mappings))
    print(f"Updated Trilium note {NOTE_ID}: {len(mappings)} mappings (HTTP {status})")

if __name__ == "__main__":
    main()
