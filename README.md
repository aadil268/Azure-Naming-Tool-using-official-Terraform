# Azure Naming Tool Implementation with Terraform

This project demonstrates the implementation of the Azure Naming Tool using the official Terraform module (`Azure/naming/azurerm`). It aims to standardize resource names across environments, ensuring compliance and consistency with Azure naming rules and organizational conventions.

## Custom Naming Convention

The naming convention implemented in this project follows the format:

`Resource Type - CCH Project name - Locations - Environments - Custom Instance number`

Examples:
- `rg-sirvis-we-dev-001` (Resource Group for 'sirvis' project, West Europe, Development environment, Instance 001)
- `stsirviswesttst002` (Storage Account for 'sirvis' project, West Europe, Test environment, Instance 002)
- `vnet-sirvis-ne-prd-003` (Virtual Network for 'sirvis' project, North Europe, Production environment, Instance 003)

### Naming Convention Breakdown:

-   **Resource Type**: Default Azure resource naming format (e.g., `rg` for resource group, `vm` for virtual machine, `st` for storage account, `vnet` for virtual network).
-   **CCH Project name**: A variable project name (e.g., `sirvis`).
-   **Locations**: Two-letter code for Azure location (e.g., `ne` for North Europe, `we` for West Europe).
-   **Environments**: `dev`, `prd`, `qlty`, `tst`, `sbx`, `stg`, `shd`.
-   **Custom Instance number**: A number from `001` to `007`.

## Project Structure

```
azure_naming_tool/
├── environments/
│   ├── dev.tfvars
│   ├── test.tfvars
│   └── prod.tfvars
├── main.tf
├── variables.tf
├── outputs.tf
└── versions.tf
```

## Files Overview

-   `main.tf`: Contains the core Terraform configuration, including the `Azure/naming/azurerm` module integration and an example resource group definition.
-   `variables.tf`: Defines input variables for the Terraform configuration, such as `cch_project_name`, `location_code`, `environment`, and `instance_number`.
-   `outputs.tf`: Defines output values that can be retrieved after Terraform applies the configuration, such as generated resource group, storage account, and virtual network names.
-   `versions.tf`: Specifies the required Terraform and AzureRM provider versions.
-   `environments/`: This directory contains environment-specific variable definition files (`.tfvars`) for `dev`, `test`, and `prod`.

## Setup and Usage

1.  **Prerequisites:**
    *   [Terraform](https://www.terraform.io/downloads.html) installed.
    *   [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
    *   An Azure subscription and appropriate permissions.

2.  **Azure Login:**
    Before running Terraform, you need to log in to your Azure account using the Azure CLI:
    ```bash
    az login
    ```

3.  **Initialize Terraform:**
    Navigate to the `azure_naming_tool` directory and initialize Terraform. This will download the necessary providers and modules.
    ```bash
    cd azure_naming_tool
    terraform init
    ```

4.  **Plan and Apply for Different Environments:**
    You can use the environment-specific `.tfvars` files to generate names for different environments. Replace `[environment]` with `dev`, `test`, or `prod`.

    *   **Development Environment:**
        ```bash
        terraform plan -var-file="environments/dev.tfvars"
        terraform apply -var-file="environments/dev.tfvars"
        ```

    *   **Test Environment:**
        ```bash
        terraform plan -var-file="environments/test.tfvars"
        terraform apply -var-file="environments/test.tfvars"
        ```

    *   **Production Environment:**
        ```bash
        terraform plan -var-file="environments/prod.tfvars"
        terraform apply -var-file="environments/prod.tfvars"
        ```

## Acceptance Criteria Fulfillment

### Scenario 1: Generate compliant names for new resources

-   The `main.tf` includes the `Azure/naming/azurerm` module.
-   The `variables.tf` defines parameters like `cch_project_name`, `location_code`, `environment`, and `instance_number` that are used by the naming module.
-   When `terraform apply` is executed, the `module.naming` generates resource names (e.g., `module.naming.resource_group.name`) that follow the organization's naming convention (e.g., `rg-sirvis-we-dev-001`). The module itself is designed to meet Azure naming rules (length, allowed characters, uniqueness).

### Scenario 2: Reuse naming convention across multiple deployments

-   The naming module is integrated into the shared Terraform repository (represented by the `azure_naming_tool` directory).
-   The same configuration (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`) is used for multiple resource deployments, with only the `.tfvars` files changing for different environments.
-   By using `terraform plan -var-file="environments/[environment].tfvars"` and `terraform apply -var-file="environments/[environment].tfvars"`, resource names are generated consistently across `dev`, `test`, and `prod` environments, and the module's design helps prevent naming conflicts.

