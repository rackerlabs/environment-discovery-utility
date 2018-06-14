function Get-ExchangeFederationTrust
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Exchange Federation Trusts"
    $discoveredFederationTrusts = @()
    $ldapFilter = "(objectClass=msExchFedTrust)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID"
    [array]$exchangeFederationTrusts = Search-Directory -Context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Federation Trusts." -WriteProgress
        $exchangeFederationTrusts = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Federation Trusts. $($_.Exception.Message)"
        return
    }

    if ($exchangeFederationTrusts)
    {
        foreach ($exchangeFederationTrust in $exchangeFederationTrusts)
        {
            $federationTrust = $null
            $federationTrust = "" | Select-Object ObjectGuid
            $federationTrust.ObjectGuid = [GUID]$($exchangeFederationTrust.objectGUID | Select-Object -First 1)

            $discoveredFederationTrusts += $federationTrust
        }
    }

    $discoveredFederationTrusts
}
