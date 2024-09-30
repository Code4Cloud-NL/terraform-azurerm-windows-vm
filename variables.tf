variable "general" {
  description = "General configuration used for naming resources, location etc."
  type = object({
    prefix      = string
    environment = string
    location    = string
    resource_group = object({
      name = string
    })
  })
  validation {
    condition     = contains(["lab", "stg", "dev", "tst", "acc", "prd"], var.general.environment)
    error_message = "Invalid environment specified!"
  }
  validation {
    condition     = contains(["northeurope", "westeurope"], var.general.location)
    error_message = "Invalid location specified!"
  }
}

variable "virtual_machine_collection_name" {
  description = "The name for the virtual machine collection created by this module. Used in naming of shared resources (e.g. availability set, log analytics workspace etc.)."
  type        = string
}

variable "availability_set" {
  description = "Optional variable to adjust the configuration of the azurerm_availability_set resource."
  type = object({
    platform_fault_domain_count  = optional(number, 2)
    platform_update_domain_count = optional(number, 5)
    managed                      = optional(bool, true)
    instance                     = optional(string, "001")
  })
  default = null
  validation {
    condition = var.availability_set == null ? true : (
      var.availability_set.platform_fault_domain_count <= 3
    )
    error_message = "Fault domain count must be less than 3."
  }
  validation {
    condition = var.availability_set == null ? true : (
      var.availability_set.platform_update_domain_count <= 20
    )
    error_message = "Update domain count must be less than 20."
  }
}

variable "azure_monitor_agent" {
  description = "value"
  type = object({
    audit_workspace = optional(object({
      id       = string
      instance = optional(string, "001")
    }))
  })
  default = null
}

variable "user_assigned_identity" {
  description = "Optional variable to change the instance on the user-assigned identity resource."
  type = object({
    instance = string
  })
  default = {
    instance = "001"
  }
}

variable "virtual_machines" {
  description = "Variable for creating one or multiple windows virtual machines."
  type = list(object({
    name                 = string
    size                 = string
    os_disk_caching      = optional(string, "ReadWrite")
    storage_account_type = optional(string, "StandardSSD_LRS")
    disk_size_gb         = optional(number, null)
    subnet = object({
      id = string
    })
    dns_servers                                            = optional(list(string), [])
    proximity_placement_group_id                           = optional(string, null)
    secure_boot_enabled                                    = optional(bool, false)
    vtpm_enabled                                           = optional(bool, false)
    timezone                                               = optional(string, "W. Europe Standard Time")
    boot_diagnostics_storage_account_uri                   = optional(string, null)
    patch_assessment_mode                                  = optional(string, "AutomaticByPlatform")
    patch_mode                                             = optional(string, "AutomaticByPlatform")
    provision_vm_agent                                     = optional(bool, true)
    bypass_platform_safety_checks_on_user_schedule_enabled = optional(bool, true)
    data_disks = optional(list(object({
      name                 = string
      disk_size_gb         = number
      lun                  = number
      caching              = optional(string, "ReadWrite")
      storage_account_type = optional(string, "StandardSSD_LRS")
    })), [])
  }))
  validation {
    condition = alltrue([
      for vm in var.virtual_machines :
      length(vm.name) <= 15
    ])
    error_message = "Name must not exceed 15 characters."
  }
  validation {
    condition = alltrue([
      for vm in var.virtual_machines :
      contains(["ReadWrite", "ReadOnly", "None"], vm.os_disk_caching)
    ])
    error_message = "Invalid os disk caching type. Possible values are: ReadWrite, ReadOnly, None."
  }
  validation {
    condition = alltrue([
      for vm in var.virtual_machines :
      contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], vm.storage_account_type)
    ])
    error_message = "Invalid storage account type. Possible values are: Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, Premium_ZRS."
  }
  validation {
    condition = alltrue([
      for vm in var.virtual_machines :
      contains(["AutomaticByPlatform", "ImageDefault"], vm.patch_assessment_mode)
    ])
    error_message = "Invalid patch assessment mode. Possible values are: AutomaticByPlatform, ImageDefault."
  }
  validation {
    condition = alltrue([
      for vm in var.virtual_machines :
      contains(["AutomaticByPlatform", "AutomaticByOS", "Manual"], vm.patch_mode)
    ])
    error_message = "Invalid patch mode. Possible values are: AutomaticByPlatform, AutomaticByOS, Manual."
  }
  validation {
    condition = alltrue([
      for vm in var.virtual_machines : alltrue([
        for disk in vm.data_disks :
        contains(["ReadWrite", "ReadOnly", "None"], disk.caching)
      ])
    ])
    error_message = "Invalid data disk caching type. Possible values are: ReadWrite, ReadOnly, None."
  }
  validation {
    condition = alltrue([
      for vm in var.virtual_machines : alltrue([
        for disk in vm.data_disks :
        contains(["Standard_LRS", "StandardSSD_ZRS", "Premium_LRS", "PremiumV2_LRS", "Premium_ZRS", "StandardSSD_LRS", "UltraSSD_LRS"], disk.storage_account_type)
      ])
    ])
    error_message = "Invalid storage account type. Possible values are: Standard_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS, StandardSSD_LRS, UltraSSD_LRS"
  }
}

variable "source_image_reference" {
  description = "The source image reference. Defaults to the latest version of Windows Server 2022 Datacenter Azure Edition."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

variable "local_administrator" {
  description = "Local administrator account used for created virtual machines."
  type = object({
    username = string
    password = string
  })
  sensitive = true
}

variable "ad_domain_join" {
  description = "Optional variable to join the windows virtual machines to an active directory domain."
  type = object({
    domain_name = string
    ou_path     = optional(string)
  })
  default = null
}

variable "ad_domain_join_account" {
  description = "The user account with permissions to add computers to the active directory domain."
  type = object({
    username = string
    password = string
  })
  sensitive = true
  default   = null
}

variable "tags" {
  description = "The tags that will be applied once during the creation of the resources."
  type        = map(string)
  default     = {}
}
