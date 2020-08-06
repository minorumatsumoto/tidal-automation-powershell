# Tidal Workload Automation

This PowerShell module provides a series of cmdlets for interacting with the Tidal Workload Automation REST Interface.

**IMPORTANT:** This module has been built in-house therefore the module or author have no connection with the Tidal software company.

## Usage

Download the latest release and copy the TidalWorkloadAutomation folder to your PowerShell profile directory and run: `Import-Module TidalWorkloadAutomation`
Once you've done this, all the cmdlets will be ready to use, you can see a full list using `Get-Command -Module TidalWorkloadAutomation`.

### Example - Set Authorized user for Tidal using Set-TWAAuth

```PowerShell
$cred = (Get-Credential)

Set-TWAAuth -Url 'tidal.domain.com' -Port '8443' -TesVersion 'tes-6.3-dev' -Credentials $cred
```
The username should be in the form: `domain\username`
The URL should be the instance name portion of the FQDN for your instance.  If you browse to `https://tidal.domain.com:8443` the URL required for the module is `tidal.domain.com`.


### Example - Retrieve Users containing the word 'svc' limited to 6 results 

```PowerShell
Get-TWAUser -Type WorkGroupRunUser -Search '*svc*' -Limit 6
```

### Example - Retrieve Jobs containing the word 'audit' limited to 3 results 

```PowerShell
Get-TWAJob -Type Job -Search '*audit*' -Limit 3
```

### Example - Get all calendars with Boxing Day in the Title limited to first 2 results
```PowerShell
Get-TWACalendar -Type Calendar -Search '*Boxing Day*' -Limit 2
```

### Example - Get all SNMP Actions 

```PowerShell
Get-TWAAction -Type SNMPAction
```

### Example - Get a variable

```PowerShell
$id = (Get-TWAVariable -Search "*TidalTest*" -Limit 1).id
```

### Example - Remove Authentication Information when closing connection to Tidal

```PowerShell
Remove-TWAAuth
```

## Functions

* Set-TWAAuth
* Get-TWAJob
* Get-TWAJobByType
* Get-TWAJobRun
* Get-TWAJobRunStats
* Get-TWAJobClass
* Get-TWACalendar
* Get-TWAUser
* Get-TWAAction
* Get-TWAAgent
* Get-TWANode
* Get-TWAEvent
* Get-TWAAlert
* Get-TWAVariable
* Get-TWAResource
* Get-TWAQueue
* Get-TWADependency
* Get-TWASecurity
* Get-TWAMaster
* Get-TWASchedules
* Get-TWAService
* Remove-TWAAuth