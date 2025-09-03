# Terraform_Infra_drift_detection

This repository provides reusable and extensible configurations for detecting **Terraform Infrastructure Drift** using **Azure DevOps pipelines**.

Infrastructure drift occurs when the actual deployed infrastructure differs from what’s defined in Terraform code.  
This repo automates drift detection, generates reports, and provides manual approval workflows before applying changes safely.

---

## 📌 Repository Goals

* ✅ Provide multiple pipeline templates for drift detection  
* 🔁 Support flows from **plan-only** to **approval and apply**  
* 🌐 Enable usage across **multiple environments** (e.g., dev, pre-prod, prod)  
* 🛠️ Include helper scripts for drift reporting and dashboards  
* 📦 Standardize **Terraform drift detection** in CI/CD workflows  

---

## 📁 Repository Structure

```

.
├── main\_drift\_detection.yaml       # Azure DevOps pipeline for drift detection
├── CheckDrift.ps1                  # PowerShell script to check drift & generate HTML dashboard
├── terraform/                      # Example Terraform configuration
│   ├── main.tf
│   ├── backend.tf
│   └── variables.tf
├── scripts/                        # Helper scripts (extendable)
├── .gitignore
└── README.md

```

---

## ✅ Available Pipelines

### 1. Drift Detection (`main_drift_detection.yaml`)

* Runs `terraform plan -detailed-exitcode`  
* Detects drift and sets pipeline variable `DriftDetected`  
* Generates:  
  * `drift.txt` → plain-text summary  
  * `drift-summary.html` → dashboard report  
  * `tfplan.json` → JSON plan output for analysis  
* Publishes reports as artifacts in Azure DevOps  

### 2. Manual Approval

* If drift is detected, requires **manual approval** before applying changes  
* Sends approval request with drift report attached  

### 3. Apply Changes

* Re-initializes Terraform backend  
* Applies drift changes only after approval  

---

## 🐍 & 💻 Drift Reporting Scripts

### PowerShell Script: `CheckDrift.ps1`

* Parses Terraform plan file  
* Detects drift and sets Azure DevOps output variable  
* Generates both **JSON** and **HTML summary dashboards**  
* Categorizes resources into:  
  * ➕ Added  
  * 🔄 Changed  
  * ❌ Destroyed  

---

## 📊 Unified Drift Report

The pipeline produces:  

- **Drift Dashboard** → Added / Changed / Destroyed resources  
- **Pipeline Artifacts** → `drift.txt`, `drift-summary.html`, `tfplan.json`  
- **Azure DevOps Test Results** → Drift shown as test cases  

![Drift Detection Overview](./drift-detection-overview.png)  

💡 With this setup, teams can **catch drift early** and keep infrastructure always in sync with Terraform.  

---

## 🔁 How to Use in Azure DevOps

1. Go to **Azure DevOps → Pipelines → New Pipeline**  
2. Select your repository  
3. Choose **Existing YAML file**  
4. Pick:  

```

/main\_drift\_detection.yaml

```
5. Run pipeline manually (trigger is set to `none`)  

---

## 🔐 Authentication Setup

Configure the following **secure variables** or use an **Azure DevOps Variable Group**:

* `ARM_CLIENT_ID`  
* `ARM_CLIENT_SECRET`  
* `ARM_SUBSCRIPTION_ID`  
* `ARM_TENANT_ID`  

Also, create a service connection in Azure DevOps named:

```

tushar\_sc\_new1

```

(or update YAML to match your actual service connection name).  

---

## 📌 Best Practices

* ❌ **Never hardcode secrets** – use secure variables or Azure Key Vault  
* 🔍 Always review the **plan & HTML report** before applying (esp. in production)  
* 🗃️ Archive `drift.json`, `drift.txt`, `drift-summary.html`, and `tfplan.binary` as artifacts  
* 🔀 Use **separate pipelines per environment** (dev / pre-prod / prod)  
* ✅ Follow Terraform workspace/directory patterns for infra organization  

---

## 🛠 Tools Used

* Terraform CLI v1.6+ / v1.7+  
* Azure DevOps Pipelines  
* PowerShell (drift dashboard)  
* Python 3.x *(optional – for JUnit conversion)*  
* Bash *(optional – helper scripts)*  

---

## 📄 License

This project is licensed under the **MIT License** — free to use, modify, and distribute.  

---

## 🙋 Maintainers

Maintained by **Tushar Upase**  
📧 Email: [tusharupase786@gmail.com](mailto:tusharupase786@gmail.com)  

For issues, open a **GitHub Issue** in this repository.  
