# Script om de disk space van een computer te checken
[CmdletBinding()]
param(
    [string]$ComputerName = $env:COMPUTERNAME
)
# Error handling
try{
    Write-Host "Checking disk space on computer: $ComputerName"
    # Bij pc connection wordt de disk space opgehaald met Get-WmiObject
    if(Test-Connection -ComputerName $ComputerName -Count 1 -Quiet){ 
        $diskSpace = Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName `
        | Select-Object SystemName,DeviceID,VolumeName,@{Name="Capacity(GB)";Expression={[math]::Round($_.Size/1GB,2)}},@{Name="UsedSpace(GB)";Expression={[math]::Round(($_.Size-$_.FreeSpace)/1GB,2)}},@{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}}
        # Output disk space details
        $diskSpace | Format-Table -AutoSize 
    }
    # Error message als pc niet gevonden is      
    else{ 
        Write-Host "The $ComputerName is not available. Please check if the computer is turned on and if you can reach it."
    }
    # Data opgeslagen in csv file met de huidige datum erachter en daarna verplaatst naar de temp folder
    $date = Get-Date -Format "yyyy-MM-dd"
    $outputPath = "C:\temp\DiskspaceReports\DiskReport_$date.csv"
    $diskSpace | Export-Csv -Path $outputPath -NoTypeInformation
    Write-Host ".CVS file has successfully been created/updated"
}
catch [System.IO.IOException] {
    Write-Error "Error: Could not access file $outputPath because it is being used by another process. Please close the file and try again." 

}
catch{
    # Error message als het script niet goed is uitgevoerd
    Write-Error "An error has occurred: $_"
}
