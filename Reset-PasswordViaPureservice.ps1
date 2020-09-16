Param(
    [string]$ticketNumber
)

$Version = 1.1

$versionCheck = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/NikolaiPoverud/PureservicePasswordReset/master/version.json" -UseBasicParsing

Write-Host "Sjekker versjonsnummer... Du kjører versjon $Version..."
Start-Sleep 2
if ($Version -ne $versionCheck) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/NikolaiPoverud/PureservicePasswordReset/master/ResetADPassword.ps1" -OutFile "C:\Pureservice\ResetADPassword.ps1"
    Write-Host "Ny versjon er $Versioncheck... Oppdaterer scriptet"
    Start-Sleep 2

}
else{
    Write-Host "Du er allerede på nyeste versjon..."
}

$Path = "C:\Pureservice"

if ($ticketNumber) {
    Start-Process "powershell.exe" -ArgumentList "-file $Path\ResetADPassword.ps1 -ticketNumber $ticketNumber" 
}
else {
    Start-Process "powershell.exe" -ArgumentList "-file $Path\ResetADPassword.ps1"
}


