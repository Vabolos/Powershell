# =========================================================
#  SharePoint Online – List all Sites (forces PowerShell 5.1)
#  Sorted alphabetically by URL
# =========================================================

# --- 1️⃣ Relaunch in PowerShell 5.1 if needed ---
if ($PSVersionTable.PSVersion.Major -ne 5) {
    Write-Host "Restarting script in Windows PowerShell 5.1..."
    $ps5Path = (Get-Command powershell.exe).Source
    $scriptPath = $MyInvocation.MyCommand.Definition
    & $ps5Path -NoProfile -ExecutionPolicy Bypass -File $scriptPath
    exit
}

# --- 2️⃣ Ensure SPO module is available ---
if (-not (Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell)) {
    Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force
}

Import-Module Microsoft.Online.SharePoint.PowerShell -ErrorAction Stop

# --- 3️⃣ Connect to tenant admin ---
$adminUrl = "https://vogelsbv-admin.sharepoint.com"
Write-Host "Connecting to $adminUrl..."
Connect-SPOService -Url $adminUrl

# --- 4️⃣ Retrieve and sort all site collections ---
$sites = Get-SPOSite -Limit All | Sort-Object URL

# --- 5️⃣ Display table and optional export ---
$sites | 
Select-Object URL, Owner, Template, StorageUsageCurrent | 
Format-Table -AutoSize

# Optional: export to CSV (also alphabetically sorted)
$path = Join-Path $env:USERPROFILE 'Documents\SPO_Sites.csv'
$rows = Import-Csv -Path $path

$enhanced = foreach ($row in $rows) {
    $s = Get-SPOSite -Identity $row.URL  # add -Detailed if you like
    [PSCustomObject]@{
        URL                      = $row.URL
    }
}

$enhanced | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8
Write-Host "✅ Updated CSV with extra columns at $path"

Write-Host "`n✅ Sites listed successfully (alphabetical by URL)."
