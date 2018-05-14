#region Script Variables

[array] $Script:siteLinks = @()

#endregion

#region Functions

function Get-ADCurrentForest
{
    $forestDetails = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
    $forestDetails
}

function Get-ADDomainDetails
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

function Get-ADForestDomains
{
    param (
        [System.DirectoryServices.ActiveDirectory.DomainCollection]
        $domains
    )
    
    $forestDomains = @()

    foreach ($domain in $domains)
    {
        $forestDomains += Get-ADDomainDetails $domain
    }
    
    $forestDomains
}

function Get-ADSiteLinkDetails
{
    param (
        [System.DirectoryServices.ActiveDirectory.ActiveDirectorySiteLink]
        $siteLink
    )
    
    $siteLinkDetails = "" | Select-Object Name,TransportType,Cost,Sites,ReplicationInterval,ReciprocalReplicationEnabled,NotificationEnabled,DataCompressionEnabled
    $sites = @()

    foreach ($site in $siteLink.Sites)
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
    
    if (-not $( $Script:siteLinks | Where-Object{$_.Name -like $siteLinkDetails.Name} ))
    {
        $Script:siteLinks += $siteLinkDetails
    }
    
    $siteLinkDetails
}

function Get-ADSiteDetails
{
    param (
        [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]
        $site
    )
     
    $siteDetails = "" | Select-Object Name,AdjacentSites,SiteLinks,Subnets
    $adjacentSites = @()
    $subnets = @()
    $siteLinks = @()
    
    foreach ($adjacentSite in $site.AdjacentSites)
    {
        $adjacentSites += $adjacentSite.Name
    }
    
    foreach ($subnet in $site.Subnets)
    {
        $subnets += $subnet.Name.ToString()
    }
    
    foreach ($siteLink in $site.SiteLinks)
    {
        $siteLink = Get-ADSiteLinkDetails $siteLink
        $siteLinks += $siteLink.Name
    }
    
    $siteDetails.Name = $site.Name
    $siteDetails.AdjacentSites = $adjacentSites
    $siteDetails.Subnets = $subnets
    $siteDetails.SiteLinks = $siteLinks
    
    $siteDetails
}

function Get-ADForestSites
{
    param (
        [System.DirectoryServices.ActiveDirectory.ReadOnlySiteCollection] $sites
    )
    
    $processedSites = @()
    foreach ($site in $sites)
    {
        $processedSites += Get-ADSiteDetails $site
    }
    
    $processedSites
}

function Get-ADForestDetails
{
    $forest = Get-ADCurrentForest
    $domains = Get-ADForestDomains $forest.Domains
    $sites = Get-ADForestSites $forest.Sites
    $applicationPartitions = @()
    
    foreach ($applicationPartition in $forest.ApplicationPartitions)
    {
        $applicationPartitions += $applicationPartition.Name
    }
    
    $forestDetails = "" | Select-Object Name,ForestMode,RootDomain,SchemaRoleOwner,NamingRoleOwner,Schema,ApplicationPartitions,SiteLinks,Domains,Sites
    $forestDetails.Name = $forest.Name
    $forestDetails.ForestMode = $forest.ForestMode.ToString()
    $forestDetails.RootDomain = $forest.RootDomain.ToString()
    $forestDetails.Schema = $forest.Schema.ToString()
    $forestDetails.SchemaRoleOwner = $forest.SchemaRoleOwner.ToString()
    $forestDetails.NamingRoleOwner = $forest.NamingRoleOwner.ToString()
    $forestDetails.Domains = $domains
    $forestDetails.Sites = $sites
    $forestDetails.SiteLinks = $Script:siteLinks
    $forestDetails.ApplicationPartitions = $applicationPartitions
    
    $forestDetails
}

#endregion