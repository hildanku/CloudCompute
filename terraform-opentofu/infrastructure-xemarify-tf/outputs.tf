output "app_server_id" {
  description = "ID of the app server"
  value       = digitalocean_droplet.app_server.id
}

output "app_server_public_ip" {
  description = "Public IP address of the app server"
  value       = digitalocean_droplet.app_server.ipv4_address
}

output "app_server_private_ip" {
  description = "Private IP address of the app server"
  value       = digitalocean_droplet.app_server.ipv4_address_private
}

output "agent_ids" {
  description = "IDs of the agent VMs"
  value       = [for agent in digitalocean_droplet.agent : agent.id]
}

output "agent_public_ips" {
  description = "Public IP addresses of the agent VMs"
  value       = [for agent in digitalocean_droplet.agent : agent.ipv4_address]
}

output "agent_private_ips" {
  description = "Private IP addresses of the agent VMs"
  value       = [for agent in digitalocean_droplet.agent : agent.ipv4_address_private]
}

output "ssh_commands" {
  description = "SSH commands to connect to the VMs"
  value = {
    app_server = "ssh root@${digitalocean_droplet.app_server.ipv4_address}"
    agents     = [for agent in digitalocean_droplet.agent : "ssh root@${agent.ipv4_address}"]
  }
}

output "service_urls" {
  description = "Service URLs"
  value = {
    manager_api = "http://${digitalocean_droplet.app_server.ipv4_address}:8089"
    web         = "http://${digitalocean_droplet.app_server.ipv4_address}:3000"
  }
}

output "database_connection" {
  description = "Database connection string (for app server local use)"
  value       = "postgresql://xemarify_manager:change-me-db-password@localhost:5432/xemarify_manager"
  sensitive   = true
}