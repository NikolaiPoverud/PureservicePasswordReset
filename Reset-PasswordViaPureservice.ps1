Param(
    [string]$ticketNumber
)

$Version = 1.0

$versionCheck = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/NikolaiPoverud/PureservicePasswordReset/master/version.json" -UseBasicParsing

if ($Version -ne $versionCheck) {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/NikolaiPoverud/PureservicePasswordReset/master/ResetADPassword.ps1" -OutFile "C:\Github\PureservicePasswordReset\ResetADPassword.ps1"
}

$Path = "C:\Pureservice"

if ($ticketNumber) {
    Start-Process "powershell.exe" -ArgumentList "-file $Path\ResetADPassword.ps1 -ticketNumber $ticketNumber" 
}
else {
    Start-Process "powershell.exe" -ArgumentList "-file $Path\ResetADPassword.ps1"
}


