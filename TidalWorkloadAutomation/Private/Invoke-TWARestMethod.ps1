function Invoke-TWARestMethod {
	<#
	.SYNOPSIS
	Wrapper for Invoke-RestRequest to call REST method via API

	.DESCRIPTION
	Sends requests to REST services. Catches Exceptions. Returns Result of $False if failure.
	Acts as wrapper for the Invoke-RestRequest CmdLet so that status codes can be
	queried and acted on.
	All requests are sent with application/x-www-form-urlencoded; charset=utf-8.

	.PARAMETER Method
	The method for the REST Method.
	Only accepts GET, POST

	.PARAMETER URI
	The address of the API or service to send the request to.

	.PARAMETER Body
	The body of the request to send to the API

	.PARAMETER Headers
	The header of the request to send to the API (encode credentials).

	.EXAMPLE
	Invoke-TWARestMethod -RestURL $URL -Method POST -Body $Body -Header $Header
	#>

	param
	(
		[Parameter(Mandatory = $true, ValueFromPipelinebyPropertyName = $true)]
		[ValidateSet('GET', 'POST')]
		[String]$Method,

		[Parameter(Mandatory = $true)]
		[String]$RestURL,

		[Parameter(Mandatory = $true)]
		[String]$Body,

		[Parameter(Mandatory = $true)]
		[Hashtable]$Header
	)

	Begin { }

	Process 
	{
		try
		{	
			$result = Invoke-RestMethod -uri $RestURL -Method $Method -Header $Header -ContentType "application/x-www-form-urlencoded; charset=utf-8" -Body $Body -TimeoutSec 120 -ErrorVariable logonResultErr

			if (($result | Select-Object -ExpandProperty html -ErrorAction SilentlyContinue) -match "html")
			{
				throw "Exception:  problem returning data from Tidal"
			}
			else 
			{
				return $result
			}
		}
		catch
		{
			throw "Exception:  problem with Tidal"
		}
	}

	End { }
}
