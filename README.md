````markdown
# Terraform_Infra_drift_detection

This repository provides reusable and extensible configurations for detecting **Terraform infrastructure drift** via **Azure DevOps pipelines**.

Infrastructure drift occurs when the actual deployed infrastructure differs from what's defined in Terraform code. This repo automates drift detection and provides optional steps to manually review and apply changes.

---

## 📌 Repository Goals

- Provide **multiple pipeline templates** for drift detection
- Support flows from **plan-only** to **approval and apply**
- Enable usage across **multiple environments** (e.g., dev, stage, prod)
- Include helper scripts (e.g., for reporting, conversion)
- Standardize Terraform drift detection in CI/CD

---

## 📁 Repository Structure

```bash
.
├── pipelines/
│   ├── drift-plan-only.yml              # Detect drift only (no apply)
│   ├── drift-plan-approve-apply.yml     # Drift detection with approval & apply
│   ├── drift-plan-auto-apply.yml        # (Future) Drift detection with auto-apply
│
├── terraform/                           # Terraform configs (optional or examples)
│   ├── main.tf
│   ├── backend.tf
│   └── variables.tf
│
├── scripts/
│   ├── drift_to_junit.py                # Converts Terraform JSON plan to JUnit XML
│   └── check_drift.sh                   # (Optional) Shell script helper
│
└── README.md
````

---

## ✅ Available Pipelines

### 1. `drift-plan-only.yml`

* Runs `terraform plan -detailed-exitcode`
* Publishes the raw plan output (`drift.json`) as artifact
* Converts `drift.json` → `drift-results.xml` (JUnit format)
* Shows results in Azure DevOps test dashboard

---

### 2. `drift-plan-approve-apply.yml`

* All features of plan-only pipeline
* Adds **manual approval stage**
* Runs `terraform apply` using saved plan file (`tfplan.binary`) **after approval**

---

### 3. `drift-plan-auto-apply.yml` *(Coming Soon)*

* Automatically applies changes without manual review
* Intended for **non-production** environments

---

## 🐍 Python Script for Drift Report Conversion

This repo includes a Python script to convert `terraform plan` JSON output to JUnit format for visualization in Azure DevOps test results.

### Script: `scripts/drift_to_junit.py`

#### 📦 Requirements

* Python 3.x
* [`junit-xml`](https://pypi.org/project/junit-xml/)

Install it via pip:

```bash
pip install junit-xml
```

#### 🧪 Usage

```bash
python scripts/drift_to_junit.py drift.json drift-results.xml
```

* Input: `drift.json` generated from `terraform plan -json`
* Output: `drift-results.xml` used in `PublishTestResults@2` task

---

## 🔁 How to Use in Azure DevOps

1. Go to Azure DevOps → Pipelines → New Pipeline
2. Choose your repository
3. Select "Existing YAML file"
4. Choose a pipeline from `/pipelines/`

```yaml
/pipelines/drift-plan-approve-apply.yml
```

---

## 🔐 Authentication Setup

Set the following as **pipeline variables** or in a secure Azure DevOps Library:

* `ARM_CLIENT_ID`
* `ARM_CLIENT_SECRET`
* `ARM_SUBSCRIPTION_ID`
* `ARM_TENANT_ID`

Also, create a service connection in Azure DevOps named `tushar_SP` or update pipeline YAML accordingly.

---

## 📌 Best Practices

* Don't hardcode secrets – use secure pipelines and Key Vault
* Always review `terraform plan` before applying (especially in prod)
* Archive `drift.json` or `tfplan.binary` as artifacts for auditing
* Use separate pipelines for different environments if needed

---

## 🛠 Tools Used

* Terraform CLI v1.6+ / v1.7+
* Azure DevOps Pipelines
* Python 3.x
* Bash scripting (optional)

---

## 📄 License

MIT License – free to use, modify, and extend.

---

## 🙋 Maintainers

Maintained by the Tushar
📧 Contact: `tusharupase786@gmail.com` or open an issue in the repo

```
