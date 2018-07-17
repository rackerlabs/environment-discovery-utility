function Get-ExchangeAcceptedDomains
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Accepted Domains"
    $discoveredAcceptedDomains = @()
    $searchRoot = "CN=Configuration,$DomainDN"
    $ldapFilter = "(objectClass=msExchAcceptedDomain)"
    $context = "LDAP://CN=Configuration,$DomainDN"
    [array]$properties = "name", "msExchAcceptedDomainFlags", "msExchAcceptedDomainName"

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Accepted Domains." -WriteProgress
        $acceptedDomains = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Accepted Domains. $($_.Exception.Message)"
        return
    }

    if ($acceptedDomains)
    {
        foreach ($acceptedDomain in $acceptedDomains)
        {
            $currentAcceptedDomain = "" | Select-Object Name, AcceptedDomain, AcceptedDomainFlags
            $currentAcceptedDomain.Name = $acceptedDomain.Name
            $currentAcceptedDomain.AcceptedDomain = $acceptedDomain.msExchAcceptedDomainName
            $currentAcceptedDomain.AcceptedDomainFlags = $acceptedDomain.msExchAcceptedDomainFlags | Select-Object -First 1

            $discoveredAcceptedDomains += $currentAcceptedDomain
        }
    }

    $discoveredAcceptedDomains
}
