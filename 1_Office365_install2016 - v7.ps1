#set variables
$path = "c:\office365install"
$office2016_path = "c:\office365install\Office"
$min_size = 2000
# $startmenu = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office 2016"

Set-Variable __COMPAT_LAYER=WINXPSP3

if(!(Test-Path -Path $path))
{
    Write-output "Creating local install folder"
    mkdir $path
    write-output "Done..."
}
else
{
    write-output "."
    Write-output "Local install folder already exists, skipping create folder job"
}

write-output "."
Write-output "Now...copying needed files to local install folder"


##copy needed files to local temp folder
copy-item -Path $PWD"\setup.exe" -Destination $path
copy-item -Path $PWD"\configuration.xml" -Destination $path
copy-item -path $PWD"\disableprompt.reg" -Destination $path
copy-item -path $PWD"\mkdir.bat" -Destination $path
write-output "Done copying first step..."

if((Test-Path -Path $office2016_path))
{
    remove-item -Path $office2016_path -Recurse
    copy-item -Path $PWD"\Office" -Destination $path -Recurse
}
else
{
    copy-item -Path $PWD"\Office" -Destination $path -Recurse
}

write-output "Done...copying Office files"

Set-Location $path

# Write-output "Downloading office 2016, this will take a while..."
# & .\setup.exe /download configuration.xml

if(!(Test-Path -Path $office2016_path))
{
    write-output "ERROR!"
    Write-Output "Office 2016 has not been copied to local folder, stopping script now!"
    Pause
    Exit
}

else
{
#$FolderSize = Get-ChildItem $office2016_path -Recurse 
$FolderSize = ((Get-ChildItem c:\office365install\Office -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
}


if(!(($FolderSize -gt $min_size) ))
{
    write-output "ERROR!"
    Write-output "Installation folder has incorrect size, stopping script now!"
    Pause
    Exit
}
    
    write-output "OK..."
    Write-Output "Verified that office 2016 has been copied correctly"
    Write-output "Now Installing Office 2016, this might take a while..."
    
    & .\setup.exe /configure configuration.xml
    #& .\setup.exe /configure configuration.xml -verb RunAs
    

    Write-output "YES! Completed Office setup"

    Write-Output "Finally, disabling Default File types splash screen"
    regedit /s "c:\office365install\disableprompt.reg"


    Write-Output "...And Creating start menu folder and moving shortcuts"


    $start_uninstall = start-process -filepath 'c:\office365install\mkdir.bat' -PassThru -verb Runas
    $start_uninstall.WaitForExit()


    Write-output "Removing temporary files Office setup"
    Set-Location $path
    ##remove temporary files from temp folder after installation
    remove-item setup.exe
    remove-item configuration.xml
    remove-item disableprompt.reg
    remove-item mkdir.bat
    remove-item -Path $office2016_path -Recurse


write-output "."
Write-output "Installation completed succesfully!"

Pause