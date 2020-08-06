Function Validate-RestAPIObjectParameters {
    <#
    .SYNOPSIS
    Validate TWA REST Object paramters

    .DESCRIPTION
    Validate TWA REST Object Paramters to ensure good data.

    .EXAMPLE
    Validate-RestAPIObjectParameters -$crudParam Job.create -$ReferenceObjectParameters -ParsedObjectParameters <hashtable varaiables> <hashtable varaiables> 

    .OUTPUTS
    throws Validation Error if failed
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$crudParam,        

        [Parameter(Mandatory = $true)]
        [hashtable]$ReferenceObjectParameters,

        [Parameter(Mandatory = $true)]
        [hashtable]$ParsedObjectParameters
    )

    begin {}
    
    process	
    {
        # Validate Object parameters (if parsed object not in reference object, object parsed)
        foreach ($newParamObject in $ReferenceObjectParameters.GetEnumerator()) 
        {
            # Check that default paramters are parsed
            if ($newParamObject.Value -match 'm') 
            {
                if (-not $ParsedObjectParameters.ContainsKey($newParamObject.key) )
                { 
                    $badKey = $newParamObject.key
                    throw ("Validation Exception:  Parsed paramter object for '$crudParam' not found: '$badKey'") 
                }
            }

            # Check if internal read-only parameters are parased
            if ($newParamObject.Value -match '-') 
            {
               
                if ($ParsedObjectParameters.ContainsKey($newParamObject.key) ) 
                {  
                    $badKey = $newParamObject.key
                    throw ("Validation Exception:  Parsed object for '$crudParam' trying to populate readonly paramter: '$badKey'") 
                }
            }
        }
    }

	end {}
}  