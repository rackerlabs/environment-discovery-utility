[array] $Script:siteLinks = @()

function Get-ActiveDirectorySiteLinkDetails
{
    [CmdletBinding()]
    param (
        [System.DirectoryServices.ActiveDirectory.ActiveDirectorySiteLink]
        $SiteLink
    )

    $siteLinkDetails = "" | Select-Object Name, TransportType, Cost, Sites, ReplicationInterval, ReciprocalReplicationEnabled, NotificationEnabled, DataCompressionEnabled
    $sites = @()

    foreach ($site in $SiteLink.Sites)
    {
        $sites += $site.Name
    }

    $siteLinkDetails.Name = $SiteLink.Name
    $siteLinkDetails.TransportType = $SiteLink.TransportType.ToString()
    $siteLinkDetails.Sites = $sites
    $siteLinkDetails.Cost = $SiteLink.Cost
    $siteLinkDetails.ReplicationInterval = $SiteLink.ReplicationInterval.ToString()
    $siteLinkDetails.ReciprocalReplicationEnabled = $SiteLink.ReciprocalReplicationEnabled
    $siteLinkDetails.NotificationEnabled = $SiteLink.NotificationEnabled
    $siteLinkDetails.DataCompressionEnabled = $SiteLink.DataCompressionEnabled

    if (-not $($Script:SiteLinks | Where-Object{$_.Name -like $siteLinkDetails.Name}))
    {
        $Script:SiteLinks += $siteLinkDetails
    }

    $siteLinkDetails
}

function Get-ActiveDirectorySiteDetails
{
    [CmdletBinding()]
    param (
        [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]
        $Site
    )

    $siteDetails = "" | Select-Object Name,AdjacentSites,SiteLinks,Subnets
    $adjacentSites = @()
    $subnets = @()
    $siteLinks = @()

    foreach ($adjacentSite in $Site.AdjacentSites)
    {
        $adjacentSites += $adjacentSite.Name
    }

    foreach ($subnet in $Site.Subnets)
    {
        $subnets += $subnet.Name.ToString()
    }

    foreach ($siteLink in $Site.SiteLinks)
    {
        $siteLink = Get-ActiveDirectorySiteLinkDetails $siteLink
        $siteLinks += $siteLink.Name
    }

    $siteDetails.Name = $Site.Name
    $siteDetails.AdjacentSites = $adjacentSites
    $siteDetails.Subnets = $subnets
    $siteDetails.SiteLinks = $siteLinks

    $siteDetails
}

function Get-ActiveDirectorySites
{
    [CmdletBinding()]
    param (
        [System.DirectoryServices.ActiveDirectory.ReadOnlySiteCollection]
        $Sites
    )

    $processedSites = @()

    foreach ($site in $Sites)
    {
        $processedSites += Get-ActiveDirectorySiteDetails $site
    }

    $processedSites
}
