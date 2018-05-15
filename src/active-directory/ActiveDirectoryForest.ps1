#region Functions

function Get-ADCurrentForest
{
    $forestDetails = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
    $forestDetails
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