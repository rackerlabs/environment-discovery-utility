function Start-ActiveDirectoryDiscovery
{
    <#
    .SYNOPSIS
        This cmdlet will return information related to the current Active Directory Forest as well as its Domains and Sites.

    .DESCRIPTION
        This cmdlet will return information related to the current Active Directory Forest as well as its Domains and Sites.  This is not meant to be run independently and is part of the Environment Discovery Utility package.

    .OUTPUTS
        A PSObject representation of the discovered Active Directory environment.

    .EXAMPLE
        Start-ActiveDirectoryDiscovery
    #>

    [CmdletBinding()]
    param ()
    process
    {
        $forest = Get-ActiveDirectoryCurrentForest

        if ($forest)
        {
            $domains = Get-ActiveDirectoryDomains $forest.Domains
            $sites = Get-ActiveDirectorySites $forest.Sites
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
        }

        $forestDetails
    }
}