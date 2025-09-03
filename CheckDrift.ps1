param (
    [string]$AppFolder,
    [string]$PlanOutputFile,
    [string]$ReportsDir,
    [string]$DriftReportFile,
    [string]$HtmlReportFile
)

# Ensure reports folder exists
if (-Not (Test-Path "$ReportsDir")) {
    New-Item -ItemType Directory -Force -Path "$ReportsDir" | Out-Null
}

cd "$AppFolder"

# Generate plain text report
terraform show -no-color $PlanOutputFile | Out-File -FilePath "$ReportsDir/$DriftReportFile" -Encoding utf8

# Detect drift
$content = Get-Content "$ReportsDir/$DriftReportFile" -Raw
if ($content -match "No changes. Your infrastructure matches the configuration.") {
    Write-Host "No drift detected"
    Write-Host "##vso[task.setvariable variable=DriftDetected;isOutput=true]false"
} else {
    Write-Host "Drift detected"
    Write-Host "##vso[task.setvariable variable=DriftDetected;isOutput=true]true"
}

# Generate JSON & HTML report
$jsonPlanFile = "$ReportsDir/tfplan.json"
terraform show -json $PlanOutputFile | Out-File $jsonPlanFile -Encoding utf8
$planData = Get-Content $jsonPlanFile | ConvertFrom-Json

$countAdd = 0; $countChange = 0; $countDestroy = 0
if ($planData.resource_changes) {
    foreach ($res in $planData.resource_changes) {
        $action = ($res.change.actions -join ",")
        if ($action -like "*create*") { $countAdd++ }
        if ($action -like "*update*") { $countChange++ }
        if ($action -like "*delete*") { $countDestroy++ }
    }
}

$html = @"
<html>
<head>
  <title>Terraform Drift Summary</title>
  <style>
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid black; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    .add { background-color: #d4edda; }
    .change { background-color: #fff3cd; }
    .destroy { background-color: #f8d7da; }
  </style>
</head>
<body>
<h2>Terraform Drift Summary</h2>
<p><strong>Summary:</strong> Added: $countAdd | Changed: $countChange | Destroyed: $countDestroy</p>
"@

if ($planData.resource_changes -and $planData.resource_changes.Count -gt 0) {
    $html += "<table><tr><th>Resource</th><th>Type</th><th>Action</th></tr>"
    foreach ($res in $planData.resource_changes) {
        $action = ($res.change.actions -join ",")
        $class = switch -Regex ($action) {
            "create" { "add"; break }
            "update" { "change"; break }
            "delete" { "destroy"; break }
            default { ""; break }
        }
        $html += "<tr class='$class'><td>$($res.address)</td><td>$($res.type)</td><td>$action</td></tr>"
    }
    $html += "</table>"
} else {
    $html += "<p>No drift detected. Infrastructure is up-to-date.</p>"
}

$html += "</body></html>"
$html | Out-File "$ReportsDir/$HtmlReportFile" -Encoding utf8

Write-Host "Drift dashboard generated at: $ReportsDir/$HtmlReportFile"