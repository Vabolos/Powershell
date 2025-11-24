
# # Update to the latest PnP first
# Update-Module PnP.PowerShell -Scope CurrentUser -Force
# Import-Module PnP.PowerShell

# # Create a tenant-specific app for interactive login
# Register-PnPEntraIDAppForInteractiveLogin `
#   -ApplicationName "PnP.PowerShell - Vogels" `
#   -Tenant "vogelsbv.onmicrosoft.com" `
# # Copy the Application (client) ID from the output





# ===============================
# SharePoint Version Cleanup + Toasts
# ===============================

# ----- Config -----
$ClientId = "1cee0d77-80f2-4682-acf6-4a69f6101e82"
$Tenant = "vogelsbv.onmicrosoft.com"

# Optional logo for the toast (PNG/JPG). Leave as-is or drop a file named toast.png next to the script.
$ToastLogo = Join-Path $PSScriptRoot 'toast.png'

# ----- Toast notifications -----
$global:ToastAvailable = $false
function Ensure-ToastModule {
    try {
        if (-not (Get-Module -ListAvailable -Name BurntToast)) {
            Install-Module BurntToast -Scope CurrentUser -Force -ErrorAction Stop
        }
        Import-Module BurntToast -ErrorAction Stop
        $global:ToastAvailable = $true
    }
    catch {
        Write-Host "ℹ️ BurntToast not available: $($_.Exception.Message)"
        $global:ToastAvailable = $false
    }
}

function Send-Toast {
    param(
        [Parameter(Mandatory)][string]$Title,
        [string]$Body = "",
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]$Type = 'Info'
    )
    if (-not $global:ToastAvailable) { return }

    try {
        $logoParam = @{}
        if (Test-Path -LiteralPath $ToastLogo) { $logoParam.AppLogo = $ToastLogo }

        # Pick a subtle sound by type (optional)
        switch ($Type) {
            'Success' { New-BurntToastNotification -Text $Title, $Body @logoParam | Out-Null }
            'Warning' { New-BurntToastNotification -Text $Title, $Body @logoParam -Sound 'Default' | Out-Null }
            'Error' { New-BurntToastNotification -Text $Title, $Body @logoParam -Sound 'Default' | Out-Null }
            default { New-BurntToastNotification -Text $Title, $Body @logoParam | Out-Null }
        }
    }
    catch {
        Write-Host "ℹ️ Failed to send toast: $($_.Exception.Message)"
    }
}

# ----- Module -----
$module = "PnP.PowerShell"
if (-not (Get-Module -ListAvailable -Name $module)) { Install-Module $module -Scope CurrentUser -Force }
Import-Module $module -ErrorAction Stop
Write-Host "✅ $module ready."

# Toasts: make sure BurntToast is ready
Ensure-ToastModule
if ($global:ToastAvailable) {
    Send-Toast -Title "🔌 Modules ready" -Body "PnP.PowerShell loaded. Toasts enabled." -Type Success
}
else {
    Write-Host "🔔 Toasts disabled (BurntToast unavailable)."
}

# ----- Helpers -----
function Invoke-WithRetry {
    param(
        [Parameter(Mandatory)][scriptblock]$Script,
        [int]$Max = 6
    )
    for ($i = 0; $i -lt $Max; $i++) {
        try { return & $Script }
        catch {
            $msg = $_.Exception.Message
            if ($msg -match '429|throttl|503|timeout|temporar') {
                $backoff = [int][math]::Min([math]::Pow(2, $i), 30)
                Write-Host "⏳ Throttled/temporary error. Retrying in $backoff s..."
                Start-Sleep -Seconds $backoff
            }
            else { throw }
        }
    }
    throw "Max retries reached."
}

function Connect-PnPSite([string]$Url) {
    try {
        try { Connect-PnPOnline -Url $Url -ClientId $ClientId -Interactive -ErrorAction Stop }
        catch {
            Write-Host "⚠️ Interactive auth failed; using device login..."
            Connect-PnPOnline -Url $Url -ClientId $ClientId -Tenant $Tenant -DeviceLogin -ErrorAction Stop
        }
        Get-PnPConnection | Out-Null
        Write-Host "🔌 Connected: $Url"
        Send-Toast -Title "🔐 Connected" -Body $Url -Type Success
        $true
    }
    catch {
        $err = $_.Exception.Message
        Write-Host "❌ Failed to connect: $err"
        Send-Toast -Title "❌ Connect failed" -Body $err -Type Error
        $false
    }
}

