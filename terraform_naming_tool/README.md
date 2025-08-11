# Azure Naming Tool with Terraform

This example demonstrates how to implement the [Azure Naming tool](https://registry.terraform.io/modules/Azure/naming/azurerm/latest) using the official Terraform module.  The goal is to generate standardised resource names across environments while adhering to Azure naming rules such as length limits, allowed characters and scope uniqueness【61396149448754†L60-L88】.

## Overview

Naming resources consistently is a key part of cloud governance.  Names should convey useful context and adhere to Azure’s naming restrictions【61396149448754†L60-L141】.  The convention used in this example follows the pattern:

```
<resourceTypeAbbreviation>-<projectName>-<locationCode>-<environmentCode>-<instanceNumber>
```

For example, an App Service in the **sirvis** project deployed to **North Europe** (`ne`) in the **dev** environment with instance number **001** would be named `app-sirvis-ne-dev-001`.  The module automatically prepends the resource type abbreviation (`app`, `rg`, `st`, etc.), and you supply the project name, location code, environment code and instance number via variables.  Zero padding (e.g. `001`) helps keep resource names lexically ordered.

The official **Azure/naming/azurerm** module encapsulates Azure naming rules.  It exposes outputs for each resource type with built‑in abbreviations and length validations.  You provide a list of suffix components, and the module concatenates them with hyphens.  For resources that need to be globally unique (like storage accounts), you can use the `name_unique` output which appends a random string【732611034378564†L75-L86】.

## Files

| File               | Purpose |
|--------------------|---------|
| `versions.tf`      | Declares the Terraform and provider versions. |
| `variables.tf`     | Defines variables for the environment, Azure region, project name and instance number.  It also includes a map for multiple environments where you can specify a suffix list containing the location code, environment and instance number. |
| `main.tf`          | Shows how to call the naming module and create a resource group, storage account, virtual network and subnet.  It also demonstrates how to reuse the naming convention across multiple environments using `for_each`. |
| `outputs.tf`       | Exports the generated names so they can be inspected after a `terraform apply`. |
| `terraform.tfvars.example` | Sample variable values to help you get started.  Copy this file to `terraform.tfvars` and customise the values for your environment. |

## Usage

1. Review and customise the variables in `terraform.tfvars` or via CLI flags/variable files.  At a minimum you should set:
   - `environment` – the environment code (e.g. `dev`, `prd`, `qlty`).
   - `location` – the full Azure region name (e.g. `northeurope`, `westeurope`).  A two‑letter location code (e.g. `ne`, `we`) will be inferred or you can override it with `location_code_override`.
   - `project_name` – the name of your CCH project or application (e.g. `sirvis`).
   - `instance_number` – the instance number (1–7).  It will be padded to three digits (e.g. `001`).
   - `location_code_override` – (optional) set this to a two‑letter region abbreviation if your region isn’t included in the built‑in map.

2. Initialize the working directory and download the module:

   ```bash
   terraform init
   ```

3. Preview the planned resources and generated names:

   ```bash
   terraform plan -out plan.tfplan
   ```

4. Apply the configuration (this will create resources in Azure):

   ```bash
   terraform apply plan.tfplan
   ```

5. Inspect the outputs:

   ```bash
   terraform output
   ```

## How it works

In `main.tf` the naming module is invoked with a `suffix` list composed of your business unit, workload, environment and a zero‑padded instance number.  The module generates outputs like `module.naming.resource_group.name` or `module.naming.storage_account.name_unique`.  These names are then assigned to the corresponding Azure resources.  Storage accounts use the `name_unique` output because their names must be globally unique across Azure.

The second part of `main.tf` uses the `for_each` meta‑argument to call the module for multiple environments defined in `variables.tf`.  Each environment entry supplies its own region and suffix list, ensuring that names remain consistent across deployments and that collisions are avoided.  This pattern allows teams to share a single repository for dev, test and prod while keeping naming consistent.

For more background on Azure naming conventions and the components that should be included in resource names, see Microsoft’s guidance【61396149448754†L60-L141】.