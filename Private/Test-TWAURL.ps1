Function Test-TWAURL {
    <#
    .SYNOPSIS
    Test Tidal Urls.

    .DESCRIPTION
    For use in testing Tidal Urls.

    .EXAMPLE
    Test-TWAURL -Url 'tidaldel.domain.com' -Port '8443'

    #>

    [CmdletBinding()]
    param (
        # Pipeline variable
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Url,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Port
    )

    begin {}
    
	process	{
        Write-Verbose "Testing Tidal url:  $Url  port: $Port"
        if ((New-Object Net.Sockets.TcpClient -ArgumentList $Url,$Port).Connected) 
        {
            $true
        }
        else 
        {
            Throw "The expected URL ($Url : $Port) is not responding"
        }
    }

	end {}
}
