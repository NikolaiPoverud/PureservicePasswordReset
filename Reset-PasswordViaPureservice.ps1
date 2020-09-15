Param(
    [string]$ticketNumber
)

$Version = "1.0"

$versionCheck = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/NikolaiPoverud/PureservicePasswordReset/master/ResetADPassword.ps1" -UseBasicParsing

if($versioncheck -contains "`$Vers")



if ($ticketNumber) {
    .\ResetADPassword.ps1 -ticketnumber $ticketnumber
}
else {
    .\ResetADPassword.ps1
}


