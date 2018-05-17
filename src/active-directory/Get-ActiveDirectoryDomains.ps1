function Get-ActiveDirectoryDomainDetails
{
    [CmdletBinding()]
    param (
        [System.DirectoryServices.ActiveDirectory.ActiveDirectoryPartition]
        $Domain
    )

    $childDomains = @()
    $parentDomain = $null

    foreach ($childDomain in $Domain.Children)
    {
        $childDomains += $childDomain.Name
    }

    if ($Domain.Parent -ne $null)
    {
        $parentDomain = $domain.Parent.Name
    }

    $domainDetails = "" | Select-Object Name,DomainMode,PdcRoleOwner,RidRoleOwner,InfrastructureRoleOwner,Parent,Children,DomainControllers
    $domainDetails.Name = $Domain.Name
    $domainDetails.DomainMode = $Domain.DomainMode.ToString()
    $domainDetails.PdcRoleOwner = $Domain.PdcRoleOwner.Name.ToString()
    $domainDetails.RidRoleOwner = $Domain.RidRoleOwner.Name.ToString()
    $domainDetails.InfrastructureRoleOwner = $Domain.InfrastructureRoleOwner.Name.ToString()
    $domainDetails.Children = $childDomains
    $domainDetails.Parent = $parentDomain

    $domainDetails
}

function Get-ActiveDirectoryDomains
{
    [CmdletBinding()]
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