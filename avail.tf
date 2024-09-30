# availability set
resource "azurerm_availability_set" "this" {
  count = var.availability_set != null ? 1 : 0

  name                         = "${var.general.prefix}-avail-${var.virtual_machine_collection_name}-${local.suffix}-${var.availability_set.instance}"
  location                     = var.general.location
  resource_group_name          = var.general.resource_group.name
  tags                         = var.tags
  platform_update_domain_count = var.availability_set.platform_update_domain_count
  platform_fault_domain_count  = var.availability_set.platform_fault_domain_count
  managed                      = var.availability_set.managed

  lifecycle { ignore_changes = [tags] }
}
