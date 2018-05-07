#region Functions

Function Get-ADCurrentForest
{
    $forestDetails = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
    return $forestDetails
}

Function Get-ADDomainDetails
{
    Param (
        [System.DirectoryServices.ActiveDirectory.ActiveDirectoryPartition] $domain
    )
    
    $childDomains = @()
    $parentDomain = $null
    
    foreach($childDomain in $domain.Children)
    {
        $childDomains += $childDomain.Name
    }
    
    if($domain.Parent -ne $null)
    {
        $parentDomain = $domain.Parent.Name
    }
    
    $domainDetails = "" | select Name,DomainMode,PdcRoleOwner,RidRoleOwner,InfrastructureRoleOwner,Parent,Children,DomainControllers
    $domainDetails.Name = $domain.Name
    $domainDetails.DomainMode = $domain.DomainMode.ToString()
    $domainDetails.PdcRoleOwner = $domain.PdcRoleOwner.Name.ToString()
    $domainDetails.RidRoleOwner = $domain.RidRoleOwner.Name.ToString()
    $domainDetails.InfrastructureRoleOwner = $domain.InfrastructureRoleOwner.Name.ToString()
    $domainDetails.Children = $childDomains
    $domainDetails.Parent = $parentDomain
    #$domainDetails.DomainControllers
    
    return $domainDetails
}

Function Get-ADForestDomains
{
    Param (
        [System.DirectoryServices.ActiveDirectory.DomainCollection] $domains
    )
    
    $processedDomains = @()
    foreach($domain in $domains)
    {
        $processedDomains += Get-ADDomainDetails $domain
    }
    
    return $processedDomains
}

Function Get-ADSiteLinkDetails
{
    Param (
        [System.DirectoryServices.ActiveDirectory.ActiveDirectorySiteLink] $siteLink
    )
    
    $siteLinkDetails = "" | select Name,TransportType,Cost,Sites,ReplicationInterval,ReciprocalReplicationEnabled,NotificationEnabled,DataCompressionEnabled
    $sites = @()

    foreach($site in $siteLink.Sites)
    {
        $sites += $site.Name
    }
    
    $siteLinkDetails.Name = $siteLink.Name
    $siteLinkDetails.TransportType = $siteLink.TransportType.ToString()
    $siteLinkDetails.Sites = $sites
    $siteLinkDetails.Cost = $siteLink.Cost
    $siteLinkDetails.ReplicationInterval = $siteLink.ReplicationInterval.ToString()
    $siteLinkDetails.ReciprocalReplicationEnabled = $siteLink.ReciprocalReplicationEnabled
    $siteLinkDetails.NotificationEnabled = $siteLink.NotificationEnabled
    $siteLinkDetails.DataCompressionEnabled = $siteLink.DataCompressionEnabled
    
    if(-not $($SiteLinks | ?{$_.Name -like $siteLinkDetails.Name}))
    {
        $SiteLinks += $siteLinkDetails.Name
    }
    
    return $siteLinkDetails
}

Function Get-ADSiteDetails
{
    Param (
        [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite] $site
    )
     
    $siteDetails = "" | select Name,AdjacentSites,SiteLinks,Subnets
    $adjacentSites = @()
    $subnets = @()
    $siteLinks = @()
    
    foreach($adjacentSite in $site.AdjacentSites)
    {
        $adjacentSites += $adjacentSite.Name
    }
    
    foreach($subnet in $site.Subnets)
    {
        $subnets += $subnet.Name.ToString()
    }
    
    foreach($siteLink in $site.SiteLinks)
    {
        $siteLinks += Get-ADSiteLinkDetails $siteLink
    }
    
    $siteDetails.Name = $site.Name
    $siteDetails.AdjacentSites = $adjacentSites
    $siteDetails.Subnets = $subnets
    $siteDetails.SiteLinks = $siteLinks
    
    return $siteDetails
}

Function Get-ADForestSites
{
    Param (
        [System.DirectoryServices.ActiveDirectory.ReadOnlySiteCollection] $sites
    )
    
    $processedSites = @()
    foreach($site in $sites)
    {
        $processedSites += Get-ADSiteDetails $site
    }
    
    return $processedSites
}

Function Get-ADForestDetails
{
    Param (
        [System.DirectoryServices.ActiveDirectory.Forest] $forest
    )
    
    $domains = Get-ADForestDomains $forest.Domains
    $sites = Get-ADForestSites $forest.Sites
    $applicationPartitions = @()
    
    foreach($applicationPartition in $forest.ApplicationPartitions)
    {
        $applicationPartitions += $applicationPartition.Name
    }
    
    $forestDetails = "" | select Name,ForestMode,RootDomain,SchemaRoleOwner,NamingRoleOwner,Schema,ApplicationPartitions,SiteLinks,Domains,Sites
    $forestDetails.Name = $forest.Name
    $forestDetails.ForestMode = $forest.ForestMode.ToString()
    $forestDetails.RootDomain = $forest.RootDomain.ToString()
    $forestDetails.Schema = $forest.Schema.ToString()
    $forestDetails.SchemaRoleOwner = $forest.SchemaRoleOwner.ToString()
    $forestDetails.NamingRoleOwner = $forest.NamingRoleOwner.ToString()
    $forestDetails.Domains = $domains
    $forestDetails.Sites = $sites
    $forestDetails.SiteLinks = $SiteLinks
    $forestDetails.ApplicationPartitions = $applicationPartitions
    
    return $forestDetails
}

#endregion

#region Main Script

$forestDetails = Get-ADForestDetails -Forest (Get-ADCurrentForest)
return $forestDetails

#endregion