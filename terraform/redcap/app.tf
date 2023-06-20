resource "azurerm_linux_web_app" "redcap" {
  name                      = "app-redcap-${var.suffix}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  tags                      = var.tags
  service_plan_id           = var.app_service_plan_id
  https_only                = true
  virtual_network_subnet_id = var.subnets["webapp"].id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                               = true
    container_registry_use_managed_identity = true

    application_stack {
      docker_image     = var.redcap_image_path
      docker_image_tag = "latest" # TODO: configurable in production
    }

    default_documents = [
      "index.php",
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "hostingstart.html",
    ]

    dynamic "ip_restriction" {
      for_each = var.debug ? toset([var.deployers_ip]) : []
      content {
        name       = "AllowClientIP"
        action     = "Allow"
        priority   = "050"
        ip_address = "${ip_restriction.value}/32"
      }
    }
  }

  app_settings = {
    "StorageContainerName"                            = "redcap" # Created automatically
    "StorageAccount"                                  = azurerm_storage_account.redcap.name
    "StorageKey"                                      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.all["storage-account-key"].id})"
    "DBHostName"                                      = azurerm_mysql_flexible_server.redcap.fqdn
    "DBName"                                          = local.mysql_database_name
    "DBUserName"                                      = local.mysql_admin_username
    "DBPassword"                                      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.all["mysql-password"].id})"
    "DBSslCa"                                         = "/home/site/wwwroot/DigiCertGlobalRootCA.crt.pem"
    "PHP_INI_SCAN_DIR"                                = "/usr/local/etc/php/conf.d:/home/site"
    "fromEmailAddress"                                = "NOT_USED"
    "smtpFQDN"                                        = "NOT_USED"
    "smtpPort"                                        = "NOT_USED"
    "smtpUsername"                                    = "NOT_USED"
    "smtpPassword"                                    = "NOT_USED"
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = data.azurerm_application_insights.redcap.instrumentation_key
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"           = data.azurerm_application_insights.redcap.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~2"
    "DiagnosticServices_EXTENSION_VERSION"            = "~3"
    "PORT"                                            = 8080
    "WEBSITES_PORT"                                   = 8080
    "WEBSITES_CONTAINER_START_TIME_LIMIT"             = 1000 # seconds
    "InstrumentationEngine_EXTENSION_VERSION"         = "disabled"
    "SnapshotDebugger_EXTENSION_VERSION"              = "disabled"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "disabled"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
    "XDT_MicrosoftApplicationInsights_PreemptSdk"     = "disabled"
    # "WEBSITE_VNET_ROUTE_ALL"                          = "1"
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100 # range is between 25-100
      }
    }
  }

  depends_on = [
    azurerm_key_vault_secret.all
  ]
}

resource "azurerm_role_assignment" "webapp_can_pull_images" {
  role_definition_name = "AcrPull"
  scope                = var.acr_id
  principal_id         = azurerm_linux_web_app.redcap.identity[0].principal_id
}

resource "azurerm_role_assignment" "webapp_can_read_secrets" {
  #for_each             = azurerm_key_vault_secret.all
  role_definition_name = "Key Vault Secrets User"
  #scope                = each.value.resource_id    # doesn't work??
  scope        = data.azurerm_key_vault.redcap.id
  principal_id = azurerm_linux_web_app.redcap.identity[0].principal_id
}
