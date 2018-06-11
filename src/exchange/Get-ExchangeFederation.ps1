function Get-ExchangeFederation
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDn
    )

    $activity = 'Exchange Federation'
    $discoveredFederationSettings = @()
    $ldapFilter = "(objectClass=msexchfedsharingrelationship)"
    $context = "LDAP://CN=Configuration,$($domainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchFedEnabledActions", "msEXchFedIsEnabled"
    
    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Federation Policies." -WriteProgress
        $exchangeFederationPolicys = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Federation Policies. $($_.Exception.Message)"
    }

    if ($exchangeFederationPolicys)
    {
        foreach ($exchangeGederationPolicy in $exchangeFederationPolicys)
        {
            $federationPolicy = $null
            $federationPolicy = "" | Select-Object ObjectGUID, FederationEnabled, FederationActions
            $federationPolicy.ObjectGUID = [GUID]$($exchangeGederationPolicy.objectGUID | Select-Object -First 1)
            $federationPolicy.FederationEnabled = $exchangeGederationPolicy.msEXchFedIsEnabled
            $federationPolicy.FederationActions = $exchangeGederationPolicy.msExchFedEnabledActions

            $discoveredFederationSettings += $federationPolicy
        }
    }

    $discoveredFederationSettings
}
