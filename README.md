# Terraform_Infra_drift_detection
Guide and configuration for setting up Terraform Infrastructure Drift Detection. Includes automation steps, scripts, and best practices to monitor and alert on drift in Terraform-managed infrastructure.


### ✅ Terraform Infra Drift Detection v

```markdown
# Terraform Infra Drift Detection.

This repository contains the configuration and pipeline setup to perform **Terraform infrastructure drift detection** using **Azure DevOps**.

Infrastructure drift occurs when the actual deployed infrastructure diverges from the code defined in Terraform configuration. This setup allows you to **automatically detect drift** and take necessary actions.

---

## 📌 Features

- ✅ Azure DevOps YAML pipeline for scheduled drift detection
- 🔁 Works with Terraform remote backends (Azure, AWS, etc.)
- 📤 Sends drift reports to logs or optional alerting systems (e.g., email, Teams)
- 🔒 Safe – read-only Terraform plan (no changes applied)
- 🧪 Supports multi-environment and workspaces

---

## 🚀 Getting Started

### Step 1: Prerequisites

- Terraform CLI installed (v1.0+ recommended)
- Azure DevOps project & repo setup
- Azure service connection with access to your backend (e.g., Azure RM, AWS, etc.)
- Remote backend configured (e.g., Azure Storage Account for state)

---

### Step 2: Repo Structure

```

.
├── azure-pipelines.yml          # Azure DevOps YAML pipeline for drift detection
├── terraform/                   # Terraform configuration directory
│   ├── main.tf
│   ├── backend.tf
│   └── variables.tf
└── scripts/
└── check\_drift.sh           # Optional helper script

````

---

### Step 3: Configure Terraform Backend

In `terraform/backend.tf`, configure your remote state:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
````

Make sure the service principal in Azure DevOps has **Storage Blob Data Reader** access.

---

### Step 4: Create Azure DevOps Pipeline

#### a. Go to Azure DevOps > Pipelines > Create Pipeline

#### b. Select your repository

#### c. Use existing YAML file and point to `azure-pipelines.yml`

---

### Step 5: azure-pipelines.yml

```yaml
trigger: none  # No trigger on push

schedules:
  - cron: "0 3 * * *"     # Every day at 3 AM UTC
    displayName: Daily Drift Check
    branches:
      include:
        - main
    always: true

pool:
  vmImage: 'ubuntu-latest'

variables:
  TF_VERSION: '1.6.0'
  ARM_CLIENT_ID: $(ARM_CLIENT_ID)
  ARM_CLIENT_SECRET: $(ARM_CLIENT_SECRET)
  ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)
  ARM_TENANT_ID: $(ARM_TENANT_ID)

steps:
- task: UseTerraform@0
  inputs:
    terraformVersion: '$(TF_VERSION)'

- script: |
    terraform --version
    cd terraform
    terraform init -input=false
    terraform plan -detailed-exitcode -input=false
  displayName: 'Terraform Drift Detection'

- task: Bash@3
  displayName: 'Handle Drift Result'
  inputs:
    targetType: 'inline'
    script: |
      if [ $$? -eq 2 ]; then
        echo "##vso[task.logissue type=error]Drift detected in infrastructure!"
        exit 1
      elif [ $$? -eq 0 ]; then
        echo "No drift detected."
      else
        echo "Terraform plan failed!"
        exit 1
      fi
```

---

### Step 6: Set Pipeline Secrets

Go to **Pipeline > Edit > Variables > Add**:

* `ARM_CLIENT_ID`
* `ARM_CLIENT_SECRET`
* `ARM_SUBSCRIPTION_ID`
* `ARM_TENANT_ID`

Mark all as **"Keep this value secret"**.

---

## ✅ Output

* If no drift: ✅ Pipeline passes
* If drift detected: ❌ Pipeline fails with message
* You can set alerts, email notifications, or integrate with Teams

---

## 📌 Notes

* This pipeline **does NOT apply any changes** – it only runs `terraform plan` to detect drift
* You can extend it to support **Slack**, **Teams**, or **email** alerts
* Add a custom script to parse and upload the plan output if needed

---

## 📄 License

MIT License. Use and modify as needed.

---

## 🙋‍♂️ Maintainers

This setup is maintained by the DevOps/Cloud Team. For queries, open an issue or contact \[[you@example.com](mailto:you@example.com)].

```

---

### Chaho to:

- **Teams/Slack alerts add** karwa deta hoon
- AWS or GCP backend ke liye customize kar deta hoon
- Multi-env support (e.g., dev/stage/prod folders) setup kar deta hoon

Batao bhai, aur kya chahiye?
```
