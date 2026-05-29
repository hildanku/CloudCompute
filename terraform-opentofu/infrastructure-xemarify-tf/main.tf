terraform {
  required_version = ">= 1.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Create a new SSH key for the droplets
resource "digitalocean_ssh_key" "default" {
  name       = "${var.project_name}-key"
  public_key = file(var.ssh_public_key_path)
}

# App Server (Manager + Web + DB)
resource "digitalocean_droplet" "app_server" {
  name   = "${var.project_name}-app"
  region = var.region
  size   = var.app_server_size
  image  = var.droplet_image

  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  tags = ["app", "xemarify", "skripsi"]

  lifecycle {
    create_before_destroy = true
  }
}

# Agent VMs
resource "digitalocean_droplet" "agent" {
  count  = var.agent_count
  name   = "${var.project_name}-agent-${count.index + 1}"
  region = var.region
  size   = var.agent_size
  image  = var.droplet_image

  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  tags = ["agent", "xemarify", "skripsi"]

  lifecycle {
    create_before_destroy = true
  }
}

# Firewall for App Server
resource "digitalocean_firewall" "app_server" {
  name = "${var.project_name}-app-firewall"

  droplet_ids = [digitalocean_droplet.app_server.id]

  # SSH access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_allowed_ips
  }

  # HTTP access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Manager API port
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8089"
    source_addresses = var.api_allowed_ips
  }

  # Web port
  inbound_rule {
    protocol         = "tcp"
    port_range       = "3000"
    source_addresses = var.web_allowed_ips
  }

  # PostgreSQL port (restrict to agent IPs)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "5432"
    source_addresses = [for agent in digitalocean_droplet.agent : agent.ipv4_address_private]
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Firewall for Agent VMs
resource "digitalocean_firewall" "agents" {
  name = "${var.project_name}-agent-firewall"

  droplet_ids = [for agent in digitalocean_droplet.agent : agent.id]

  # SSH access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_allowed_ips
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}