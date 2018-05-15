#region Functions

function Get-ActiveDirectoryDomainDetails
{
    param (
        [System.DirectoryServices.ActiveDirectory.ActiveDirectoryPartition]
        $domain
    )
    
    $childDomains = @()
    $parentDomain = $null
    
    foreach ($childDomain in $domain.Children)
    {
        $childDomains += $childDomain.Name
    }
    
    if ($domain.Parent -ne $null)
    {
        $parentDomain = $domain.Parent.Name
    }
    
    $domainDetails = "" | Select-Object Name,DomainMode,PdcRoleOwner,RidRoleOwner,InfrastructureRoleOwner,Parent,Children,DomainControllers
    $domainDetails.Name = $domain.Name
    $domainDetails.DomainMode = $domain.DomainMode.ToString()
    $domainDetails.PdcRoleOwner = $domain.PdcRoleOwner.Name.ToString()
    $domainDetails.RidRoleOwner = $domain.RidRoleOwner.Name.ToString()
    $domainDetails.InfrastructureRoleOwner = $domain.InfrastructureRoleOwner.Name.ToString()
    $domainDetails.Children = $childDomains
    $domainDetails.Parent = $parentDomain
    
    $domainDetails
}

function Get-ActiveDirectoryDomains
{
    param (
        [System.DirectoryServices.ActiveDirectory.DomainCollection]
        $domains
    )
    
    $forestDomains = @()

    foreach ($domain in $domains)
    {
        $forestDomains += Get-ActiveDirectoryDomainDetails $domain
    }
    
    $forestDomains
}

#endregion