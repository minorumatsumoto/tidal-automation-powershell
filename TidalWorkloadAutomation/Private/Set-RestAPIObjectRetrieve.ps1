Function Set-RestAPIObjectRetrieve {
    <#
    .SYNOPSIS
    Retrieve Object for CRUD

    .DESCRIPTION
    Set Retrieve Api object(s) – get(), getList() for CRUD method.

    .EXAMPLE
    Set-RestAPIObjectRetrieve -id 43321 -tesParam "Job.get"
    Set-RestAPIObjectRetrieve -tesParam "Job.getList"

    .OUTPUTS
    XML String if successful or exception if failed
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [int]$id,

        [Parameter(Mandatory = $true)]
        [string]$tesParam
    )

    begin {}
    
    process	
    {
        try 
        {
            if ($tesParam -match '.getList') { $tesID = '' } else { $tesID = "<tes:id>$id</tes:id>" }

            $formatedRetrieveObject =  "data=<?xml version=`"1.0`" encoding=`"UTF-8`"?><entry xmlns=`"http://purl.org/atom/ns#`"><id>xxx</id><tes:$tesParam xmlns:tes=`"http://www.tidalsoftware.com/client/tesservlet`">$tesID</tes:$tesParam></entry>"

            return $formatedRetrieveObject 
        }
        catch 
        {
            throw "Exception:  Problem parsing XML string"
        }
    }

	end {}
}  