Function Get-TWAAction {
    <#
    .SYNOPSIS
    Get all Tidal actions or specific action information.

    .DESCRIPTION
    return action information based on input paramters

    .EXAMPLE
    Get-TWAAction -Type [ Actions | AlertAction | EmailAction | JobAction | ITOAction | LogAction | ServiceAction | SNMPAction | VariableAction ]
    Get-TWAAction -Type [ Actions | AlertAction | EmailAction | JobAction | ITOAction | LogAction | ServiceAction | SNMPAction | VariableAction ] -ActionID 20, 40, 1002
    Get-TWAAction -Type [ Actions | AlertAction | EmailAction | JobAction | ITOAction | LogAction | ServiceAction | SNMPAction | VariableAction ] -Search '*email*' -Limit 6

    .NOTES
    For ease of use ensure 'Set-TWAAuth' has been initialised before running above commands 
        e.g: Set-TWAAuth -Url 'tidal.domain.com' -Port '8443' -TesVersion 'tes-6.2-dev' -Credentials (Get-Credential)
    #>

    [CmdletBinding()]
    param (
        # Pipeline variable
        [Parameter(Mandatory = $true)]
        [ValidateSet("Actions","AlertAction","EmailAction","JobAction","ITOAction","LogAction","ServiceAction","SNMPAction","VariableAction")]
        [string]$Type,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]$ActionID,

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

        if ($ActionID)
        {
            foreach ($id in $ActionID)
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