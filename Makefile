---
# Makefile for Kubernetes cluster management

.PHONY: help setup master workers deploy verify clean

help:
	@echo "Available targets:"
	@echo "  setup    - Install prerequisites on all nodes"
	@echo "  master   - Initialize master node"
	@echo "  workers  - Join worker nodes to cluster"
	@echo "  deploy   - Complete cluster deployment (setup + master + workers)"
	@echo "  verify   - Verify cluster status"
	@echo "  clean    - Reset cluster (WARNING: destructive)"
	@echo ""
	@echo "NOTE: All commands will prompt for vault password"
	@echo "To avoid prompts, create .vault_pass file and use:"
	@echo "  make deploy-auto (or setup-auto, master-auto, workers-auto)"

setup:
	ansible-playbook playbooks/setup.yml --ask-vault-pass

setup-auto:
	ansible-playbook playbooks/setup.yml --vault-password-file .vault_pass

master:
	ansible-playbook playbooks/kube_master.yml --ask-vault-pass

master-auto:
	ansible-playbook playbooks/kube_master.yml --vault-password-file .vault_pass

workers:
	ansible-playbook playbooks/kube_workers.yml --ask-vault-pass

workers-auto:
	ansible-playbook playbooks/kube_workers.yml --vault-password-file .vault_pass

deploy:
	ansible-playbook playbooks/site.yml --ask-vault-pass

deploy-auto:
	ansible-playbook playbooks/site.yml --vault-password-file .vault_pass

verify:
	ansible -m shell -a "kubectl get nodes" master

clean:
	@echo "This will destroy the cluster. Press Ctrl+C to cancel."
	@sleep 5
	ansible -m shell -a "kubeadm reset -f" all
	ansible -m shell -a "rm -rf /etc/kubernetes /var/lib/kubelet /var/lib/etcd ~/.kube" all
