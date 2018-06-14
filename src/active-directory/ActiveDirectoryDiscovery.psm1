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
    begin
    {
        Write-Log -Level "VERBOSE" -Activity "Active Directory Discovery" -ProgressId $ProgressId -Message "Starting Active Directory Discovery." -WriteProgress
        $activeDirectoryEnvironment = @{}
    }
    process
    {
        $forest = Get-ActiveDirectoryCurrentForest

        if ($forest)
        {
            [array]$domains = Get-ActiveDirectoryDomains $forest.Domains
            [array]$sites = Get-ActiveDirectorySites $forest.Sites
            [array]$applicationPartitions = @()

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
            $forestDetails.Domains = [array]$domains
            $forestDetails.Sites = [array]$sites
            $forestDetails.SiteLinks = [array]$Global:siteLinks
            $forestDetails.ApplicationPartitions = [array]$applicationPartitions
        }

        $activeDirectoryEnvironment.Add("Forest",$forestDetails)
        Write-Log -Level "VERBOSE" -Activity "Active Directory Discovery" -ProgressId $ProgressId -Message "Completed Active Directory Discovery." -ProgressComplete -WriteProgress

        $activeDirectoryEnvironment
    }
}
