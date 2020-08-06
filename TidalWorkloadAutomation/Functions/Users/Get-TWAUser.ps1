Function Get-TWAUser {
    <#
    .SYNOPSIS
    Get all users/workgroups or specific user account/workgroup information.

    .DESCRIPTION
    return user account/workgroup information based on input paramters

    .EXAMPLE
    Get-TWAUser -Type [ Users | UserService | UserSession | UserMessage | UserJoin | WorkGroup | WorkGroupRunUser | WorkGroupUserJoin | Owners ]
    Get-TWAUser -Type Users -TesID 3, 5, 8
    Get-TWAUser -Type WorkGroupRunUser -Search '*svc*' -Limit 6

    .NOTES 
    For ease of use ensure 'Set-TWAAuth' has been initialised before running above commands 
        e.g: Set-TWAAuth -Url 'tidal.domain.com' -Port '8443' -TesVersion 'tes-6.2-dev' -Credentials (Get-Credential)
    #>

    [CmdletBinding()]
    param (
        # Pipeline variable
        [Parameter(Mandatory = $true)]
        [ValidateSet("Users","UserService","UserSession","UserMessage","UserJoin","WorkGroup","WorkGroupRunUser","WorkGroupUserJoin","Owners")]
        [string]$Type,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$TesID,

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

        if ($TesID)
        {
            foreach ($id in $TesID)
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