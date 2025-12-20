#!/bin/bash
# Verify Kubernetes cluster health

echo "Checking cluster status..."
echo ""

echo "=== Nodes ==="
ansible -m shell -a "kubectl get nodes -o wide" master

echo ""
echo "=== System Pods ==="
ansible -m shell -a "kubectl get pods -n kube-system" master

echo ""
echo "=== Calico Pods ==="
ansible -m shell -a "kubectl get pods -n calico-system" master

echo ""
echo "=== Tigera Operator ==="
ansible -m shell -a "kubectl get pods -n tigera-operator" master

echo ""
echo "=== Cluster Info ==="
ansible -m shell -a "kubectl cluster-info" master
