#!/bin/bash
set -e

echo "Enabling RoutingViaHost..."
oc patch network.operator.openshift.io/cluster --type=merge -p '{"spec": {"defaultNetwork": {"ovnKubernetesConfig": {"gatewayConfig": {"routingViaHost": true}}}}}'

echo "Enabling FRR Provider..."
oc patch network.operator.openshift.io/cluster --type=merge -p '{"spec": {"additionalRoutingCapabilities": {"providers": ["FRR"]}}}'

echo "Enabling Route Advertisements..."
oc patch network.operator cluster --type merge --patch '{"spec":{"defaultNetwork":{"ovnKubernetesConfig":{"routeAdvertisements":"Enabled"}}}}'

echo "Enabling Global IP Forwarding..."
oc patch Network.operator.openshift.io cluster --type=merge -p='{"spec":{"defaultNetwork":{"ovnKubernetesConfig":{"gatewayConfig":{"ipForwarding":"Global"}}}}}'

echo "Cluster operators patched successfully."
