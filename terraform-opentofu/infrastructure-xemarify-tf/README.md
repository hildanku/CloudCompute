# Infrastructure for Xemarify Testing

This directory contains OpenTofu configuration for provisioning test VMs on DigitalOcean.

## Architecture

- **1 App Server**: Manager API + Web UI + PostgreSQL Database (1 vCPU, 1GB RAM)
- **2 Agent VMs**: For testing agents (1 vCPU, 512MB RAM each)

## Prerequisites

1. DigitalOcean API token
2. OpenTofu installed
3. SSH key pair

## Setup

1. Copy `terraform.tfvars.example` to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your DigitalOcean API token and other settings

3. Initialize OpenTofu:
   ```bash
   tofu init
   ```

4. Preview the changes:
   ```bash
   tofu plan
   ```

5. Apply the changes:
   ```bash
   tofu apply
   ```

## Connecting to the VMs

After applying, connect using:

```bash
# App Server
ssh root@$(tofu output -raw app_server_public_ip)

# Agent 1
ssh root@$(tofu output -raw agent_public_ips | jq -r '.[0]')

# Agent 2
ssh root@$(tofu output -raw agent_public_ips | jq -r '.[1]')
```

Or use the SSH commands output:
```bash
tofu output ssh_commands
```

## Accessing Services

- Manager API: `http://$(tofu output -raw app_server_public_ip):8089`
- Web Interface: `http://$(tofu output -raw app_server_public_ip):3000`

## Firewall Rules

**App Server:**
- SSH (22): Restricted to `ssh_allowed_ips`
- HTTP (80), HTTPS (443): Open
- Manager API (8089): Restricted to `api_allowed_ips`
- Web UI (3000): Restricted to `web_allowed_ips`
- PostgreSQL (5432): Only accessible from Agent VMs (private network)

**Agent VMs:**
- SSH (22): Restricted to `ssh_allowed_ips`
- All outbound: Open

## Cleanup

To destroy all resources:

```bash
tofu destroy
```

## Security Notes

- Restrict SSH access to your IP only in production
- Database is only accessible from Agent VMs via private network