function Get-ExchangeOrganizationalRelationship
{
    <#

        .SYNOPSIS
            Discover Federation Sharing settings.
    
        .DESCRIPTION
            Run LDAP queries to find Federation Sharing settings in Active Directory.
    
        .PARAMETER DomainDN
            The current forest distinguished name to use in the LDAP query.

        .OUTPUTS
            Returns a custom object containing federation sharing properties.
    
        .EXAMPLE
            Get-ExchangeOrganizationalRelationship -DomainDN $domainDN
    
    #>

    [CmdletBinding()]
    param (
        [string]
        $DomainDn
    )

    $activity = "Organizational Relationship"
    $discoveredOrganizationalRelationship = @()
    $ldapFilter = "(objectClass=msexchfedsharingrelationship)"
    $context = "LDAP://CN=Configuration,$domainDN"

    [array]$properties = "objectGUID", "msExchFedEnabledActions", "msEXchFedIsEnabled"

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Organizational Relationships." -WriteProgress
        $organizationalRelationshipSettings = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $DomainDN
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Organizational Relationships. $($_.Exception.Message)"
        return
    }

    if ($organizationalRelationshipSettings)
    {
        foreach ($organizationalRelationshipSetting in $organizationalRelationshipSettings)
        {
            $organizationalRelationship = $null
            $organizationalRelationship = "" | Select-Object ObjectGuid, Enabled, EnabledActions
            $organizationalRelationship.ObjectGuid = [GUID]$($organizationalRelationshipSetting.objectGUID | Select-Object -First 1)
            $organizationalRelationship.Enabled = $organizationalRelationshipSetting.msExchFedIsEnabled
            $organizationalRelationship.EnabledActions = $organizationalRelationshipSetting.msExchFedEnabledActions

            $discoveredOrganizationalRelationship += $organizationalRelationship
        }
    }

    $discoveredOrganizationalRelationship
}
