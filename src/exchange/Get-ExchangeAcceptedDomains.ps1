function Get-ExchangeAcceptedDomains
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = 'Accepted Domain Discovery'
    $discoveredAcceptedDomains = @()
    $searchRoot = "CN=Configuration,$($DomainDN)"
    $ldapFilter = "(objectClass=msExchAcceptedDomain)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    [array]$properties = "name", "msExchAcceptedDomainFlags"

    try
    {
        Write-Log -Level 'VERBOSE' -Activity $activity -Message 'Searching Active Directory for Accepted Domains.' -WriteProgress
        $acceptedDomains = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level 'ERROR' -Activity $activity -Message "Failed to search Active Directory for Accepted Domains. $($_.Exception.Message)"
    }

    foreach ($acceptedDomain in $acceptedDomains)
    {
        $currentAcceptedDomain = "" | Select-Object Name,AcceptedDomainFlags
        $currentAcceptedDomain.Name = $acceptedDomain.name
        $currentAcceptedDomain.AcceptedDomainFlags = $acceptedDomain.msExchAcceptedDomainFlags | Select-Object -First 1

        $discoveredAcceptedDomains += $currentAcceptedDomain
    }

    $discoveredAcceptedDomains
}
