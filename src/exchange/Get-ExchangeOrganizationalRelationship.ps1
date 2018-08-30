function Get-ExchangeOrganizationalRelationship
{
    <#

        .SYNOPSIS
            Discover Federation Sharing settings.
    
        .DESCRIPTION
            Run LDAP queries to find Federation Sharing settings in Active Directory.
    
        .OUTPUTS
            Returns a custom object containing federation sharing properties.
    
        .EXAMPLE
            Get-ExchangeOrganizationalRelationship
    
    #>

    [CmdletBinding()]
    param ()

    $activity = "Organizational Relationship"
    $discoveredOrganizationalRelationship = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for Organizational Relationships." -WriteProgress
        $organizationalRelationshipSettings = Get-OrganizationRelationship
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for Organizational Relationships. $($_.Exception.Message)"
        return
    }

    if ($organizationalRelationshipSettings)
    {
        foreach ($organizationalRelationshipSetting in $organizationalRelationshipSettings)
        {
            $organizationalRelationship = $null
            $organizationalRelationship = "" | Select-Object ObjectGuid, Enabled, DomainNames, MailboxMoveEnabled
            $organizationalRelationship.ObjectGuid = $organizationalRelationshipSetting.GUID
            $organizationalRelationship.Enabled = [bool]$organizationalRelationshipSetting.Enabled
            $organizationalRelationship.DomainNames = [array]$organizationalRelationshipSetting.DomainNames
            $organizationalRelationship.MailboxMoveEnabled = [bool]$organizationalRelationshipSetting.MailboxMoveEnabled

            $discoveredOrganizationalRelationship += $organizationalRelationship
        }
    }

    $discoveredOrganizationalRelationship
}
