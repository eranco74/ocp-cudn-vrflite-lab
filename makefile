# Makefile for OCP C-UDN VRF-Lite Lab

# --- Environment Variables ---
# Override these when running make, e.g., make host-net WORKER_IP=192.168.122.50
SSH_USER ?= core
WORKER_IP ?= 192.168.122.100
HYPERVISOR_IP ?= 192.168.122.1
HYPERVISOR_USER ?= root

.PHONY: help patch-cluster host-net tenant-deploy router-bridge test-pod

help: ## Show this help menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

patch-cluster: ## 1. Apply cluster-level network operator patches (Runs locally via oc)
	@echo "Patching OCP Network Operator..."
	bash scripts/01-patch-cluster.sh

host-net: ## 2. Create VRF and VLAN interfaces on the OCP worker node (Runs via SSH)
	@if [ "$(WORKER_IP)" = "192.168.122.100" ]; then echo "WARNING: Using default WORKER_IP. Pass WORKER_IP=<ip> to override."; fi
	@echo "Setting up Host VRF and VLAN on $(WORKER_IP)..."
	ssh $(SSH_USER)@$(WORKER_IP) 'bash -s' < scripts/02-setup-host-network.sh

tenant-deploy: ## 3. Deploy Tenant Namespace, C-UDN, and FRR Configs (Runs locally via oc)
	@echo "Deploying Tenant Manifests..."
	oc apply -f manifests/01-tenant-namespace.yaml
	oc apply -f manifests/02-cudn.yaml
	oc apply -f manifests/03-frr-config.yaml
	oc apply -f manifests/04-route-advertisements.yaml

router-bridge: ## 4. Setup OVS Bridge and Libvirt Network on Hypervisor (Runs via SSH)
	@echo "Setting up OVS Bridge and Libvirt Network on Hypervisor ($(HYPERVISOR_IP))..."
	ssh $(HYPERVISOR_USER)@$(HYPERVISOR_IP) 'bash -s' < scripts/03-setup-router-bridge.sh

test-pod: ## 5. Deploy the netshoot troubleshooting pod (Runs locally via oc)
	@echo "Deploying netshoot pod to tenant1 namespace..."
	oc apply -f manifests/99-netshoot-pod.yaml
