Param(
    [string]$ticketNumber
)

$Version = 1.1

function Create-RandomPassword {
    $Liste1 = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/NikolaiPoverud/PureservicePasswordReset/master/Liste1.txt" -UseBasicParsing).ToString()
    $Liste1 = $Liste1 -split '[\r\n]'
    $Liste2 = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/NikolaiPoverud/PureservicePasswordReset/master/Liste2.txt" -UseBasicParsing).ToString()
    $Liste2 = $Liste2 -split '[\r\n]'
    $Liste3 = (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/NikolaiPoverud/PureservicePasswordReset/master/liste.txt" -UseBasicParsing).ToString()
    $Liste3 = $Liste3 -split '[\r\n]'
    $Word1 = $Liste1 | Sort-Object { Get-Random } -Unique | Select-Object -first 1
    $Word2 = $Liste2 | Sort-Object { Get-random } -Unique | Select-Object -first 1
    $Word3 = $Liste3 | Sort-Object { Get-random } -Unique | Select-Object -first 1
    $Word4 = "i"
    $Date = Get-Date -Format "ddMM"
 
    $pwd = $Word1 + " " + $Word2.tolower() + " " + $Word4.tolower() + " " + $Word3 + " " + $Date 
  
    $pwd

}

##Config stuff
$config = Get-Content C:\Pureservice\config.json | convertfrom-json

if ($ticketnumber) {

    
    $baseUri = $Config.baseUri 
    $apiKey = $config.apiKey
    $content = $Config.content

    # Declare Pureservice variables -Do not change
    $headers = @{'Accept' = 'application/vnd.api+json'; 'X-Authorization-Key' = $apiKey }
  

    # Get User from Active Directory
    $UserName = Read-Host "Please specify users username"
    $userObj = Get-ADUser -Filter { SamAccountName -eq $UserName } -Properties mail
    $userName = $userObj.SamAccountName
    $enabled = $userObj.enabled
    $mail = $userObj.mail

    # Get ticket info
    $ticketUri = "$baseUri/api/ticket?filter=requestNumber=$ticketNumber"
    $ticketQuery = Invoke-RestMethod -uri $ticketUri -ContentType $content -Headers $headers
    $ticketId = $ticketQuery.tickets.Id

    #Get agent to assign ticket
    $AdSearch = Get-ADUser -Filter "SamAccountName -eq '$env:USERNAME'" -pr cn, displayName
    $GetAgents = invoke-restmethod -uri "$BaseUri/api/user/?filter=$($config.pureserviceFilter)" -headers $headers | Select-Object -ExpandProperty users | Select-Object fullName, id
    $Agent = $GetAgents | Where-Object { $_.fullName -contains $AdSearch.displayName } | select id


    if ($enabled -eq $false) {
        Unlock-ADAccount -Identity $userObj
    }

    $pw = Create-RandomPassword


    # Send the command to change password in Active Directory
    Set-ADAccountPassword -Identity $username -NewPassword (ConvertTo-SecureString -AsPlainText "$pw" -Force) -Reset 
  
    # Close ticket and notify user
    $CloseBody = [PSCustomObject]@{
        tickets = @(
            @{
                id              = $ticketID
                subject         = $ticketQuery.tickets.subject
                description     = $ticketQuery.tickets.description
                solution        = "Passordet for bruker med brukernavn $username er satt til '$pw' og endres ved første pålogging.

            Visste du at man kan resette sitt eget passord dersom man har lagret mobilnummeret sitt i HR-systemet? Da skriver man en SMS: HRTPASS og sender til $($config.resetNumber). Da vil man få nytt passord på SMS.
            Pass derfor på å ha riktig informasjon i HR-systemet. Man kan sjekke sine egne opplysninger på $($config.linktoHR) (denne finner man også på skrivebordet og på selvbetjening på intranett - HR Web)"
                assignedTeamId  = 1 
                assignedAgentId = $Agent.id
                resolvedbyId    = $ticketQuery.tickets.assignedAgentId
                category1Id     = 1083
                links           = @{
                    user        = @{ id = $ticketquery.tickets.links.user.id }
                    ticketType  = @{ id = $ticketquery.tickets.links.ticketType.id }
                    priority    = @{ id = $ticketquery.tickets.links.priority.id }
                    status      = @{ id = 7 }
                    source      = @{ id = $ticketquery.tickets.links.source.id }
                    modifiedBy  = @{ id = $ticketquery.tickets.links.modifiedBy.id }
                    requestType = @{ id = $ticketquery.tickets.links.requestType.id }
                } 
            }
        )
    }


    Invoke-RestMethod -uri "$Baseuri/api/ticket/$ticketID" -Headers $headers  -Body (ConvertTo-Json $CloseBody -Depth 4) -Method Put -ContentType $content

}
else {
    $UserName = Read-Host "Please specify users username"
    $userObj = Get-ADUser -Filter { SamAccountName -eq $UserName } -Properties mail
    $userName = $userObj.SamAccountName
    $enabled = $userObj.enabled
    $mail = $userObj.mail

    if ($enabled -eq $false) {
        Unlock-ADAccount -Identity $userObj
    }

    $pw = Create-RandomPassword
    Set-ADAccountPassword -Identity $userobj -NewPassword (ConvertTo-SecureString -AsPlainText "$pw" -Force) -Reset 
    Set-ADUser -Identity $userobj -ChangePasswordAtLogon $true
    if ($userobj.enabled -eq $false) {
        Unlock-ADAccount -Identity $userObj
    }

    Write-Host "Passord satt til: '$pw'"

    pause
}


