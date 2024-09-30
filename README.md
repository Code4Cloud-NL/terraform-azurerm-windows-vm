<!-- BEGIN_TF_DOCS -->
# Azure Windows Virtual Machine (VM) module

This module simplifies the creation of one or more Windows virtual machines (VM) in Azure. It is designed to be flexible, modular, and easy to use, ensuring a seamless and secure VM deployment experience.

# Features

Creates one or more Windows VM in Azure with the following (optional) features:

- The option to add the VM to a new availability set (created from within this module) using the 'var.availability_set.enabled' variable.
- The option to configure the (optional) availability set using the 'var.availability_set' variable.
- The option to install the Azure Monitor Agent via the 'var.azure_monitor_agent' variable.
- The option to connect the Azure Monitor Agent to an existing log analytic workspace via the 'var.azure_monitor_agent.audit' variable.
- The option to change the source image reference using the 'var.source_image_reference' variable (defaults to Windows Server 2022 Datacenter Azure Edition).
- The option to change VM specific configuration using the 'var.virtual_machines' variable.
- The option to add one or more data disks to each separate VM using the option: data_disks.
- The option to join the VM to an Active Directory (AD) domain using the 'var.ad_domain_join' and 'var.ad_domain_join_account' variables.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_availability_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |
| [azurerm_managed_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_monitor_data_collection_rule.audit](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_data_collection_rule_association.audit](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule_association) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_machine_data_disk_attachment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.ad_domain_join](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.azure_monitor_agent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ad_domain_join"></a> [ad\_domain\_join](#input\_ad\_domain\_join) | Optional variable to join the windows virtual machines to an active directory domain. | <pre>object({<br>    domain_name = string<br>    ou_path     = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_ad_domain_join_account"></a> [ad\_domain\_join\_account](#input\_ad\_domain\_join\_account) | The user account with permissions to add computers to the active directory domain. | <pre>object({<br>    username = string<br>    password = string<br>  })</pre> | `null` | no |
| <a name="input_availability_set"></a> [availability\_set](#input\_availability\_set) | Optional variable to adjust the configuration of the azurerm\_availability\_set resource. | <pre>object({<br>    platform_fault_domain_count  = optional(number, 2)<br>    platform_update_domain_count = optional(number, 5)<br>    managed                      = optional(bool, true)<br>    instance                     = optional(string, "001")<br>  })</pre> | `null` | no |
| <a name="input_azure_monitor_agent"></a> [azure\_monitor\_agent](#input\_azure\_monitor\_agent) | value | <pre>object({<br>    audit_workspace = optional(object({<br>      id       = string<br>      instance = optional(string, "001")<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_general"></a> [general](#input\_general) | General configuration used for naming resources, location etc. | <pre>object({<br>    prefix      = string<br>    environment = string<br>    location    = string<br>    resource_group = object({<br>      name = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_local_administrator"></a> [local\_administrator](#input\_local\_administrator) | Local administrator account used for created virtual machines. | <pre>object({<br>    username = string<br>    password = string<br>  })</pre> | n/a | yes |
| <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference) | The source image reference. Defaults to the latest version of Windows Server 2022 Datacenter Azure Edition. | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | <pre>{<br>  "offer": "WindowsServer",<br>  "publisher": "MicrosoftWindowsServer",<br>  "sku": "2022-datacenter-azure-edition",<br>  "version": "latest"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags that will be applied once during the creation of the resources. | `map(string)` | `{}` | no |
| <a name="input_user_assigned_identity"></a> [user\_assigned\_identity](#input\_user\_assigned\_identity) | Optional variable to change the instance on the user-assigned identity resource. | <pre>object({<br>    instance = string<br>  })</pre> | <pre>{<br>  "instance": "001"<br>}</pre> | no |
| <a name="input_virtual_machine_collection_name"></a> [virtual\_machine\_collection\_name](#input\_virtual\_machine\_collection\_name) | The name for the virtual machine collection created by this module. Used in naming of shared resources (e.g. availability set, log analytics workspace etc.). | `string` | n/a | yes |
| <a name="input_virtual_machines"></a> [virtual\_machines](#input\_virtual\_machines) | Variable for creating one or multiple windows virtual machines. | <pre>list(object({<br>    name                 = string<br>    size                 = string<br>    os_disk_caching      = optional(string, "ReadWrite")<br>    storage_account_type = optional(string, "StandardSSD_LRS")<br>    disk_size_gb         = optional(number, null)<br>    subnet = object({<br>      id = string<br>    })<br>    dns_servers                                            = optional(list(string), [])<br>    proximity_placement_group_id                           = optional(string, null)<br>    secure_boot_enabled                                    = optional(bool, false)<br>    vtpm_enabled                                           = optional(bool, false)<br>    timezone                                               = optional(string, "W. Europe Standard Time")<br>    boot_diagnostics_storage_account_uri                   = optional(string, null)<br>    patch_assessment_mode                                  = optional(string, "AutomaticByPlatform")<br>    patch_mode                                             = optional(string, "AutomaticByPlatform")<br>    provision_vm_agent                                     = optional(bool, true)<br>    bypass_platform_safety_checks_on_user_schedule_enabled = optional(bool, true)<br>    data_disks = optional(list(object({<br>      name                 = string<br>      disk_size_gb         = number<br>      lun                  = number<br>      caching              = optional(string, "ReadWrite")<br>      storage_account_type = optional(string, "StandardSSD_LRS")<br>    })), [])<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_availability_set"></a> [azurerm\_availability\_set](#output\_azurerm\_availability\_set) | n/a |
| <a name="output_azurerm_network_interface"></a> [azurerm\_network\_interface](#output\_azurerm\_network\_interface) | n/a |
| <a name="output_azurerm_windows_virtual_machine"></a> [azurerm\_windows\_virtual\_machine](#output\_azurerm\_windows\_virtual\_machine) | n/a |

## Example(s)

### 1 VM with basic configuration
```hcl
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
```

 ### 1 VM with joined to an active directory domain
```hcl
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

  ad_domain_join = {                            # (optional) join the virtual machine(s) to an active directory (ad) domain
    domain_name = "example.nl"                  # (required) domain name
    ou_path     = "OU=Servers,DC=example,DC=nl" # (optional) ou path for the computer object
  }

  ad_domain_join_account = {                       # (required when ad_domain_join is used) the functional account with permissions to perform domain join
    username = "exampleadmin"                      # (required) username
    password = var.AD_DOMAIN_JOIN_ACCOUNT_PASSWORD # (required) password
  }

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
```

### 2 VM within an availability set

```hcl
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
```

### 1 VM with datadisks

```hcl
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

  virtual_machines = [
    {
      name   = "c4c-mgt-01"                   # (required) name for the virtual machine
      size   = "Standard_D4ds_v5"             # (required) size for the virtual machine
      subnet = data.azurerm_subnet.example.id # (required) subnet for the virtual machine
      data_disk = [                           # (optional) add one or more data disk(s) to the virtual machine
        {
          name         = "data" # (required) name for the data disk
          lun          = 1      # (required) lun for the data disk
          disk_size_gb = 20     # size for the data disk
        }
      ]
    }
  ]

  local_administrator = {                       # (required) local administrator account for the virtual machine(s)
    username = "c4c-admin"                      # (required) username
    password = var.LOCAL_ADMINISTRATOR_PASSWORD # (required) password
  }
}
```

### 1 VM with Azure Monitor Agent enabled

```hcl
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

  azure_monitor_agent = {                                             # (optional) install the azure monitor agent and enable monitoring to sentinel
    audit_workspace = data.azurerm_log_analytics_workspace.example.id # the log analytic workspace to stream data to
  }

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
```

# Known issues and limitations

No known issues or limitations.

# Author

Stefan Vonk (vonk.stefan@live.nl) Technical Specialist
<!-- END_TF_DOCS -->