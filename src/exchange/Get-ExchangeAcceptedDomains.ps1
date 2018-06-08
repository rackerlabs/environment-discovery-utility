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

    try
    {
        Write-Log -Level 'VERBOSE' -Activity $MyInvocation.MyCommand.Name -Message 'Finding Exchange accepted domains' -WriteProgress
        $acceptedDomains = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level 'ERROR' -Activity $MyInvocation.MyCommand.Name -Message "Failed to get Active Directory Forest information. $($_.Exception.Message)"
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