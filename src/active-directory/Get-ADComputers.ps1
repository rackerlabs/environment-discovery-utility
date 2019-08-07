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
    Write-Log -Level "INFO" -Activity $activity -Message "Discovering Domain Joined Computers."
   
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
                    $computerProperties = $computer.GetDirectoryEntry() | Select DistinguishedName, OperatingSystem, OperatingSystemServicePack, OperatingSystemVersion, WhenCreated, WhenChanged
                    $computerObject.DistinguishedName = $computerProperties | Select -ExpandProperty DistinguishedName
                    $computerObject.OperatingSystem = $computerProperties | Select -ExpandProperty OperatingSystem
                    $computerObject.OperatingSystemServicePack = $computerProperties | Select -ExpandProperty OperatingSystemServicePack
                    $computerObject.OperatingSystemVersion = $computerProperties | Select -ExpandProperty OperatingSystemVersion
                    $computerObject.WhenCreated = $computerProperties | Select -ExpandProperty WhenCreated
                    $computerObject.WhenChanged = $computerProperties | Select -ExpandProperty WhenChanged
                    
                    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
                    $contextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
                    $context = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $contextType, $domain.Name
                    $idType = [System.DirectoryServices.AccountManagement.IdentityType]::DistinguishedName         
                    $otherComputerProperties = [System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($context, $idType, $computerObject.DistinguishedName) | Select LastPasswordSet
                    $computerObject.PwdLastSet = $otherComputerProperties.LastPasswordSet
                   
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
