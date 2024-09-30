# network interfaces
resource "azurerm_network_interface" "this" {
  for_each = { for vm in var.virtual_machines : vm.name => vm }

  name                = "${each.value.name}_nic"
  resource_group_name = var.general.resource_group.name
  location            = var.general.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  dns_servers = each.value.dns_servers

  lifecycle { ignore_changes = [tags, ip_configuration[0].private_ip_address_allocation] }
}

# virtual machines
resource "azurerm_windows_virtual_machine" "this" {
  for_each = { for vm in var.virtual_machines : vm.name => vm }

  name                                                   = each.value.name
  resource_group_name                                    = var.general.resource_group.name
  location                                               = var.general.location
  tags                                                   = var.tags
  size                                                   = each.value.size
  admin_username                                         = var.local_administrator.username
  admin_password                                         = var.local_administrator.password
  network_interface_ids                                  = [azurerm_network_interface.this["${each.value.name}"].id]
  availability_set_id                                    = try(azurerm_availability_set.this[0].id, null)
  proximity_placement_group_id                           = each.value.proximity_placement_group_id
  secure_boot_enabled                                    = each.value.secure_boot_enabled
  vtpm_enabled                                           = each.value.vtpm_enabled
  timezone                                               = each.value.timezone
  patch_assessment_mode                                  = each.value.patch_assessment_mode
  patch_mode                                             = each.value.patch_mode
  provision_vm_agent                                     = each.value.provision_vm_agent
  bypass_platform_safety_checks_on_user_schedule_enabled = each.value.bypass_platform_safety_checks_on_user_schedule_enabled

  dynamic "identity" {
    for_each = var.azure_monitor_agent != null ? ["UserAssigned"] : []
    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.this[0].id]
    }
  }

  os_disk {
    name                 = "${each.value.name}_osdisk"
    disk_size_gb         = each.value.disk_size_gb
    caching              = each.value.os_disk_caching
    storage_account_type = each.value.storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  boot_diagnostics {
    storage_account_uri = each.value.boot_diagnostics_storage_account_uri
  }

  lifecycle { ignore_changes = [tags] }
}

locals {
  data_disks = {
    for item in flatten([
      for vm in var.virtual_machines : [
        for disk in vm.data_disks : [
          merge(
            disk,
            {
              vm_name = vm.name
            }
          )
        ]
      ]
    ]) : "${item.vm_name}-${item.name}" => item
  }
}

# managed data disks (optional resource)
resource "azurerm_managed_disk" "this" {
  for_each = local.data_disks

  name                = "${each.value.vm_name}_${each.value.name}_disk"
  resource_group_name = var.general.resource_group.name
  location            = var.general.location
  tags                = var.tags

  disk_size_gb         = each.value.disk_size_gb
  storage_account_type = each.value.storage_account_type
  create_option        = "Empty"
}

# attach managed disks (optional resource)
resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each = local.data_disks

  virtual_machine_id = azurerm_windows_virtual_machine.this[each.value.vm_name].id
  managed_disk_id    = azurerm_managed_disk.this[each.key].id
  lun                = each.value.lun
  caching            = each.value.caching
}