# Delete all historical versions in one server call (keeps current)
function Remove-AllFileVersions {
    param([Parameter(Mandatory)][string]$FileServerRelativeUrl)

    $ctx = Get-PnPContext
    $resPath = [Microsoft.SharePoint.Client.ResourcePath]::FromDecodedUrl($FileServerRelativeUrl)
    $file = $ctx.Web.GetFileByServerRelativePath($resPath)

    $ctx.Load($file)
    $ctx.Load($file.Versions)
    $ctx.ExecuteQuery()

    if ($file.Versions.Count -gt 0) {
        $file.Versions.DeleteAll()
        $ctx.ExecuteQuery()
        return $true
    }
    return $false
}

# ---------- CSOM deep walker: visits EVERY folder & yields file info ----------
function Get-FileItemsByFolder {
    param(
        [Parameter(Mandatory)][object]$List,                   # list object (Document Library)
        [string]$StartFolderServerRelativeUrl                  # optional start deeper in the tree
    )

    $ctx = Get-PnPContext
    $listObj = Invoke-WithRetry { Get-PnPList -Identity $List -Includes RootFolder, Title }
    $rootSrv = $listObj.RootFolder.ServerRelativeUrl
    $startSrv = if ([string]::IsNullOrWhiteSpace($StartFolderServerRelativeUrl)) { $rootSrv } else { $StartFolderServerRelativeUrl.Trim() }

    Write-Host "   ➜ Library root (server-relative): $rootSrv"
    if ($startSrv -ne $rootSrv) { Write-Host "   ➜ Starting at: $startSrv" }

    # queue for BFS, visited to avoid loops
    $queue = New-Object System.Collections.Queue
    $visited = New-Object 'System.Collections.Generic.HashSet[string]'
    $queue.Enqueue($startSrv) | Out-Null
    $visited.Add($startSrv)   | Out-Null

    $foldersVisited = 0
    $filesYielded = 0
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    while ($queue.Count -gt 0) {
        $currentSrv = [string]$queue.Dequeue()
        $foldersVisited++

        Write-Progress -Id 1 `
            -Activity "Scanning library: $($listObj.Title)" `
            -Status   "Folder: $currentSrv  |  Folders: $foldersVisited  |  Files: $filesYielded  |  Queue: $($queue.Count)"

        # Load THIS folder (and its Folders + Files) via CSOM
        $resPath = [Microsoft.SharePoint.Client.ResourcePath]::FromDecodedUrl($currentSrv)
        $folder = $ctx.Web.GetFolderByServerRelativePath($resPath)

        $ctx.Load($folder)
        $ctx.Load($folder.Folders)
        $ctx.Load($folder.Files)
        Invoke-WithRetry { $ctx.ExecuteQuery() } | Out-Null

        # enqueue child folders
        foreach ($sub in $folder.Folders) {
            $childSrv = [string]$sub.ServerRelativeUrl
            if ($childSrv -and -not $visited.Contains($childSrv)) {
                $visited.Add($childSrv) | Out-Null
                $queue.Enqueue($childSrv) | Out-Null
            }
        }

        # yield files in this folder
        foreach ($f in $folder.Files) {
            $filesYielded++
            [pscustomobject]@{
                FileRef     = [string]$f.ServerRelativeUrl
                FileLeafRef = [string]$f.Name
            }
        }
    }

    Write-Progress -Id 1 -Completed -Activity "Scanning library: $($listObj.Title)"
    Write-Host ("   ➜ Scanned {0} folders, yielded {1} files in {2}" -f $foldersVisited, $filesYielded, $sw.Elapsed)
}

