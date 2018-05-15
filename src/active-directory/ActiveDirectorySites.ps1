#region Script Variables

[array] $Script:siteLinks = @()

#endregion

#region Functions
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

#endRegion