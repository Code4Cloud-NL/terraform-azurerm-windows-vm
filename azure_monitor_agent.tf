# user-assigned managed identity
resource "azurerm_user_assigned_identity" "this" {
  count = var.azure_monitor_agent != null ? 1 : 0

  name                = "${var.general.prefix}-id-${var.virtual_machine_collection_name}-vm-${local.suffix}-${var.user_assigned_identity.instance}"
  location            = var.general.location
  resource_group_name = var.general.resource_group.name
  tags                = var.tags
}

# azure monitor agent
resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  for_each = { for vm in var.virtual_machines : vm.name => vm if var.azure_monitor_agent != null }

  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[each.key].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = "true"
  tags                       = var.tags
  settings = jsonencode({
    "authentication" : {
      "managedIdentity" : {
        "identifier-name" : "mi_res_id",
        "identifier-value" : azurerm_user_assigned_identity.this[0].id
      }
    }
  })
}

# audit data collection rule
resource "azurerm_monitor_data_collection_rule" "audit" {
  count = try(var.azure_monitor_agent.audit_workspace, null) != null ? 1 : 0

  name                = "${var.general.prefix}-dcr-${var.virtual_machine_collection_name}-audit-${local.suffix}-${var.azure_monitor_agent.audit_workspace.instance}"
  location            = var.general.location
  resource_group_name = var.general.resource_group.name
  tags                = var.tags

  destinations {
    log_analytics {
      name                  = "log-analytics"
      workspace_resource_id = var.azure_monitor_agent.audit_workspace.id
    }
  }

  data_flow {
    streams      = ["Microsoft-Event", "Microsoft-SecurityEvent"]
    destinations = ["log-analytics"]
  }

  data_sources {
    windows_event_log {
      name    = "eventLogsDataSource"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
        "System!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
    }

    windows_event_log {
      name    = "SecurityEventLogsDataSource"
      streams = ["Microsoft-SecurityEvent"]
      x_path_queries = [
        "Security!*[System[(band(Keywords,13510798882111488))]]",
      ]
    }
  }
}

# audit data collection rule association
resource "azurerm_monitor_data_collection_rule_association" "audit" {
  for_each = { for vm in var.virtual_machines : vm.name => vm if try(var.azure_monitor_agent.audit_workspace, null) != null }

  name                    = "${var.general.prefix}-dcr-${var.virtual_machine_collection_name}-${each.key}-${local.suffix}-${var.azure_monitor_agent.audit_workspace.instance}"
  target_resource_id      = azurerm_windows_virtual_machine.this[each.key].id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.audit[0].id
}

