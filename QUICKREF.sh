#!/bin/bash
# Quick Reference Commands for Kubernetes Cluster Management

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║           Kubernetes Cluster - Quick Reference                 ║
╚════════════════════════════════════════════════════════════════╝

📦 DEPLOYMENT
─────────────────────────────────────────────────────────────────
  ./deploy.sh                    Quick deployment
  make deploy                    Deploy using Make
  ansible-playbook playbooks/site.yml    Full deployment

🔧 STEP-BY-STEP DEPLOYMENT
─────────────────────────────────────────────────────────────────
  make setup                     Setup prerequisites
  make master                    Initialize master
  make workers                   Join workers

✅ VERIFICATION
─────────────────────────────────────────────────────────────────
  ./verify.sh                    Quick verification
  make verify                    Verify cluster status
  ansible -m shell -a "kubectl get nodes" master

📊 CLUSTER STATUS
─────────────────────────────────────────────────────────────────
  kubectl get nodes -o wide      View all nodes
  kubectl get pods -A            View all pods
  kubectl cluster-info           Cluster information
  kubectl get events -A          View cluster events

🔍 TROUBLESHOOTING
─────────────────────────────────────────────────────────────────
  # Check kubelet
  ansible -m shell -a "systemctl status kubelet" all
  
  # Check containerd
  ansible -m shell -a "systemctl status containerd" all
  
  # View logs
  ansible -m shell -a "journalctl -u kubelet -n 50" <node>
  
  # Describe node
  kubectl describe node <node-name>

🔄 RESTART SERVICES
─────────────────────────────────────────────────────────────────
  ansible -m shell -a "systemctl restart kubelet" all
  ansible -m shell -a "systemctl restart containerd" all

📝 CONFIGURATION
─────────────────────────────────────────────────────────────────
  Edit inventory:        vim inventory/hosts.ini
  Edit variables:        vim group_vars/all.yml
  Edit vault:            ansible-vault edit vault/root_password.yaml

🗑️  RESET CLUSTER (⚠️  DESTRUCTIVE)
─────────────────────────────────────────────────────────────────
  make clean                     Reset using Make
  ansible -m shell -a "kubeadm reset -f" all

📖 DOCUMENTATION
─────────────────────────────────────────────────────────────────
  cat README.md                  Main documentation
  cat STRUCTURE.md               Project structure
  cat docs/TROUBLESHOOTING.md    Troubleshooting guide
  cat docs/ADVANCED.md           Advanced configuration

🔐 VAULT MANAGEMENT
─────────────────────────────────────────────────────────────────
  ansible-vault create vault/root_password.yaml    Create
  ansible-vault edit vault/root_password.yaml      Edit
  ansible-vault view vault/root_password.yaml      View

🌐 NETWORKING
─────────────────────────────────────────────────────────────────
  kubectl get pods -n calico-system      Calico pods
  kubectl get pods -n tigera-operator    Tigera operator
  kubectl get networkpolicies -A         Network policies

💾 BACKUP
─────────────────────────────────────────────────────────────────
  # Get kubeconfig
  ansible -m fetch -a "src=/root/.kube/config dest=./kubeconfig flat=yes" master
  
  # Backup etcd (run on master)
  ETCDCTL_API=3 etcdctl snapshot save backup.db \\
    --endpoints=https://127.0.0.1:2379 \\
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \\
    --cert=/etc/kubernetes/pki/etcd/server.crt \\
    --key=/etc/kubernetes/pki/etcd/server.key

🎯 COMMON TASKS
─────────────────────────────────────────────────────────────────
  # Add new worker
  ansible-playbook playbooks/setup.yml --limit new_worker
  ansible-playbook playbooks/kube_workers.yml --limit new_worker
  
  # Drain node
  kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
  
  # Uncordon node
  kubectl uncordon <node>
  
  # Delete node
  kubectl delete node <node>

📱 MONITORING
─────────────────────────────────────────────────────────────────
  kubectl top nodes                  Node resource usage
  kubectl top pods -A                Pod resource usage
  kubectl get events --sort-by='.lastTimestamp' -A

🔗 USEFUL ALIASES (add to ~/.bashrc)
─────────────────────────────────────────────────────────────────
  alias k='kubectl'
  alias kgn='kubectl get nodes -o wide'
  alias kgp='kubectl get pods -A'
  alias kgs='kubectl get svc -A'
  alias kd='kubectl describe'

╚════════════════════════════════════════════════════════════════╝
EOF
