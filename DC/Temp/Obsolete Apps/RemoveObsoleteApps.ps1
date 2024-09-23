Echo 'Check de Execution Policy:'
Get-ExecutionPolicy -List
Pause

Echo 'Zet de Execution Policy op ByPass:'
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
Pause

Echo 'Verwijderen Xbox Apps...'
Get-ProvisionedAppxPackage -Online | `
Where-Object { $_.PackageName -match "xbox" } | `
ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName  $_.PackageName }

Get-AppxPackage Microsoft.XboxIdentityProvider -AllUsers | Remove-AppxPackage
Get-AppxPackage Microsoft.GamingApp -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Skype'
Get-ProvisionedAppxPackage -Online | `
Where-Object { $_.PackageName -match "skype" } | `
ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName  $_.PackageName }

Echo 'Verwijderen Solitaire'
Get-AppxPackage Microsoft.MicrosoftSolitaireCollection -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Microsoft Mail'
Get-AppxPackage Microsoft.windowscommunicationsapps -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Video'
Get-AppxPackage Microsoft.ZuneVideo -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Phone Link'
Get-AppxPackage Microsoft.YourPhone -AllUsers | Remove-AppxPackage

Echo 'Verwijderen MediaPlayer'
Get-AppxPackage Microsoft.ZuneMusic -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Spotify'
Get-AppxPackage SpotifyAB.SpotifyMusic -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Weather'
Get-AppxPackage Microsoft.BingWeather -AllUsers | Remove-AppxPackage

Echo 'Verwijderen News'
Get-AppxPackage Microsoft.BingNews -AllUsers | Remove-AppxPackage

Echo 'Verwijderen ClipChamp VideoEditor'
Get-AppxPackage Clipchamp.Clipchamp -AllUsers | Remove-AppxPackage

Echo 'Verwijderen WhiteBoard'
Get-AppxPackage Microsoft.Whiteboard -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Journal'
Get-AppxPackage Microsoft.MicrosoftJournal -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Maps'
Get-AppxPackage Microsoft.WindowsMaps -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Cortana'
Get-AppxPackage Microsoft.549981C3F5F10 -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Family'
Get-AppxPackage MicrosoftCorporationII.MicrosoftFamily -AllUsers | Remove-AppxPackage

Echo 'Verwijderen ToDo'
Get-AppxPackage Microsoft.Todos -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Mixed Reality Portal'
Get-AppxPackage Microsoft.MixedReality.Portal -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Personen'
Get-AppxPackage Microsoft.People -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Plaknotities'
Get-AppxPackage Microsoft.MicrosoftStickyNotes -AllUsers | Remove-AppxPackage

Echo 'Verwijderen KonicaMinolta Experience'
Get-AppxPackage KONICAMINOLTAINC.KONICAMINOLTAPrintExperience -AllUsers | Remove-AppxPackage

Echo 'Verwijderen PowerAutomate'
Get-AppxPackage Microsoft.PowerAutomateDesktop -AllUsers | Remove-AppxPackage

Echo 'Verwijderen GamingApp'
Get-AppxPackage Microsoft.GamingApp -AllUsers | Remove-AppxPackage

Echo 'Verwijderen Mobile Plans'
Get-AppxPackage Microsoft.OneConnect -AllUsers | Remove-AppxPackage

Echo 'Zet de Execution Policy op terug op Undefined:'
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser

Echo 'Klaar!'
Echo 'Check de lijst op andere onzinnige meukzooi, in PowerShell ISE:'
Echo Get-AppxPackage | Select Name, PackageFullName
Pause