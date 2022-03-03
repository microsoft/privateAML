data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

# Random unique id
resource "random_string" "unique_id" {
  length      = 4
  min_numeric = 4
}

# locals {
#  name = lower(replace("${var.name}${random_string.unique_id.result}", "-", ""))
# }

locals {
  name = var.name
}