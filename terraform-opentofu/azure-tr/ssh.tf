resource "random_pet" "langlang" {
  prefix    = "langlang"
  separator = ""
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = random_pet.langlang.id
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id

  body = jsonencode({
    properties = {}
  })

  depends_on = [azurerm_resource_group.rg]
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

# Save to local file
resource "local_file" "private_key" {
  content         = azapi_resource_action.ssh_public_key_gen.output.privateKey
  filename        = "${path.module}/id_${random_pet.langlang.id}"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = azapi_resource_action.ssh_public_key_gen.output.publicKey
  filename        = "${path.module}/id_${random_pet.langlang.id}.pub"
  file_permission = "0644"
}

output "ssh_public_key" {
  value = azapi_resource_action.ssh_public_key_gen.output.publicKey
}

output "private_key_path" {
  value     = local_file.private_key.filename
  sensitive = true
}
