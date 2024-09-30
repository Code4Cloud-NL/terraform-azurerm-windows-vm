module "windows_vm" {
  source = "../modules/terraform-azurerm-windows-vm"

  general = {
    prefix         = "c4c"                                    # (required) the prefix of the customer (e.g. c4c)
    environment    = "prd"                                    # (required) the environment (e.g. lab, stg, dev, tst, acc, prd)
    location       = "westeurope"                             # (required) the location for the resources (e.g. westeurope, northeurope)
    resource_group = data.azurerm_resource_group.example.name # (required) the resource group for the resources (must be set via a module or data source)
  }

  tags = { # (optional) a map of tags applied to the resources
    environment = "prd"
    location    = "westeurope"
    managed_by  = "terraform"
  }

  virtual_machine_collection_name = "management-vms" # (required) the unique name for the virtual machine collection (must be unique within the resource group)

  availability_set = {} # (optional) enable and/or configure the availability set for the virtual machine(s)

  virtual_machines = [ # (required) list of one or more virtual machines
    {
      name   = "c4c-mgt-01"                   # (required) name for the virtual machine
      size   = "Standard_D4ds_v5"             # (required) size for the virtual machine
      subnet = data.azurerm_subnet.example.id # (required) subnet for the virtual machine
    }
  ]

  local_administrator = {                       # (required) local administrator account for the virtual machine(s)
    username = "c4c-admin"                      # (required) username
    password = var.LOCAL_ADMINISTRATOR_PASSWORD # (required) password
  }
}
