# Advanced Configuration

## Custom Pod Network CIDR

Edit `group_vars/all.yml`:

```yaml
pod_network_cidr: "192.168.0.0/16"  # Change to your preferred CIDR
```

## High Availability Setup

For HA master nodes, modify inventory:

```ini
[master]
master1 ansible_host=<IP1> ansible_user=root
master2 ansible_host=<IP2> ansible_user=root
master3 ansible_host=<IP3> ansible_user=root

[master:vars]
loadbalancer_apiserver_address=<LB_IP>
loadbalancer_apiserver_port=6443
```

## Custom Kubernetes Version

Edit `group_vars/all.yml`:

```yaml
kubernetes_version: "1.28"  # Change version
```

Update repositories in `roles/kubernetes/tasks/main.yml`.

## Resource Reservations

Adjust in `roles/master/tasks/main.yml`:

```yaml
systemReserved:
  cpu: 200m      # Increase for larger nodes
  memory: 512M
kubeReserved:
  cpu: 200m
  memory: 100M
```

## Alternative CNI Plugins

### Flannel

Replace Calico with Flannel in `roles/master/tasks/main.yml`:

```yaml
- name: Install Flannel
  shell: |
    kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### Cilium

```yaml
- name: Install Cilium
  shell: |
    kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/v1.14/install/kubernetes/quick-install.yaml
```

## Storage Classes

### NFS Storage Class

Create `storage-nfs.yml`:

```yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-storage
provisioner: kubernetes.io/nfs
parameters:
  server: <NFS_SERVER_IP>
  path: /exported/path
```

### Local Path Provisioner

```yaml
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
```

## Ingress Controller

### NGINX Ingress

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/baremetal/deploy.yaml
```

### Traefik

```bash
helm repo add traefik https://traefik.github.io/charts
helm install traefik traefik/traefik
```

## Monitoring Stack

### Prometheus & Grafana

Create `monitoring-stack.yml`:

```yaml
---
- name: Install Prometheus Operator
  hosts: master
  tasks:
    - name: Add Helm repo
      shell: |
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo update

    - name: Install kube-prometheus-stack
      shell: |
        helm install prometheus prometheus-community/kube-prometheus-stack \
          --namespace monitoring --create-namespace
```

## Security Hardening

### Network Policies

Enable in `group_vars/all.yml`:

```yaml
network_policy_enabled: true
```

### Pod Security Policies

Create policies in `security/psp.yml`:

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  # ... additional restrictions
```

## Multi-Tenancy

### Namespaces

```bash
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace prod
```

### Resource Quotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: dev
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    persistentvolumeclaims: "10"
```

## Backup & Restore

### etcd Backup

Add to playbooks:

```yaml
- name: Backup etcd
  hosts: master
  tasks:
    - name: Create etcd snapshot
      shell: |
        ETCDCTL_API=3 etcdctl snapshot save /backup/etcd-$(date +%Y%m%d).db \
          --endpoints=https://127.0.0.1:2379 \
          --cacert=/etc/kubernetes/pki/etcd/ca.crt \
          --cert=/etc/kubernetes/pki/etcd/server.crt \
          --key=/etc/kubernetes/pki/etcd/server.key
```

### Velero for Application Backup

```bash
kubectl apply -f https://github.com/vmware-tanzu/velero/releases/download/v1.12.0/velero-v1.12.0-linux-amd64.tar.gz
```

## Auto-scaling

### Cluster Autoscaler

Requires cloud provider support.

### Metrics Server

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```
