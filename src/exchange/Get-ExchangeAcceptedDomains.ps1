function Get-ExchangeAcceptedDomains
{
    param (
        [string]
        $DomainDN
    )

    $discoveredAcceptedDomains = @()
    $searchRoot = "CN=Configuration,$($DomainDN)"
    $ldapFilter = "(objectClass=msExchAcceptedDomain)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    [array]$properties = "name", "msExchAcceptedDomainFlags"
    $acceptedDomains = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($acceptedDomain in $acceptedDomains)
    {
        $currentAcceptedDomain = "" | Select-Object Name,AcceptedDomainFlags
        $currentAcceptedDomain.Name = $acceptedDomain.name
        $currentAcceptedDomain.AcceptedDomainFlags = $acceptedDomain.msExchAcceptedDomainFlags | Select-Object -First 1

        $discoveredAcceptedDomains += $currentAcceptedDomain
    }

    $discoveredAcceptedDomains
}