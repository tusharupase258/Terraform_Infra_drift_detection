Terraform_Infra_drift_detection

---

````markdown
# Terraform_Infra_drift_detection

This repository provides **reusable** and **extensible** configurations for detecting **Terraform infrastructure drift** using **Azure DevOps pipelines**.

Infrastructure drift occurs when the actual deployed infrastructure differs from what's defined in Terraform code. This repo automates drift detection and provides optional steps to manually review and apply changes safely.

---

## 📌 Repository Goals

- ✅ Provide **multiple pipeline templates** for drift detection
- 🔁 Support flows from **plan-only** to **approval and apply**
- 🌐 Enable usage across **multiple environments** (e.g., dev, stage, prod)
- 🛠️ Include **helper scripts** (e.g., reporting, conversion to test results)
- 📦 Standardize Terraform drift detection in CI/CD workflows

---

## 📁 Repository Structure

```bash
.
├── pipelines/
│   ├── drift-plan-only.yml              # Detect drift only (no apply)
│   ├── drift-plan-approve-apply.yml     # Drift detection with manual approval & apply
│   ├── drift-plan-auto-apply.yml        # (Coming Soon) Auto apply after drift
│
├── terraform/                           # Example Terraform configuration
│   ├── main.tf
│   ├── backend.tf
│   └── variables.tf
│
├── scripts/
│   ├── drift_to_junit.py                # Converts Terraform plan JSON to JUnit XML
│   └── check_drift.sh                   # (Optional) Shell helper script
│
└── README.md                            # This documentation
````

---

## ✅ Available Pipelines

### 1. `drift-plan-only.yml`

* Runs `terraform plan -detailed-exitcode`
* Publishes the raw plan output (`drift.json`) as an artifact
* Converts `drift.json` → `drift-results.xml` (JUnit format)
* Shows drift results in Azure DevOps Test tab

### 2. `drift-plan-approve-apply.yml`

* Includes all steps from the **plan-only pipeline**
* Adds a **manual approval stage** before apply
* Applies changes using `tfplan.binary` only after approval

### 3. `drift-plan-auto-apply.yml` *(Coming Soon)*

* Automatically applies changes **without human approval**
* Best suited for **non-production** environments

---

## 🐍 Python Script for Drift Report Conversion

The repo includes a Python script to convert `terraform plan -json` output into **JUnit XML**, so it can be viewed as test results in Azure DevOps.

### 📄 Script: `scripts/drift_to_junit.py`

#### 📦 Requirements

* Python 3.x
* [`junit-xml`](https://pypi.org/project/junit-xml/)

Install via pip:

```bash
pip install junit-xml
```

#### 🧪 Usage

```bash
python scripts/drift_to_junit.py drift.json drift-results.xml
```

* `drift.json`: Output from `terraform plan -json`
* `drift-results.xml`: Used by `PublishTestResults@2` in the pipeline

---

## 🔁 How to Use in Azure DevOps

1. Go to **Azure DevOps** → **Pipelines** → **New Pipeline**
2. Select your repository
3. Choose "**Existing YAML file**"
4. Pick the pipeline file you need, e.g.:

```yaml
/pipelines/drift-plan-approve-apply.yml
```

---

## 🔐 Authentication Setup

Set the following as **secure pipeline variables** or in a **DevOps Variable Group**:

* `ARM_CLIENT_ID`
* `ARM_CLIENT_SECRET`
* `ARM_SUBSCRIPTION_ID`
* `ARM_TENANT_ID`

Also, create a **service connection** in Azure DevOps named:

```text
tushar_SP
```

Or update the pipeline YAML to match your actual service connection name.

---

## 📌 Best Practices

* ❌ **Never hardcode secrets** – use secure variables or Key Vault
* 🔍 Always **review the plan** before applying (especially in production)
* 🗃️ Archive `drift.json` and `tfplan.binary` as artifacts for audit trail
* 🔀 Use **separate pipelines** per environment (dev/stage/prod)
* ✅ Follow Terraform workspace or directory patterns to organize infra

---

## 🛠 Tools Used

* [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) v1.6+ / v1.7+
* [Azure DevOps Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
* Python 3.x for drift reporting
* Bash (optional scripts)

---

## 📄 License

This project is licensed under the **MIT License** — free to use, modify, and distribute.

---

## 🙋 Maintainers

Maintained by **Tushar Upase**
📧 Email: [tusharupase786@gmail.com](mailto:tusharupase786@gmail.com)
For issues, [open a GitHub Issue](https://github.com/your-repo/issues)
