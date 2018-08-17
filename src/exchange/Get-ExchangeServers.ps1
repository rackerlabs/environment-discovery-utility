function Get-ExchangeServers
{
    <#

        .SYNOPSIS
            Discover all Exchange servers in an Active Directory forest.

        .DESCRIPTION
            Uses LDAP queries run against the Active Directory configuration partition to find all Exchange servers.

        .OUTPUTS
            Returns a custom object containing Exchange server settings.

        .EXAMPLE
            Get-ExchangeServers -DomainDN $domainDN

    #>

    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Exchange Servers"
    $discoveredExchangeServers = @()
    $searchRoot = "CN=Configuration,$DomainDN"
    $ldapFilter = "(&(objectClass=msExchExchangeServer)(msExchCurrentServerRoles=*)(!(objectClass=msExchExchangeTransportServer)))"
    $context = "LDAP://CN=Configuration,$DomainDN"
    [array]$properties = "name", "serialNumber", "msExchMDBAvailabilityGroupLink", "msExchCurrentServerRoles", "msExchServerSite", "whenCreated", "distinguishedName"

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Searching Active Directory for Exchange servers." -WriteProgress
        $exchangeServers = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Exchange servers. $($_.Exception.Message)"
        return
    }

    if ($exchangeServers)
    {

        foreach ($exchangeServer in $exchangeServers)
        {
            $currentServer = "" | Select-Object Name, Version, InstalledRoles, Site, DistinguishedName
            $currentServer.Name = $exchangeServer.name
            $currentServer.Version = $exchangeServer.serialNumber
            $currentServer.Site = $exchangeServer.msExchServerSite
            $currentServer.DistinguishedName = $exchangeServer.distinguishedName
            $currentServer.InstalledRoles = $exchangeServer.msExchCurrentServerRoles

            $discoveredExchangeServers += $currentServer
        }
    }

    $discoveredExchangeServers
}
