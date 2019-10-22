function Get-ADComputers
{

    <#
  
        .SYNOPSIS
            Discover all domain joined computers in Active Directory. 
  
        .DESCRIPTION
            Uses the ADSISearcher type accelerator and System.DirectoryServices.AccountManagement namespace to discover all domain joined computers.
  
        .OUTPUTS 
            Returns operating system information, joined and changed dates, and last password set date for all domain joined computers.
  
        .EXAMPLE
            Get-ADComputers
  
    #> 

    [CmdletBinding()] 
    param (
       #An array of domains.
       [array]
       $Domains
    )

    $activity = "Active Directory Domain Joined Computers"
    Write-Log -Level "INFO" -Activity $activity -Message "Discovering Domain Joined Computers." -WriteProgress

    $allComputers = @()

    if ($null -ne $domains)
    {
        foreach ($domain in $domains)
        {
            $domainDistinguishedName = "DC="+($domain.Name.Replace(".",",DC="))
            $computerSearcher = [ADSISearcher]'ObjectClass=Computer'
            $computerSearcher.PageSize = 1000
            $computerSearcher.SearchRoot = "LDAP://"+$domainDistinguishedName
            $computers = $computerSearcher.FindAll()

            if ($null -ne $computers)
            {
                foreach ($computer in $computers)
                {
                    $computerObject = "" | Select-Object DistinguishedName, OperatingSystem, OperatingSystemServicePack, OperatingSystemVersion, PwdLastSet, WhenCreated, WhenChanged
                    $computerProperties = $computer.Properties
                    $computerObject.DistinguishedName = $computerProperties.distinguishedname
                    $computerObject.OperatingSystem = $computerProperties.operatingsystem
                    $computerObject.OperatingSystemServicePack = $computerProperties.operatingsystemservicepack
                    $computerObject.OperatingSystemVersion = $computerProperties.operatingsystemversion
                    $computerObject.WhenCreated = $computerProperties.whencreated
                    $computerObject.WhenChanged = $computerProperties.whenchanged

                    if ($null -notlike $computerProperties.pwdlastset)
                    {
                        $computerObject.PwdLastSet = [datetime]::FromFileTime($computerProperties.pwdlastset[0])
                    }

                    $allComputers += $ComputerObject
                }
            }
        }
    }

    if ($null -ne $allComputers)
    {
        $allComputers
    }
    else
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to find domain joined computers."
    }
}
