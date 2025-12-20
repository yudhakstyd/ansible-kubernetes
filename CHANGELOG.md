# CHANGELOG

## Version 2.0 - 2025-12-20

### Major Changes
- Complete restructure with Ansible roles
- Improved playbook organization
- Added comprehensive documentation

### Added
- Role-based architecture (common, containerd, kubernetes, master)
- Group variables for better configuration management
- Makefile for easier deployment
- Deployment and verification scripts
- Enhanced README with detailed instructions
- .gitignore file
- CHANGELOG file

### Improved
- Better error handling and verification steps
- Cleaner YAML formatting
- More descriptive task names
- Added pre_tasks and post_tasks for better flow
- Enhanced ansible.cfg with performance optimizations

### Fixed
- Removed duplicate README content
- Fixed hardcoded IP addresses
- Improved idempotency of tasks
- Better wait conditions for services

## Version 1.0 - Initial Release

### Features
- Basic Kubernetes cluster deployment
- Single master, multiple workers
- Containerd as container runtime
- Calico networking
