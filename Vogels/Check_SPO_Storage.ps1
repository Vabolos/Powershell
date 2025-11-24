param(
    [Parameter(Mandatory = $true)]
    [string]$TenantName  # e.g. vogelsbv (no domain)
)

$ClientId = "1cee0d77-80f2-4682-acf6-4a69f6101e82"
$Tenant = "vogelsbv.onmicrosoft.com"
$AdminUrl = "https://$TenantName-admin.sharepoint.com"

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Install-Module PnP.PowerShell -Scope CurrentUser -Force
}
Import-Module PnP.PowerShell -ErrorAction Stop

Write-Host "Opening browser to sign in to: $AdminUrl" -ForegroundColor Cyan
Connect-PnPOnline -Url $AdminUrl -ClientId $ClientId -Tenant $Tenant -Interactive

# Tenant capacity (MB) via PnP (no SPO module needed)
$tenant = Get-PnPTenant -ErrorAction Stop
$capacityMB = [double]$tenant.StorageQuota
$capacityGB = [math]::Round($capacityMB / 1024, 2)
$capacityTB = [math]::Round($capacityMB / (1024 * 1024), 3)

# Sites
$sites = Get-PnPTenantSite -Detailed -IncludeOneDriveSites -ErrorAction SilentlyContinue
$siteCount = ($sites | Measure-Object).Count

$usedMB = ($sites | Measure-Object -Property StorageUsage -Sum).Sum
$usedGB = [math]::Round($usedMB / 1024, 2)
$usedTB = [math]::Round($usedMB / (1024 * 1024), 3)

Write-Host ""
Write-Host "📊 TENANT STORAGE (actuals)" -ForegroundColor Green
Write-Host ("  Sites returned: {0}" -f $siteCount)
Write-Host ("  Used: {0:N2} MB  |  {1:N2} GB  |  {2:N3} TB" -f $usedMB, $usedGB, $usedTB)
Write-Host ("  Capacity: {0:N2} MB | {1:N2} GB | {2:N3} TB" -f $capacityMB, $capacityGB, $capacityTB)
Write-Host ("  Timestamp (UTC): {0}" -f (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss"))

if ($siteCount -eq 0) {
    Write-Host "`n⚠️  No sites returned. This is almost always missing delegated SharePoint permissions on the app." -ForegroundColor Yellow
    Write-Host "   In Entra ID → App registrations → your app → API permissions → Add permission → SharePoint → Delegated:" 
    Write-Host "     - ✅ AllSites.Read  (minimum for read)" 
    Write-Host "     - (or) AllSites.FullControl"
    Write-Host "   Then click “Grant admin consent”. Re-run the script."
}
start-sleep -Seconds 30




# param(
#     [Parameter(Mandatory = $true)]
#     [string]$TenantName  # e.g. vogelsbv (no domain)
# )

# $ClientId = "1cee0d77-80f2-4682-acf6-4a69f6101e82"
# $Tenant = "vogelsbv.onmicrosoft.com"
# $adminUrl = "https://$TenantName-admin.sharepoint.com"

# # Ensure PnP.PowerShell is available
# if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
#     Install-Module PnP.PowerShell -Scope CurrentUser -Force
# }
# Import-Module PnP.PowerShell -ErrorAction Stop

# Write-Host "Opening browser to sign in to: $adminUrl" -ForegroundColor Cyan
# Connect-PnPOnline -Url $adminUrl -ClientId $ClientId -Tenant $Tenant -Interactive

# # Try to read all sites
# $allSites = Get-PnPTenantSite -Detailed -IncludeOneDriveSites -ErrorAction SilentlyContinue

# # If nothing returned, warn
# if (-not $allSites) {
#     Write-Host "`n⚠️  No site data returned. Check your app permissions (SharePoint delegated AllSites.Read)." -ForegroundColor Yellow
#     return
# }

# # Calculate usage
# $usedMB = ($allSites | Measure-Object -Property StorageUsage -Sum).Sum
# $usedGB = [math]::Round($usedMB / 1024, 2)
# $usedTB = [math]::Round($usedMB / (1024 * 1024), 3)

# # Get tenant capacity
# try {
#     $tenant = Get-SPOTenant
#     $capacityMB = [double]$tenant.StorageQuota
#     $capacityTB = [math]::Round($capacityMB / (1024 * 1024), 3)
# }
# catch {
#     $capacityTB = "Unknown"
# }

# Write-Host ""
# Write-Host "📊 TOTAL STORAGE USED (tenant-wide)" -ForegroundColor Green
# Write-Host ("  Used: {0:N2} MB  |  {1:N2} GB  |  {2:N3} TB" -f $usedMB, $usedGB, $usedTB)
# Write-Host ("  Capacity: {0}" -f $capacityTB + " TB (tenant pool)")
# Write-Host ("  Timestamp (UTC): {0}" -f (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss"))

# start-sleep -Seconds 30

# # Disconnect
# Disconnect-PnPOnline
# Write-Host "`nDisconnected from SharePoint Online." -ForegroundColor Cyan
