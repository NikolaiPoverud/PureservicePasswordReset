Param(
    $ticketNumber,
    $WaitFor
)

if (!($WaitFor -eq $null)) {
    Do {
        $proc = Get-Process -Id $WaitFor
    }
    until ($proc -eq $null)
}

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/NikolaiPoverud/PureservicePasswordReset/master/ResetADPassword.ps1" -OutFile "C:\Pureservice\ResetADPassword.ps1" -UseBasicParsing


$Path = "C:\Pureservice"

if ($ticketNumber) {
    Start-Process "powershell.exe" -ArgumentList "-file $Path\ResetADPassword.ps1 -ticketNumber $ticketNumber"
}
else {
    Start-Process "powershell.exe" -ArgumentList "-file $Path\ResetADPassword.ps1"
}

