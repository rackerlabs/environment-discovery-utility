function Get-ActiveDirectoryDomainDetails
{
    <#

        .SYNOPSIS
            Discover Active Directory attributes for a single domain.

        .DESCRIPTION
            Extract key attributes from a ActiveDirectoryPartition object for an Active Directory domain.

        .OUTPUTS
            Returns a custom object containing details for the requested Active Directory domain.

        .EXAMPLE
            Get-ActiveDirectoryDomainDetails -Domain $domain

    #>
    
    # The Active Directory domain to process.
    [CmdletBinding()]
    param (
        [System.DirectoryServices.ActiveDirectory.ActiveDirectoryPartition]
        $Domain
    )

    [array]$childDomains = @()
    $parentDomain = $null

    foreach ($childDomain in $Domain.Children)
    {
        $childDomains += $childDomain.Name
    }

    if ($Domain.Parent -ne $null)
    {
        $parentDomain = $domain.Parent.Name
    }

    $domainDetails = "" | Select-Object Name, Mode, PdcRoleOwner, RidRoleOwner, InfrastructureRoleOwner, Parent, Children, DomainControllers
    $domainDetails.Name = $Domain.Name
    $domainDetails.Mode = $Domain.DomainMode.ToString()
    $domainDetails.PdcRoleOwner = $Domain.PdcRoleOwner.Name.ToString()
    $domainDetails.RidRoleOwner = $Domain.RidRoleOwner.Name.ToString()
    $domainDetails.InfrastructureRoleOwner = $Domain.InfrastructureRoleOwner.Name.ToString()
    $domainDetails.Children = $childDomains
    $domainDetails.Parent = $parentDomain
    $domainDetails.DomainControllers = [array]$Domain.DomainControllers | Select-Object @{Name='Roles';expression={[array]$_.Roles}}, SiteName, OSVersion

    $domainDetails
}

function Get-ActiveDirectoryDomains
{
    <#

        .SYNOPSIS
            Iterates through a list of Active Directory domains.

        .DESCRIPTION
            List all domains in an Active Directory DomainCollection, pass each one to Get-ActiveDirectoryDomainDetails for further analysis.

        .OUTPUTS
            A custom object containing a list of Active Directory domains with their key attributes.

        .EXAMPLE
            Get-ActiveDirectoryDomains -Domains $forest.Domains

    #>
    
    # List of active directory domains using [System.DirectoryServices.ActiveDirectory.DomainCollection].
    [CmdletBinding()]    
    [Parameter(Mandatory=$true)]
    param (
        [System.DirectoryServices.ActiveDirectory.DomainCollection]
        $Domains
    )

    $forestDomains = @()

    foreach ($domain in $Domains)
    {
        $forestDomains += Get-ActiveDirectoryDomainDetails $domain
    }

    $forestDomains
}
