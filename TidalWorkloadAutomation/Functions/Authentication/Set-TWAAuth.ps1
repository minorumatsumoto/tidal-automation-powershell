function Set-TWAAuth {
<#
    .SYNOPSIS
    Set your Tidal authentication credentials

    .DESCRIPTION
    This cmdlet will set your Tidal authentication credentials which will enable you to interact with Tidal using the other cmdlets in the module

    .PARAMETER Url
    The URL of your Tidal instance

    .PARAMETER Credentials
    Credentials to authenticate you to the Tidal instance provided in the Url parameter

    .EXAMPLE
    Set-TWAAuth -Url 'tidal.domain.com' -Port '8443' -TesVersion 'tes-6.2-dev'

#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Url,

        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-TWAURL -Url $Url -Port $_})]
        [string]$Port,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TesVersion,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credentials
    )
    $Global:twaurl = "https://" + $Url + ":" + $Port + "/api/" + $TesVersion + "/post"
    $Global:twaCredentials = $Credentials
    return $true
}
