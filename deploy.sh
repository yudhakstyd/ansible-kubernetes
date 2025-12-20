#!/bin/bash
# Quick deployment script for Kubernetes cluster

set -e

echo "================================================"
echo " Kubernetes Cluster Deployment"
echo "================================================"
echo ""

# Check if ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "ERROR: Ansible is not installed"
    exit 1
fi

# Check if vault password file exists
if [ ! -f vault/root_password.yaml ]; then
    echo "ERROR: vault/root_password.yaml not found"
    echo "Please create it with: ansible-vault create vault/root_password.yaml"
    exit 1
fi

# Check inventory
if [ ! -f inventory/hosts.ini ]; then
    echo "ERROR: inventory/hosts.ini not found"
    exit 1
fi

echo "Starting deployment..."
echo ""

# Step 1: Setup prerequisites
echo "Step 1/3: Setting up prerequisites on all nodes..."
ansible-playbook playbooks/setup.yml --ask-vault-pass || { echo "Failed at setup stage"; exit 1; }

# Step 2: Initialize master
echo ""
echo "Step 2/3: Initializing master node..."
ansible-playbook playbooks/kube_master.yml --ask-vault-pass || { echo "Failed at master initialization"; exit 1; }

# Step 3: Join workers
echo ""
echo "Step 3/3: Joining worker nodes..."
ansible-playbook playbooks/kube_workers.yml --ask-vault-pass || { echo "Failed at worker join stage"; exit 1; }

echo ""
echo "================================================"
echo " Deployment Complete!"
echo "================================================"
echo ""
echo "To verify cluster status, run:"
echo "  ansible -m shell -a 'kubectl get nodes' master"
echo ""
