# Ansible (SSM + Dynamic Inventory)

```bash
ansible-galaxy collection install -r ansible/collections/requirements.yml

ansible-inventory --graph

# Ping all discovered hosts over SSM
ansible -m ping all
ansible-playbook ansible/playbooks/ping.yml

# Check Dependency
ansible-playbook ansible/playbooks/dependency_check.yml
```
