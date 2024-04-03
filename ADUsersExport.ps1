Get-ADUser -Filter * -Properties * | Select-Object name, Surname, UserPrincipalName, WhenCreated | export-csv -path c:\temp\userexport.csv

if (-not(Test-Path -Path 'C:\powershell')) {
    Write-Host "C:\ps directory does not exist, creating now." -ForegroundColor Yellow
    $item = New-Item -Path C:\ps -Name DCUserExport.ps1 -ItemType File -Force
    Add-Content -Path $item -Value $authContent
    Write-Host "DCUserExport.ps1 created successfully." -ForegroundColor Cyan
}
else {
    Write-Host "DCUserExport.ps1 already successfully." -ForegroundColor Cyan
    Add-Content -Path $item -Value $authContent
}
