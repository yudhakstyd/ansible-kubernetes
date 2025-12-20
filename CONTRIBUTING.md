# Contributing to Ansible Kubernetes

Thank you for your interest in contributing!

## How to Contribute

### Reporting Bugs

- Use GitHub Issues to report bugs
- Describe the bug in detail
- Include steps to reproduce
- Specify your environment (OS, Ansible version, etc.)

### Suggesting Features

- Open an issue with the feature request label
- Describe the feature and its benefits
- Provide examples if possible

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Guidelines

### Code Style

- Follow YAML best practices
- Use 2 spaces for indentation
- Keep tasks descriptive and atomic
- Add comments for complex logic

### Testing

Before submitting:

```bash
# Check syntax
ansible-playbook --syntax-check playbooks/*.yml

# Run in check mode
ansible-playbook playbooks/setup.yml --check

# Test on a development environment first
```

### Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests

## Project Structure

```
ansible-kubernetes/
├── roles/              # Ansible roles
│   ├── common/        # Common setup tasks
│   ├── containerd/    # Container runtime
│   ├── kubernetes/    # K8s installation
│   └── master/        # Master node setup
├── playbooks/         # Playbook files
├── inventory/         # Inventory files
├── group_vars/        # Group variables
└── vault/            # Encrypted secrets
```

## Questions?

Feel free to open an issue for any questions!
