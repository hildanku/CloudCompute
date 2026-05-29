variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "xemarify"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "sgp1"
}

variable "app_server_size" {
  description = "App server droplet size"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "agent_size" {
  description = "Agent droplet size"
  type        = string
  default     = "s-1vcpu-512mb-10gb"
}

variable "agent_count" {
  description = "Number of agent VMs"
  type        = number
  default     = 2
}

variable "droplet_image" {
  description = "Droplet image"
  type        = string
  default     = "ubuntu-22-04-x64"
}

variable "ssh_allowed_ips" {
  description = "IP addresses allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "api_allowed_ips" {
  description = "IP addresses allowed to access the API"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "web_allowed_ips" {
  description = "IP addresses allowed to access the web interface"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}