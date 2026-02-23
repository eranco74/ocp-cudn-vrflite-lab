#!/bin/bash
# This script is injected via SSH to run directly on the OpenShift Worker Node
set -e

# Variables (Ensure these match your actual node interfaces)
PARENT_IFACE="enp1s0"
VLAN_ID="101"
VRF_NAME="tenant2-net"
VRF_TABLE="1009"
VLAN_IP="10.0.1.2/24"

echo "Creating VRF: ${VRF_NAME} (Table ${VRF_TABLE})..."
sudo ip link add ${VRF_NAME} type vrf table ${VRF_TABLE} || true
sudo ip link set ${VRF_NAME} up

echo "Creating VLAN ${VLAN_ID} on ${PARENT_IFACE}..."
sudo ip link add link ${PARENT_IFACE} name ${PARENT_IFACE}.${VLAN_ID} type vlan id ${VLAN_ID} || true

echo "Enslaving VLAN to VRF and assigning IP ${VLAN_IP}..."
sudo ip link set dev ${PARENT_IFACE}.${VLAN_ID} master ${VRF_NAME}
sudo ip addr add ${VLAN_IP} dev ${PARENT_IFACE}.${VLAN_ID} || true

echo "Bouncing interface to ensure clean route table population..."
sudo ip link set dev ${PARENT_IFACE}.${VLAN_ID} down
sudo ip link set dev ${PARENT_IFACE}.${VLAN_ID} up

ip vrf show
ip route show vrf ${VRF_NAME}
