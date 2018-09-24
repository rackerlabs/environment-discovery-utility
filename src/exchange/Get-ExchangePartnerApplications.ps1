function Get-ExchangePartnerApplications
{
    <#

        .SYNOPSIS
            Discover all Exchange partner applications in the on premises deployment.

        .DESCRIPTION
            Uses Exchange PowerShell to enumerate partner applications.

        .OUTPUTS
            Returns an array containing a list of partner applications and their noteworthy properties.

        .EXAMPLE
            Get-ExchangePartnerApplications

    #>
    
    [CmdletBinding()]
    param (
        # An array of Exchange server objects used when checking version number.
        [array]
        $Servers
    )
    
    $activity = "Exchange Partner Applications"
    $discoveredPartnerApps = @()
    
    if ($Servers[0].Version.Major -lt 15)
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Skipping Get-PartnerApplication cmdlet because environment is not Exchange 2013 or higher."
        return
    }
    
    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Discovering Exchange partner applications." -WriteProgress
        [array]$partnerApps = Get-PartnerApplication
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to run the Get-PartnerApplication cmdlet. $($_.Exception.Message)"
        return
    }
    
    if ($partnerApps)
    {
        $partnerApps | ForEach-Object { $discoveredPartnerApps += $_ | Select-Object Name, Enabled, ApplicationIdentifier, AuthMetadataUrl, Realm, UseAuthServer, AcceptSecurityIdentifierInformation, LinkedAccount, IssuerIdentifier, AppOnlyPermissions, ActAsPermissions, AdminDisplayName, Identity, Guid, WhenCreatedUTC, WhenChangedUTC }
    }
    else
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "No partner application(s) found."
    }
    
    Write-Log -Level "INFO" -Activity $activity -Message "Found $($partnerApps.Count) partner application(s)."
    
    $discoveredPartnerApps
}
