function Get-ExchangeFederationTrust
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Federation Trusts"
    $discoveredFederationTrusts = @()
    $ldapFilter = "(objectClass=msExchFedTrust)"
    $context = "LDAP://CN=Configuration,$DomainDN"
    [array]$properties = "objectGUID"

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Federation Trusts." -WriteProgress
        [array]$exchangeFederationTrusts = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $DomainDN
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Federation Trusts. $($_.Exception.Message)"
        break
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
