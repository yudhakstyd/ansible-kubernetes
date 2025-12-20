# Troubleshooting Guide

## Common Issues and Solutions

### 1. Swap Not Disabled

**Symptom**: Kubelet fails to start

**Solution**:
```bash
# Verify swap is off
ansible -m shell -a "swapon -s" all

# If swap is still on
ansible -m shell -a "swapoff -a" all
ansible -m shell -a "sed -i '/ swap / s/^/#/' /etc/fstab" all
```

### 2. Port 6443 Not Accessible

**Symptom**: Workers cannot join cluster

**Solution**:
```bash
# Check firewall on master
ansible -m shell -a "ufw status" master

# Allow port if needed
ansible -m shell -a "ufw allow 6443/tcp" master

# Verify connectivity from worker
ansible -m shell -a "nc -zv <master_ip> 6443" workers
```

### 3. Pod Network Not Ready

**Symptom**: Pods stuck in pending state

**Solution**:
```bash
# Check Calico pods
kubectl get pods -n calico-system
kubectl get pods -n tigera-operator

# Restart Calico if needed
kubectl delete pods -n calico-system --all
```

### 4. Node Not Ready

**Symptom**: Node status shows NotReady

**Solution**:
```bash
# Check node details
kubectl describe node <node-name>

# Check kubelet status
ansible -m shell -a "systemctl status kubelet" <node>

# View kubelet logs
ansible -m shell -a "journalctl -u kubelet -n 50" <node>

# Restart kubelet
ansible -m shell -a "systemctl restart kubelet" <node>
```

### 5. Container Runtime Issues

**Symptom**: Containers not starting

**Solution**:
```bash
# Check containerd status
ansible -m shell -a "systemctl status containerd" all

# Restart containerd
ansible -m shell -a "systemctl restart containerd" all

# Check containerd logs
ansible -m shell -a "journalctl -u containerd -n 50" all
```

### 6. Token Expired

**Symptom**: Cannot join new workers

**Solution**:
```bash
# Generate new token on master
kubeadm token create --print-join-command

# Use the output to manually join worker
```

### 7. DNS Not Working

**Symptom**: Pods cannot resolve names

**Solution**:
```bash
# Check CoreDNS pods
kubectl get pods -n kube-system | grep coredns

# Restart CoreDNS
kubectl delete pods -n kube-system -l k8s-app=kube-dns

# Test DNS
kubectl run test --image=busybox --rm -it -- nslookup kubernetes.default
```

### 8. Disk Pressure

**Symptom**: Pods being evicted

**Solution**:
```bash
# Check disk usage
ansible -m shell -a "df -h" all

# Clean up Docker/containerd
ansible -m shell -a "crictl rmi --prune" all

# Remove old logs
ansible -m shell -a "journalctl --vacuum-time=3d" all
```

## Debugging Commands

### Cluster Status
```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl cluster-info
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

### Node Diagnostics
```bash
kubectl describe node <node-name>
kubectl top nodes
```

### Pod Diagnostics
```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
```

### Component Logs
```bash
# Kubelet
journalctl -u kubelet -f

# Containerd
journalctl -u containerd -f

# API Server
kubectl logs -n kube-system kube-apiserver-<master-node>
```

## Reset Cluster

If all else fails, reset and redeploy:

```bash
# Reset cluster
ansible -m shell -a "kubeadm reset -f" all

# Clean up
ansible -m shell -a "rm -rf /etc/kubernetes /var/lib/kubelet /var/lib/etcd ~/.kube" all
ansible -m shell -a "rm -rf /root/*.log" all

# Redeploy
./deploy.sh
```

## Getting Help

1. Check logs first
2. Search existing issues on GitHub
3. Ask on Kubernetes Slack
4. Open a detailed issue with logs and environment info
