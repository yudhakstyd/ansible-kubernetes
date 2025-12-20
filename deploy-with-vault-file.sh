#!/bin/bash
# Alternative deployment script using vault password file

set -e

echo "================================================"
echo " Kubernetes Cluster Deployment (Vault File)"
echo "================================================"
echo ""

# Check if ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "ERROR: Ansible is not installed"
    exit 1
fi

# Check if vault password file exists
if [ ! -f .vault_pass ]; then
    echo "ERROR: .vault_pass file not found"
    echo ""
    echo "Please create .vault_pass file with your vault password:"
    echo "  echo 'your_vault_password' > .vault_pass"
    echo "  chmod 600 .vault_pass"
    echo ""
    echo "Or use deploy.sh which will prompt for password interactively"
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
ansible-playbook playbooks/setup.yml --vault-password-file .vault_pass || { echo "Failed at setup stage"; exit 1; }

# Step 2: Initialize master
echo ""
echo "Step 2/3: Initializing master node..."
ansible-playbook playbooks/kube_master.yml --vault-password-file .vault_pass || { echo "Failed at master initialization"; exit 1; }

# Step 3: Join workers
echo ""
echo "Step 3/3: Joining worker nodes..."
ansible-playbook playbooks/kube_workers.yml --vault-password-file .vault_pass || { echo "Failed at worker join stage"; exit 1; }

echo ""
echo "================================================"
echo " Deployment Complete!"
echo "================================================"
echo ""
echo "To verify cluster status, run:"
echo "  ansible -m shell -a 'kubectl get nodes' master"
echo ""
