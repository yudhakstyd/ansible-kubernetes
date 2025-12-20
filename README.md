# Ansible Kubernetes Cluster Setup

Automated Kubernetes cluster deployment using Ansible.

## 📋 Prerequisites

- Ubuntu 20.04/22.04 LTS servers
- Ansible 2.9+ installed on control machine
- SSH access to all nodes with root privileges
- Minimum 2 CPU cores and 2GB RAM per node

## 🏗️ Infrastructure

- **Master Node**: 172.16.250.9
- **Worker Nodes**: 
  - workernode1: 172.16.250.10
  - workernode2: 172.16.250.11
  - workernode3: 172.16.250.12

## 🚀 Quick Start

### 1. Configure Inventory

Edit `inventory/hosts.ini` with your server IPs:

```ini
[master]
masternode ansible_host=<MASTER_IP> ansible_user=root

[workers]
workernode1 ansible_host=<WORKER1_IP> ansible_user=root
workernode2 ansible_host=<WORKER2_IP> ansible_user=root
```

### 2. Set Vault Password

**Option A: Create vault password file (easier for automation)**

```bash
echo 'your_vault_password' > .vault_pass
chmod 600 .vault_pass
```

Then use:
```bash
./deploy-with-vault-file.sh
```

**Option B: Interactive password prompt**

The vault file is already encrypted. When running playbooks, use:
```bash
./deploy.sh  # Will prompt for vault password
```

Or manually:
```bash
ansible-playbook playbooks/setup.yml --ask-vault-pass
```

**Option C: Create new vault password (if you forgot the password)**

```bash
# Decrypt with old password (if you know it)
ansible-vault decrypt vault/root_password.yaml

# Or create new encrypted file
ansible-vault create vault/root_password.yaml
```

Add your root password:

```yaml
ansible_become_pass: your_root_password
```

### 3. Deploy Cluster

Run the complete deployment:

```bash
# Install dependencies and setup all nodes
ansible-playbook playbooks/main.yml

# Initialize master node
ansible-playbook playbooks/kube_master.yml

# Join worker nodes to cluster
ansible-playbook playbooks/kube_workers.yml
```

Or run all at once:

```bash
ansible-playbook playbooks/main.yml && \
ansible-playbook playbooks/kube_master.yml && \
ansible-playbook playbooks/kube_workers.yml
```

## 📦 What Gets Installed

- **Container Runtime**: containerd
- **Kubernetes**: v1.29.x
  - kubelet
  - kubeadm
  - kubectl (master only)
- **Network Plugin**: Calico (Pod network)

## 🔧 Configuration

- **Pod Network CIDR**: 10.244.0.0/16
- **CGroup Driver**: systemd
- **Container Runtime**: containerd

## 📁 Project Structure

```
ansible-kubernetes/
├── ansible.cfg              # Ansible configuration
├── inventory/
│   └── hosts.ini           # Server inventory
├── playbooks/
│   ├── site.yml            # Complete deployment (recommended)
│   ├── setup.yml           # Setup dependencies on all nodes
│   ├── kube_master.yml     # Initialize master node
│   ├── kube_workers.yml    # Join workers to cluster
│   └── main.yml            # Legacy combined playbook
├── roles/
│   ├── common/             # Common system setup
│   ├── containerd/         # Container runtime
│   ├── kubernetes/         # K8s components
│   └── master/             # Master initialization
├── group_vars/
│   ├── all.yml             # Global variables
│   ├── master.yml          # Master-specific vars
│   └── workers.yml         # Worker-specific vars
├── vault/
│   └── root_password.yaml  # Encrypted credentials
├── docs/
│   ├── TROUBLESHOOTING.md  # Troubleshooting guide
│   └── ADVANCED.md         # Advanced configuration
├── deploy.sh               # Quick deployment script
├── verify.sh               # Cluster verification script
├── Makefile                # Make commands
└── CONTRIBUTING.md         # Contribution guidelines
```

## 🚀 Quick Deploy

**Option 1: With vault password file (no prompts)**

```bash
echo 'your_vault_password' > .vault_pass
chmod 600 .vault_pass
./deploy-with-vault-file.sh
```

**Option 2: Interactive (will prompt for password)**

```bash
./deploy.sh
```

**Option 3: Using Make**

```bash
make deploy  # Will prompt for vault password
```

**Option 4: Manual step-by-step**

```bash
ansible-playbook playbooks/site.yml --ask-vault-pass
```

## 🔍 Verification

After deployment, SSH to master node and run:

```bash
kubectl get nodes
kubectl get pods -A
```

Or use the verification script:

```bash
./verify.sh
```

## 📚 Documentation

- [Troubleshooting Guide](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [Advanced Configuration](docs/ADVANCED.md) - Advanced setup options
- [Contributing](CONTRIBUTING.md) - How to contribute
- [Changelog](CHANGELOG.md) - Version history

## 🛠️ Management Commands

### Using Make

```bash
make help      # Show available commands
make setup     # Setup prerequisites
make master    # Initialize master
make workers   # Join workers
make deploy    # Full deployment
make verify    # Check cluster status
```

### Manual Commands

```bash
# Check cluster status
ansible -m shell -a "kubectl get nodes" master

# Get kubeconfig
ansible -m fetch -a "src=/root/.kube/config dest=./kubeconfig flat=yes" master

# Reset cluster (WARNING: destructive)
ansible -m shell -a "kubeadm reset -f" all
```

## 🛠️ Troubleshooting

- **Swap not disabled**: Check `/etc/fstab` for swap entries
- **Network issues**: Verify firewall rules allow port 6443
- **Pod network**: Ensure Calico pods are running

## 📝 Notes

- All nodes will be rebooted during setup
- SWAP will be disabled permanently
- Kubernetes v1.29 stable release is used

## 📄 License

MIT
