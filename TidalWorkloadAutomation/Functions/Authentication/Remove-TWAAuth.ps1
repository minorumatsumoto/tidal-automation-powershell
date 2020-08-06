function Remove-TWAAuth {
<#
    .SYNOPSIS
    Remove authentication details

    .DESCRIPTION
    Remove authentication details

    .EXAMPLE
    Remove-TWAAuth

#>
    if (-not (Test-TWAAuthIsSet)) 
    {
        Return $true
    }

    try 
    {
        Remove-Variable -Name twaurl -Scope Global -ErrorAction Stop
        Remove-Variable -Name twaCredentials -Scope Global -ErrorAction Stop
    }
    catch 
    {
        Write-Error $_
        Return $false
    }
}
