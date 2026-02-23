#!/bin/bash
# This script is injected via SSH to run directly on the Libvirt Hypervisor
set -e

echo "Creating OVS Bridge 'testpr'..."
sudo ovs-vsctl add-br testpr || true

echo "Defining Libvirt Network 'testpr'..."
cat << 'EOF' > /tmp/testpr.xml
<network>
  <name>testpr</name>
  <forward mode='bridge'/>
  <bridge name='testpr'/>
  <virtualport type='openvswitch'/>
</network>
EOF

sudo virsh net-define /tmp/testpr.xml || true
sudo virsh net-start testpr || true
sudo virsh net-autostart testpr || true

echo "OVS Bridge and Libvirt network created."