# -------- Processor --------
function Process-Site([string]$SiteUrl, [switch]$DryRun, [string]$StartFolderServerRelativeUrl) {
    $libs = Invoke-WithRetry { Get-PnPList -Includes Title, Hidden, BaseTemplate | Where-Object { $_.BaseTemplate -eq 101 -and -not $_.Hidden } }
    if (-not $libs) {
        Write-Host "ℹ️ No document libraries found."
        Send-Toast -Title "ℹ️ No libraries" -Body $SiteUrl -Type Info
        return
    }

    $totalFiles = 0; $totalVersions = 0; $totalDeleted = 0
    $details = New-Object System.Collections.Generic.List[object]
    $ctx = Get-PnPContext

    foreach ($lib in $libs) {
        Write-Host "📁 $($lib.Title)"
        $processedInLib = 0; $deletedInLib = 0

        # Enumerate ALL files in the library (deep)
        $items = Get-FileItemsByFolder -List $lib -StartFolderServerRelativeUrl $StartFolderServerRelativeUrl

        foreach ($it in $items) {
            $fileRef = $it.FileRef
            $name = $it.FileLeafRef

            # load file + versions once (for both dry-run and delete)
            $resPath = [Microsoft.SharePoint.Client.ResourcePath]::FromDecodedUrl($fileRef)
            $file = $ctx.Web.GetFileByServerRelativePath($resPath)

            $ctx.Load($file)
            $ctx.Load($file.Versions)
            Invoke-WithRetry { $ctx.ExecuteQuery() } | Out-Null

            $verCount = [int]$file.Versions.Count
            if ($verCount -gt 0) {
                if ($DryRun) {
                    $totalFiles++; $processedInLib++; $totalVersions += $verCount
                    $details.Add([pscustomobject]@{
                            Library  = $lib.Title
                            File     = $name
                            Versions = $verCount
                            Path     = $fileRef
                        })
                }
                else {
                    $file.Versions.DeleteAll()
                    Invoke-WithRetry { $ctx.ExecuteQuery() } | Out-Null
                    $totalFiles++; $processedInLib++; $totalDeleted++
                    Write-Host ("  - {0} | Removed {1} historical versions" -f $name, $verCount)
                }
            }

            Write-Progress -Id 2 `
                -Activity "Processing: $($lib.Title)" `
                -Status   "Files with history: $processedInLib  |  Files cleaned: $deletedInLib" `
                -PercentComplete 0
        }
    }

    Write-Progress -Id 2 -Completed -Activity "Processing libraries"

    Write-Host ""
    if ($DryRun) {
        Write-Host "🔎 DRY-RUN SUMMARY for $SiteUrl"
        Write-Host "Libraries scanned            : $($libs.Count)"
        Write-Host "Files with version history   : $totalFiles"
        Write-Host "Total versions to delete     : $totalVersions"

        # Toast with a concise summary
        Send-Toast -Title "🔎 Dry-run complete" -Body "Libs: $($libs.Count) | Files: $totalFiles | Versions: $totalVersions" -Type Info

        if ($details.Count) {
            $details | Sort-Object Library, File | Format-Table -AutoSize
            $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $csv = "VersionCleanup_DryRun_$($stamp).csv"
            $details | Export-Csv -Path $csv -NoTypeInformation -Encoding UTF8
            Write-Host "📝 Full dry-run details saved to: $csv"
        }
        else {
            Write-Host "✅ No version history found. Nothing to delete."
        }
    }
    else {
        Write-Host "🧹 CLEANUP COMPLETE for $SiteUrl"
        Write-Host "Files cleaned (had history)  : $totalFiles"
        Write-Host "Delete operations performed  : $totalDeleted"

        # Toast completion
        Send-Toast -Title "🧹 Cleanup complete" -Body "Files cleaned: $totalFiles | Deletes: $totalDeleted" -Type Success
    }
}

# ----- Main loop -----
while ($true) {
    $siteUrl = Read-Host "Enter SharePoint Site URL (or press Enter to quit)"
    if ([string]::IsNullOrWhiteSpace($siteUrl)) { 
        Write-Host "👋 Exiting."
        Send-Toast -Title "✅ All done" -Body "Script finished." -Type Success
        break 
    }
    if ($siteUrl -notmatch '^https?://') { 
        Write-Host "⚠️ Use full URL, e.g. https://tenant.sharepoint.com/sites/YourSite"
        Send-Toast -Title "⚠️ Invalid URL" -Body "Provide a full https:// URL" -Type Warning
        continue 
    }

    if (-not (Connect-PnPSite $siteUrl)) { 
        # connect already toasts on failure
        continue 
    }

    # Example to start deep: /sites/VogelsProfessionalBenelux/DocumentsNew/General
    $startFolder = Read-Host "Optional: start at a specific folder (server-relative) or press Enter for library root"

    $dry = Read-Host "Do a dry-run first? (Y/N)"
    if ($dry -match '^[Yy]') {
        try {
            Process-Site -SiteUrl $siteUrl -DryRun -StartFolderServerRelativeUrl $startFolder
            $go = Read-Host "Proceed with deletion now? (Y/N)"
            if ($go -match '^[Yy]') {
                $confirm = Read-Host "Type 'DELETE' to confirm deletion"
                if ($confirm -eq 'DELETE') { 
                    Process-Site -SiteUrl $siteUrl -StartFolderServerRelativeUrl $startFolder 
                }
                else { 
                    Write-Host "❎ Not confirmed. Skipping."
                    Send-Toast -Title "❎ Deletion skipped" -Body "Confirmation not provided." -Type Warning
                }
            }
            else { 
                Write-Host "⏭️ Skipped deletion for $SiteUrl."
                Send-Toast -Title "⏭️ Skipped deletion" -Body $siteUrl -Type Info
            }
        }
        catch {
            $err = $_.Exception.Message
            Write-Host "❌ Error during dry-run/cleanup: $err"
            Send-Toast -Title "❌ Error" -Body $err -Type Error
        }
    }
    else {
        try {
            $confirm = Read-Host "This will delete all historical versions and keep only the current version. Type 'DELETE' to confirm"
            if ($confirm -eq 'DELETE') { 
                Process-Site -SiteUrl $siteUrl -StartFolderServerRelativeUrl $startFolder 
            }
            else { 
                Write-Host "❎ Not confirmed. Skipping."
                Send-Toast -Title "❎ Deletion skipped" -Body "Confirmation not provided." -Type Warning
            }
        }
        catch {
            $err = $_.Exception.Message
            Write-Host "❌ Error during cleanup: $err"
            Send-Toast -Title "❌ Error" -Body $err -Type Error
        }
    }

    $again = Read-Host "Process another site? (Y/N)"
    if ($again -notmatch '^[Yy]') { 
        Write-Host "👋 All done."
        Send-Toast -Title "✅ All done" -Body "Script finished." -Type Success
        break 
    }
}






# <# SharePoint Online – Trim File Version History (PnP.PowerShell)
# - Walks every folder & subfolder via CSOM (BFS) – LVT-safe
# - Dry-run shows exact version counts
# - Delete uses CSOM DeleteAll() (one call per file)
# - Retry/backoff + progress; optional start folder
# #>

# # ----- Config -----
# $ClientId = "1cee0d77-80f2-4682-acf6-4a69f6101e82"
# $Tenant = "vogelsbv.onmicrosoft.com"

# # ----- Module -----
# $module = "PnP.PowerShell"
# if (-not (Get-Module -ListAvailable -Name $module)) { Install-Module $module -Scope CurrentUser -Force }
# Import-Module $module -ErrorAction Stop
# Write-Host "✅ $module ready."

# # ----- Helpers -----
# function Invoke-WithRetry {
#     param(
#         [Parameter(Mandatory)][scriptblock]$Script,
#         [int]$Max = 6
#     )
#     for ($i = 0; $i -lt $Max; $i++) {
#         try { return & $Script }
#         catch {
#             $msg = $_.Exception.Message
#             if ($msg -match '429|throttl|503|timeout|temporar') {
#                 $backoff = [int][math]::Min([math]::Pow(2, $i), 30)
#                 Write-Host "⏳ Throttled/temporary error. Retrying in $backoff s..."
#                 Start-Sleep -Seconds $backoff
#             }
#             else { throw }
#         }
#     }
#     throw "Max retries reached."
# }

# function Connect-PnPSite([string]$Url) {
#     try {
#         try { Connect-PnPOnline -Url $Url -ClientId $ClientId -Interactive -ErrorAction Stop }
#         catch {
#             Write-Host "⚠️ Interactive auth failed; using device login..."
#             Connect-PnPOnline -Url $Url -ClientId $ClientId -Tenant $Tenant -DeviceLogin -ErrorAction Stop
#         }
#         Get-PnPConnection | Out-Null
#         Write-Host "🔌 Connected: $Url"
#         $true
#     }
#     catch {
#         Write-Host "❌ Failed to connect: $($_.Exception.Message)"
#         $false
#     }
# }

# # Delete all historical versions in one server call (keeps current)
# function Remove-AllFileVersions {
#     param([Parameter(Mandatory)][string]$FileServerRelativeUrl)

#     $ctx = Get-PnPContext
#     $resPath = [Microsoft.SharePoint.Client.ResourcePath]::FromDecodedUrl($FileServerRelativeUrl)
#     $file = $ctx.Web.GetFileByServerRelativePath($resPath)

#     $ctx.Load($file)
#     $ctx.Load($file.Versions)
#     $ctx.ExecuteQuery()

#     if ($file.Versions.Count -gt 0) {
#         $file.Versions.DeleteAll()
#         $ctx.ExecuteQuery()
#         return $true
#     }
#     return $false
# }


# # ---------- CSOM deep walker: visits EVERY folder & yields file info ----------
# function Get-FileItemsByFolder {
#     param(
#         [Parameter(Mandatory)][object]$List,                   # list object (Document Library)
#         [string]$StartFolderServerRelativeUrl                  # optional start deeper in the tree
#     )

#     $ctx = Get-PnPContext
#     $listObj = Invoke-WithRetry { Get-PnPList -Identity $List -Includes RootFolder, Title }
#     $rootSrv = $listObj.RootFolder.ServerRelativeUrl
#     $startSrv = if ([string]::IsNullOrWhiteSpace($StartFolderServerRelativeUrl)) { $rootSrv } else { $StartFolderServerRelativeUrl.Trim() }

#     Write-Host "   ➜ Library root (server-relative): $rootSrv"
#     if ($startSrv -ne $rootSrv) { Write-Host "   ➜ Starting at: $startSrv" }

#     # queue for BFS, visited to avoid loops
#     $queue = New-Object System.Collections.Queue
#     $visited = New-Object 'System.Collections.Generic.HashSet[string]'
#     $queue.Enqueue($startSrv) | Out-Null
#     $visited.Add($startSrv)   | Out-Null

#     $foldersVisited = 0
#     $filesYielded = 0
#     $sw = [System.Diagnostics.Stopwatch]::StartNew()

#     while ($queue.Count -gt 0) {
#         $currentSrv = [string]$queue.Dequeue()
#         $foldersVisited++

#         Write-Progress -Id 1 `
#             -Activity "Scanning library: $($listObj.Title)" `
#             -Status   "Folder: $currentSrv  |  Folders: $foldersVisited  |  Files: $filesYielded  |  Queue: $($queue.Count)"

#         # Load THIS folder (and its Folders + Files) via CSOM
#         $resPath = [Microsoft.SharePoint.Client.ResourcePath]::FromDecodedUrl($currentSrv)
#         $folder = $ctx.Web.GetFolderByServerRelativePath($resPath)

#         $ctx.Load($folder)
#         $ctx.Load($folder.Folders)
#         $ctx.Load($folder.Files)
#         Invoke-WithRetry { $ctx.ExecuteQuery() } | Out-Null


#         # enqueue child folders
#         foreach ($sub in $folder.Folders) {
#             $childSrv = [string]$sub.ServerRelativeUrl
#             if ($childSrv -and -not $visited.Contains($childSrv)) {
#                 $visited.Add($childSrv) | Out-Null
#                 $queue.Enqueue($childSrv) | Out-Null
#             }
#         }

#         # yield files in this folder
#         foreach ($f in $folder.Files) {
#             $filesYielded++
#             # We only need Name + ServerRelativeUrl now; versions are loaded in processing phase
#             [pscustomobject]@{
#                 FileRef     = [string]$f.ServerRelativeUrl
#                 FileLeafRef = [string]$f.Name
#             }
#         }
#     }

#     Write-Progress -Id 1 -Completed -Activity "Scanning library: $($listObj.Title)"
#     Write-Host ("   ➜ Scanned {0} folders, yielded {1} files in {2}" -f $foldersVisited, $filesYielded, $sw.Elapsed)
# }

# # -------- Processor --------
# function Process-Site([string]$SiteUrl, [switch]$DryRun, [string]$StartFolderServerRelativeUrl) {
#     $libs = Invoke-WithRetry { Get-PnPList -Includes Title, Hidden, BaseTemplate | Where-Object { $_.BaseTemplate -eq 101 -and -not $_.Hidden } }
#     if (-not $libs) { Write-Host "ℹ️ No document libraries found."; return }

#     $totalFiles = 0; $totalVersions = 0; $totalDeleted = 0
#     $details = New-Object System.Collections.Generic.List[object]
#     $ctx = Get-PnPContext

#     foreach ($lib in $libs) {
#         Write-Host "📁 $($lib.Title)"
#         $processedInLib = 0; $deletedInLib = 0

#         # Enumerate ALL files in the library (deep)
#         $items = Get-FileItemsByFolder -List $lib -StartFolderServerRelativeUrl $StartFolderServerRelativeUrl

#         foreach ($it in $items) {
#             $fileRef = $it.FileRef
#             $name = $it.FileLeafRef

#             # load file + versions once (for both dry-run and delete)
#             $resPath = [Microsoft.SharePoint.Client.ResourcePath]::FromDecodedUrl($fileRef)
#             $file = $ctx.Web.GetFileByServerRelativePath($resPath)

#             $ctx.Load($file)
#             $ctx.Load($file.Versions)
#             Invoke-WithRetry { $ctx.ExecuteQuery() } | Out-Null


#             $verCount = [int]$file.Versions.Count
#             if ($verCount -gt 0) {
#                 if ($DryRun) {
#                     $totalFiles++; $processedInLib++; $totalVersions += $verCount
#                     $details.Add([pscustomobject]@{
#                             Library  = $lib.Title
#                             File     = $name
#                             Versions = $verCount
#                             Path     = $fileRef
#                         })
#                 }
#                 else {
#                     $file.Versions.DeleteAll()
#                     Invoke-WithRetry { $ctx.ExecuteQuery() } | Out-Null
#                     $totalFiles++; $processedInLib++; $totalDeleted++
#                     Write-Host ("  - {0} | Removed {1} historical versions" -f $name, $verCount)
#                 }
#             }

#             Write-Progress -Id 2 `
#                 -Activity "Processing: $($lib.Title)" `
#                 -Status   "Files with history: $processedInLib  |  Files cleaned: $deletedInLib" `
#                 -PercentComplete 0
#         }
#     }

#     Write-Progress -Id 2 -Completed -Activity "Processing libraries"

#     Write-Host ""
#     if ($DryRun) {
#         Write-Host "🔎 DRY-RUN SUMMARY for $SiteUrl"
#         Write-Host "Libraries scanned            : $($libs.Count)"
#         Write-Host "Files with version history   : $totalFiles"
#         Write-Host "Total versions to delete     : $totalVersions"
#         if ($details.Count) {
#             $details | Sort-Object Library, File | Format-Table -AutoSize
#             $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
#             $csv = "VersionCleanup_DryRun_$($stamp).csv"
#             $details | Export-Csv -Path $csv -NoTypeInformation -Encoding UTF8
#             Write-Host "📝 Full dry-run details saved to: $csv"
#         }
#         else {
#             Write-Host "✅ No version history found. Nothing to delete."
#         }
#     }
#     else {
#         Write-Host "🧹 CLEANUP COMPLETE for $SiteUrl"
#         Write-Host "Files cleaned (had history)  : $totalFiles"
#         Write-Host "Delete operations performed  : $totalDeleted"
#     }
# }

# # ----- Main loop -----
# while ($true) {
#     $siteUrl = Read-Host "Enter SharePoint Site URL (or press Enter to quit)"
#     if ([string]::IsNullOrWhiteSpace($siteUrl)) { Write-Host "👋 Exiting."; break }
#     if ($siteUrl -notmatch '^https?://') { Write-Host "⚠️ Use full URL, e.g. https://tenant.sharepoint.com/sites/YourSite"; continue }

#     if (-not (Connect-PnPSite $siteUrl)) { continue }

#     # Example to start deep: /sites/VogelsProfessionalBenelux/DocumentsNew/General
#     $startFolder = Read-Host "Optional: start at a specific folder (server-relative) or press Enter for library root"

#     $dry = Read-Host "Do a dry-run first? (Y/N)"
#     if ($dry -match '^[Yy]') {
#         Process-Site -SiteUrl $siteUrl -DryRun -StartFolderServerRelativeUrl $startFolder
#         $go = Read-Host "Proceed with deletion now? (Y/N)"
#         if ($go -match '^[Yy]') {
#             $confirm = Read-Host "Type 'DELETE' to confirm deletion"
#             if ($confirm -eq 'DELETE') { Process-Site -SiteUrl $siteUrl -StartFolderServerRelativeUrl $startFolder } else { Write-Host "❎ Not confirmed. Skipping." }
#         }
#         else { Write-Host "⏭️ Skipped deletion for $SiteUrl." }
#     }
#     else {
#         $confirm = Read-Host "This will delete all historical versions and keep only the current version. Type 'DELETE' to confirm"
#         if ($confirm -eq 'DELETE') { Process-Site -SiteUrl $siteUrl -StartFolderServerRelativeUrl $startFolder } else { Write-Host "❎ Not confirmed. Skipping." }
#     }

#     $again = Read-Host "Process another site? (Y/N)"
#     if ($again -notmatch '^[Yy]') { Write-Host "👋 All done."; break }
# }





# <# SharePoint Online – Trim File Version History (PnP.PowerShell)
# - Per-site prompt, Dry-run option, Repeat or Exit
# - Deletes historical versions only; current version is kept #>

# # ----- Config -----
# $ClientId = "1cee0d77-80f2-4682-acf6-4a69f6101e82"
# $Tenant = "vogelsbv.onmicrosoft.com"

# # ----- Module -----
# $module = "PnP.PowerShell"
# if (-not (Get-Module -ListAvailable -Name $module)) { Install-Module $module -Scope CurrentUser -Force }
# Import-Module $module -ErrorAction Stop
# Write-Host "✅ $module ready."

# function Connect-PnPSite([string]$Url) {
#     try {
#         try { Connect-PnPOnline -Url $Url -ClientId $ClientId -Interactive -ErrorAction Stop }
#         catch {
#             Write-Host "⚠️ Interactive auth failed; using device login..."
#             Connect-PnPOnline -Url $Url -ClientId $ClientId -Tenant $Tenant -DeviceLogin -ErrorAction Stop
#         }
#         Get-PnPConnection | Out-Null
#         Write-Host "🔌 Connected: $Url"
#         $true
#     }
#     catch {
#         Write-Host "❌ Failed to connect: $($_.Exception.Message)"
#         $false
#     }
# }

# function Process-Site([string]$SiteUrl, [switch]$DryRun) {
#     # Get document libraries (template 101, not hidden)
#     $libs = Get-PnPList -Includes Title, Hidden, BaseTemplate | Where-Object { $_.BaseTemplate -eq 101 -and -not $_.Hidden }
#     if (-not $libs) { Write-Host "ℹ️ No document libraries found."; return }

#     # CAML to fetch files (FSObjType=0)
#     $caml = @"
# <View Scope='RecursiveAll'>
#   <Query><Where><Eq><FieldRef Name='FSObjType'/><Value Type='Integer'>0</Value></Eq></Where></Query>
#   <ViewFields><FieldRef Name='FileRef'/><FieldRef Name='FileLeafRef'/></ViewFields>
#   <RowLimit Paged='TRUE'>2000</RowLimit>
# </View>
# "@

#     $totalFiles = 0; $totalVersions = 0; $totalDeleted = 0
#     $details = New-Object System.Collections.Generic.List[object]

#     foreach ($lib in $libs) {
#         Write-Host "📁 $($lib.Title)"
#         $items = Get-PnPListItem -List $lib -PageSize 2000 -Query $caml
#         foreach ($it in $items) {
#             $fileRef = $it["FileRef"]; $name = $it["FileLeafRef"]
#             $versions = Get-PnPFileVersion -Url $fileRef -ErrorAction SilentlyContinue
#             if ($versions.Count -gt 0) {
#                 $totalFiles++; $totalVersions += $versions.Count
#                 if ($DryRun) {
#                     # add ALL files (no cap)
#                     $details.Add([pscustomobject]@{
#                             Library  = $lib.Title
#                             File     = $name
#                             Versions = $versions.Count
#                             Path     = $fileRef
#                         })
#                 }
#                 else {
#                     foreach ($v in $versions) {
#                         Remove-PnPFileVersion -Url $fileRef -Identity $v.Id -Force -ErrorAction SilentlyContinue
#                         $totalDeleted++
#                     }
#                     Write-Host ("  - {0} | Removed {1} historical versions" -f $name, $versions.Count)
#                 }
#             }
#         }
#     }

#     Write-Host ""
#     if ($DryRun) {
#         Write-Host "🔎 DRY-RUN SUMMARY for $SiteUrl"
#         Write-Host "Libraries scanned            : $($libs.Count)"
#         Write-Host "Files with version history   : $totalFiles"
#         Write-Host "Total versions to delete     : $totalVersions"

#         if ($details.Count) {
#             # show EVERYTHING to console
#             $details | Sort-Object Library, File | Format-Table -AutoSize

#             # also save a CSV for full review
#             $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
#             $csv = "VersionCleanup_DryRun_$($stamp).csv"
#             $details | Export-Csv -Path $csv -NoTypeInformation -Encoding UTF8
#             Write-Host "📝 Full dry-run details saved to: $csv"
#         }
#         else {
#             Write-Host "✅ No version history found. Nothing to delete."
#         }
#     }
#     else {
#         Write-Host "🧹 CLEANUP COMPLETE for $SiteUrl"
#         Write-Host "Files that had history       : $totalFiles"
#         Write-Host "Versions deleted             : $totalDeleted"
#     }
# }

# # ----- Main loop -----
# while ($true) {
#     $siteUrl = Read-Host "Enter SharePoint Site URL (or press Enter to quit)"
#     if ([string]::IsNullOrWhiteSpace($siteUrl)) { Write-Host "👋 Exiting."; break }
#     if ($siteUrl -notmatch '^https?://') { Write-Host "⚠️ Use full URL, e.g. https://tenant.sharepoint.com/sites/YourSite"; continue }

#     if (-not (Connect-PnPSite $siteUrl)) { continue }

#     $dry = Read-Host "Do a dry-run first? (Y/N)"
#     if ($dry -match '^[Yy]') {
#         Process-Site -SiteUrl $siteUrl -DryRun

#         $go = Read-Host "Proceed with deletion now? (Y/N)"
#         if ($go -match '^[Yy]') {
#             $confirm = Read-Host "Type 'DELETE' to confirm deletion"
#             if ($confirm -eq 'DELETE') { Process-Site -SiteUrl $siteUrl } else { Write-Host "❎ Not confirmed. Skipping." }
#         }
#         else { Write-Host "⏭️ Skipped deletion for $siteUrl." }
#     }
#     else {
#         $confirm = Read-Host "This will delete all historical versions and keep only the current version. Type 'DELETE' to confirm"
#         if ($confirm -eq 'DELETE') { Process-Site -SiteUrl $siteUrl } else { Write-Host "❎ Not confirmed. Skipping." }
#     }

#     $again = Read-Host "Process another site? (Y/N)"
#     if ($again -notmatch '^[Yy]') { Write-Host "👋 All done."; break }
# }









# <# SharePoint Online – Trim File Version History (PnP.PowerShell)
#     - Per-site prompt, Dry-run option, Repeat or Exit
#     - Deletes historical versions only; current version is kept #>

# # ----- Config -----
# $ClientId = "1cee0d77-80f2-4682-acf6-4a69f6101e82"
# $Tenant   = "vogelsbv.onmicrosoft.com"

# # ----- Module -----
# $module = "PnP.PowerShell"
# if (-not (Get-Module -ListAvailable -Name $module)) { Install-Module $module -Scope CurrentUser -Force }
# Import-Module $module -ErrorAction Stop
# Write-Host "✅ $module ready."

# function Connect-PnPSite([string]$Url) {
#     try {
#         try { Connect-PnPOnline -Url $Url -ClientId $ClientId -Interactive -ErrorAction Stop }
#         catch {
#             Write-Host "⚠️ Interactive auth failed; using device login..."
#             Connect-PnPOnline -Url $Url -ClientId $ClientId -Tenant $Tenant -DeviceLogin -ErrorAction Stop
#         }
#         Get-PnPConnection | Out-Null
#         Write-Host "🔌 Connected: $Url"
#         $true
#     } catch {
#         Write-Host "❌ Failed to connect: $($_.Exception.Message)"
#         $false
#     }
# }

# function Process-Site([string]$SiteUrl, [switch]$DryRun) {
#     # Get document libraries (template 101, not hidden)
#     $libs = Get-PnPList -Includes Title,Hidden,BaseTemplate | Where-Object { $_.BaseTemplate -eq 101 -and -not $_.Hidden }
#     if (-not $libs) { Write-Host "ℹ️ No document libraries found."; return }

#     # CAML to fetch files (FSObjType=0)
#     $caml = @"
# <View Scope='RecursiveAll'>
#   <Query><Where><Eq><FieldRef Name='FSObjType'/><Value Type='Integer'>0</Value></Eq></Where></Query>
#   <ViewFields><FieldRef Name='FileRef'/><FieldRef Name='FileLeafRef'/></ViewFields>
#   <RowLimit Paged='TRUE'>2000</RowLimit>
# </View>
# "@

#     $totalFiles=0; $totalVersions=0; $totalDeleted=0
#     $preview = New-Object System.Collections.Generic.List[object]

#     foreach ($lib in $libs) {
#         Write-Host "📁 $($lib.Title)"
#         $items = Get-PnPListItem -List $lib -PageSize 2000 -Query $caml
#         foreach ($it in $items) {
#             $fileRef = $it["FileRef"]; $name = $it["FileLeafRef"]
#             $versions = Get-PnPFileVersion -Url $fileRef -ErrorAction SilentlyContinue
#             if ($versions.Count -gt 0) {
#                 $totalFiles++; $totalVersions += $versions.Count
#                 if ($DryRun) {
#                     if ($preview.Count -lt 20) { $preview.Add([pscustomobject]@{Library=$lib.Title; File=$name; Versions=$versions.Count; Path=$fileRef}) }
#                 } else {
#                     foreach ($v in $versions) {
#                         Remove-PnPFileVersion -Url $fileRef -Identity $v.Id -Force -ErrorAction SilentlyContinue
#                         $totalDeleted++
#                     }
#                     Write-Host ("  - {0} | Removed {1} historical versions" -f $name, $versions.Count)
#                 }
#             }
#         }
#     }

#     Write-Host ""
#     if ($DryRun) {
#         Write-Host "🔎 DRY-RUN SUMMARY for $SiteUrl"
#         Write-Host "Libraries scanned            : $($libs.Count)"
#         Write-Host "Files with version history   : $totalFiles"
#         Write-Host "Total versions to delete     : $totalVersions"
#         if ($preview.Count) { $preview | Format-Table -AutoSize }
#     } else {
#         Write-Host "🧹 CLEANUP COMPLETE for $SiteUrl"
#         Write-Host "Files that had history       : $totalFiles"
#         Write-Host "Versions deleted             : $totalDeleted"
#     }
# }

# # ----- Main loop -----
# while ($true) {
#     $siteUrl = Read-Host "Enter SharePoint Site URL (or press Enter to quit)"
#     if ([string]::IsNullOrWhiteSpace($siteUrl)) { Write-Host "👋 Exiting."; break }
#     if ($siteUrl -notmatch '^https?://') { Write-Host "⚠️ Use full URL, e.g. https://tenant.sharepoint.com/sites/YourSite"; continue }
    
#     if (-not (Connect-PnPSite $siteUrl)) { continue }
    
#     $dry = Read-Host "Do a dry-run first? (Y/N)"
#     if ($dry -match '^[Yy]') {
#         Process-Site -SiteUrl $siteUrl -DryRun
    
#         $go = Read-Host "Proceed with deletion now? (Y/N)"
#         if ($go -match '^[Yy]') {
#             $confirm = Read-Host "Type 'DELETE' to confirm deletion"
#             if ($confirm -eq 'DELETE') { Process-Site -SiteUrl $siteUrl } else { Write-Host "❎ Not confirmed. Skipping." }
#         } else { Write-Host "⏭️ Skipped deletion for $siteUrl." }
#     } else {
#         $confirm = Read-Host "This will delete all historical versions and keep only the current version. Type 'DELETE' to confirm"
#         if ($confirm -eq 'DELETE') { Process-Site -SiteUrl $siteUrl } else { Write-Host "❎ Not confirmed. Skipping." }
#     }

#     $again = Read-Host "Process another site? (Y/N)"
#     if ($again -notmatch '^[Yy]') { Write-Host "👋 All done."; break }
# }



