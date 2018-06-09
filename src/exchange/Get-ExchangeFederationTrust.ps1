function Get-ExchangeFederationTrust
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $discoveredFederationTrusts = @()
    $ldapFilter = "(objectClass=msExchFedTrust)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID"
    $exchangeFederationTrusts = Search-Directory -Context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($exchangefederationTrust in $exchangeFederationTrusts)
    {
        $federationTrust = $null
        $federationTrust = "" | Select-Object objectGUID
        $federationTrust.ObjectGUID = [GUID]$($exchangefederationTrust.objectguid | Select-Object -First 1)

        $discoveredFederationTrusts += $federationTrust
    }

    $discoveredFederationTrusts
}