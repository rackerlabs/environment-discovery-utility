function Get-ExchangeFederation
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDn
    )

    $discoveredFederationSettings = @()
    $ldapFilter = "(objectClass=msexchfedsharingrelationship)"
    $context = "LDAP://CN=Configuration, $($domainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchFedEnabledActions", "msEXchFedIsEnabled"
    $exchangeFederationPolicys = Search-Directory -Context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($exchangeGederationPolicy in $exchangeFederationPolicys)
    {
        $federationPolicy = $null
        $federationPolicy = "" | Select-Object ObjectGUID, FederationEnabled, FederationActions
        $federationPolicy.ObjectGUID = [GUID]$($exchangeGederationPolicy.objectGUID | Select-Object -First 1)
        $federationPolicy.FederationEnabled = $exchangeGederationPolicy.msEXchFedIsEnabled
        $federationPolicy.FederationActions = $exchangeGederationPolicy.msExchFedEnabledActions

        $discoveredFederationSettings += $federationPolicy
    }

    $discoveredFederationSettings
}