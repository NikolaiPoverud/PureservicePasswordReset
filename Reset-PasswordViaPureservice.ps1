Param(
    [string]$ticketNumber
)

$Version = "1.0"

$versionCheck = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/NikolaiPoverud/PureservicePasswordReset/master/version.json" -UseBasicParsing

if($Version -ne $versionCheck){
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/NikolaiPoverud/PureservicePasswordReset/master/ResetADPassword.ps1" -OutFile "C:\Pureservice\ResetADPassword.ps1"
}


if ($ticketNumber) {
    .\ResetADPassword.ps1 -ticketnumber $ticketnumber
}
else {
    .\ResetADPassword.ps1
}


