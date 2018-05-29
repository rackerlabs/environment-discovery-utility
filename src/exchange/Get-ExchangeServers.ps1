function Get-ExchangeServers
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $discoveredExchangeServers = @()
    $searchRoot = "CN=Configuration,$($DomainDN)"
    $ldapFilter = "(&(objectClass=msExchExchangeServer)(msExchCurrentServerRoles=*)(!(objectClass=msExchExchangeTransportServer)))"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    [array] $properties = "name", "serialNumber", "msExchMDBAvailabilityGroupLink", "msExchCurrentServerRoles", "msExchServerSite", "whenCreated", "distinguishedName"
    $exchangeServers = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($exchangeServer in $exchangeServers)
    {
        $currentServer = "" | Select-Object Name, Version, DatabaseAvailabilityGroup, InstalledRoles, Site, DistinguishedName
        $currentServer.Name = $exchangeServer.name
        $currentServer.Version = $exchangeServer.serialNumber
        $currentServer.DatabaseAvailabilityGroup = $exchangeServer.msExchMDBAvailabilityGroupLink
        $currentServer.Site = $exchangeServer.msExchServerSite
        $currentServer.DistinguishedName = $exchangeServer.distinguishedName
        $currentServer.InstalledRoles = $exchangeServer.msExchCurrentServerRoles

        $discoveredExchangeServers += $currentServer
    }

    $discoveredExchangeServers
}