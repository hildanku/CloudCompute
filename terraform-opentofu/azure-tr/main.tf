resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "East Asia" # <- i choose East Asia because limitation Azure Student
}

# First create virtual network

resource "azurerm_virtual_network" "wakandaVNet" {
  name                = "wakandaVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#  Then create Subnet

resource "azurerm_subnet" "wakandaSubnet" {
  name                 = "wakandaSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.wakandaVNet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Then Create a public IP

resource "azurerm_public_ip" "wakandaPublicIP" {
  name                = "wakandaPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static" # <- if i set Dynamic option, i got this err
  # Public IP Error
  # Your Azure subscription has reached the limit for Basic SKU public IP addresses (0 allowed)
  # maybe, because my subscription is Azure Student
  sku = "Standard"
}

# Then we create Network Security Group and Rule

resource "azurerm_network_security_group" "wakandaNetworkSecurityGroup" {
  name                = "wakandaNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow SSH
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Then we Create Network Interface

resource "azurerm_network_interface" "wakandaNIC" {
  name                = "wakandaNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.wakandaSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wakandaPublicIP.id
  }
}

# Then Connect Network Security Group to Network Interface

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.wakandaNIC.id
  network_security_group_id = azurerm_network_security_group.wakandaNetworkSecurityGroup.id
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Then Create a Storage Account
resource "azurerm_storage_account" "wakandaStorageAccount" {
  name = "wakanda${random_id.random_id.hex}" # <- if you set like this "wakandaStorageXXXXX"
  # you will get this error:
  # The storage account name is too long and contains uppercase letters
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Finally Create a Virtual Machine

resource "azurerm_linux_virtual_machine" "wakandaVM" {
  name                  = "wakandaVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.wakandaNIC.id]
  size                  = "Standard_B1ms" # <- a very minim vm spec $0.03/Hour or -+ $21/Month (9 September 2025)

  os_disk {
    name                 = "wakandaOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "wakandaVM"
  admin_username = "azureuser"

  admin_ssh_key {
    username   = var.username
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.wakandaStorageAccount.primary_blob_endpoint
  }
}
