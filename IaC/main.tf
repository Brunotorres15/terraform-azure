# Projeto 3 - Deploy do Stack de Infraestrutura de Dados no Azure com Terraform

# Define um grupo de recursos chamado "projeto_bt"
resource "azurerm_resource_group" "projeto_bt" {
  name     = "Grupo_Recursos_Projeto3"
  location = "West US 2"
}

# Cria uma rede virtual chamada "bt_vnet"
resource "azurerm_virtual_network" "bt_vnet" {
  name                = "vnet_terr_bt"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.projeto_bt.location
  resource_group_name = azurerm_resource_group.projeto_bt.name
}

# Cria a subnet dentro da rede virtual (os recursos de rede ficam na subnet)
resource "azurerm_subnet" "bt_subnet1" {
  name                 = "subnet_terr_bt"
  resource_group_name  = azurerm_resource_group.projeto_bt.name
  virtual_network_name = azurerm_virtual_network.bt_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# A principal diferença entre os dois ranges de ip acima é a escala da rede: 
# "10.0.0.0/16" é uma rede muito maior que abrange todos os endereços IP sob o "10.0.x.x", 
# enquanto "10.0.1.0/24" é uma sub-rede muito menor que inclui apenas os endereços sob "10.0.1.x".

# Cria uma interface de rede para a máquina virtual
resource "azurerm_network_interface" "bt_ni" {
  name                = "ni_terr_bt"
  location            = azurerm_resource_group.projeto_bt.location
  resource_group_name = azurerm_resource_group.projeto_bt.name

  # Configuração de IP para a interface de rede
  ip_configuration {
    name                          = "vm_bt"
    subnet_id                     = azurerm_subnet.bt_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Cria uma máquina virtual Linux
resource "azurerm_linux_virtual_machine" "bt_vm" {
  name                = "vmbt"
  resource_group_name = azurerm_resource_group.projeto_bt.name
  location            = azurerm_resource_group.projeto_bt.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  disable_password_authentication = false
  admin_password      = "" 
  network_interface_ids = [azurerm_network_interface.bt_ni.id]

  # Configurações do disco para o sistema operacional
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Imagem do sistema operacional da máquina virtual
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
