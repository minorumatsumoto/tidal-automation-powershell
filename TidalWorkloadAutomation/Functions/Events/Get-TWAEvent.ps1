Function Get-TWAEvent {
    <#
    .SYNOPSIS
    Get all Events or specific Event information.

    .DESCRIPTION
    return Event information based on input paramters

    .EXAMPLE
    Get-TWAEvent -Type [ Events | EventsFile | EventsJob | EventsService | EventsSystem | EventsVariable | EventActionJoin | EventActionRun | EventCalendarJoin | EventJobClassJoin | EventJobJoin ] 

    Get-TWAEvent -Type EventsVariable -EventsID 39, 40, 41 
    Get-TWAEvent -Type EventsSystem -EventsID 118, 119, 117 
    Get-TWAEvent -Type EventsService -EventsID 538 
    Get-TWAEvent -Type EventsJob -EventsID 1, 7, 8  
    Get-TWAEvent -Type EventsFile -EventsID 150, 151, 199  
    Get-TWAEvent -Type Events -EventsID 249, 253, 247

    Get-TWAEvent -Type EventActionJoin -EventsID 249, 253, 247
    Get-TWAEvent -Type EventActionRun -EventsID 249, 253, 247
    Get-TWAEvent -Type EventCalendarJoin -EventsID 249, 253, 247  
    Get-TWAEvent -Type EventJobJoin -EventsID 249, 253, 247
    Get-TWAEvent -Type EventJobClassJoin -EventsID 249, 253, 247 

    Get-TWAEvent -Type EventsVariable -Search '*oms_arch*' -Limit 3
    Get-TWAEvent -Type EventsSystem -Search '*Backup*' -Limit 3
    Get-TWAEvent -Type EventsService -Search '*adapter*' -Limit 3
    Get-TWAEvent -Type EventsJob -Search '*schedule*' -Limit 3
    Get-TWAEvent -Type EventsFile -Search '*filemove*' -Limit 3
    Get-TWAEvent -Type Events -Search '*dsl*' -Limit 3

    .NOTES
    For ease of use ensure 'Set-TWAAuth' has been initialised before running above commands 
        e.g: Set-TWAAuth -Url 'tidal.domain.com' -Port '8443' -TesVersion 'tes-6.2-dev' -Credentials (Get-Credential)
    #>

    [CmdletBinding()]
    param (
        # Pipeline variable
        [Parameter(Mandatory = $true)]
        [ValidateSet("Events","EventsFile","EventsJob","EventsService","EventsSystem","EventsVariable","EventActionJoin","EventActionRun","EventCalendarJoin","EventJobClassJoin","EventJobJoin")]
        [string]$Type,

        # Pipeline variable
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$EventsID,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Search,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1,100)]
        [int]$Limit,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TWAURL,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TWAPort,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TWAVersion,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Connection
    )

    begin {}
    
    process	
    {
        # Get credential and Tidal REST URL/Port
        if ($null -ne $Connection) 
        {
            $InsecurePassword = $Connection.Password
            $TWAURL = 'https://' + $Connection.TWAUri + ':' + $Connection.TWAPort + '/api/' + $Connection.TWAVersion + '/post'
        }
        elseif ($null -ne $Credential -and $null -ne $TWAURL -and $null -ne $TWAPort) 
        {
            Try 
            {
                $InsecurePassword = ConvertTo-InsecureString -SecureString $Credential.Password

                $null = Test-TWAURL -Url $TWAURL -Port $TWAPort -ErrorAction Stop
                $TWAURL = 'https://' + $TWAURL + ':' + $TWAPort + '/api/' + $TWAVersion + '/post'
            }
            Catch 
            {
                Throw $PSItem
            }
        }
        elseif ((Test-TWAAuthIsSet)) 
        {   
            $Credential = $Global:twaCredentials
            $InsecurePassword = ConvertTo-InsecureString -SecureString $Credential.Password
            
            $TWAURL = $global:twaurl
        }
        else 
        {
            throw "Exception:  You must do one of the following to authenticate: `n 1. Call the Set-TWAAuth cmdlet `n 2. Pass in an SSendpoint and credential"
        }

        # Get credentials and convert basic authentication
        $Header = @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName+":"+$InsecurePassword))}

        if ($EventsID)
        {
            foreach ($id in $EventsID)
            {
                $Body   = Set-RestAPIObjectRetrieve -id $id -tesParam "$Type.get"
                $result = Invoke-TWARestMethod -RestURL $TWAURL -Method "POST" -Body $Body -Header $Header

                if ($result) { $result.entry }
            }
        }
        elseif ($Search) 
        {
            $searchArray = @()
            
            $Body   = Set-RestAPIObjectRetrieve -tesParam "$Type.getList"
            $result = Invoke-TWARestMethod -RestURL $TWAURL -Method "POST" -Body $Body -Header $Header

            if ($result)
            {
                $result | ForEach-Object {

                    if ($_.title -like $Search)
                    {
                        $searchArray += $_
                    }
                } 

                $searchArray | Select-Object -First $Limit
            }
            else
            {
                return $false    
            }
        }
        else
        {
            $Body   = Set-RestAPIObjectRetrieve -tesParam "$Type.getList"
            $result = Invoke-TWARestMethod -RestURL $TWAURL -Method "POST" -Body $Body -Header $Header
            $result
        }
    }

	end {}
}  