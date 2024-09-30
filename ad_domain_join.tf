# active directory domain join
resource "azurerm_virtual_machine_extension" "ad_domain_join" {
  for_each = { for vm in var.virtual_machines : vm.name => vm if var.ad_domain_join != null }

  name                       = "ad_domain_join"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[each.key].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true
  tags                       = var.tags

  settings = <<SETTINGS
    {
        "Name": "${var.ad_domain_join.domain_name}",
        "OUPath": "${var.ad_domain_join.ou_path != null ? var.ad_domain_join.ou_path : ""}",
        "User": "${var.ad_domain_join_account.username}@${var.ad_domain_join.domain_name}",
        "Restart": "true",
        "Options": "3"
    }
  SETTINGS

  protected_settings = <<SETTINGS
    {
        "Password": "${var.ad_domain_join_account.password}"
    }
  SETTINGS
}
