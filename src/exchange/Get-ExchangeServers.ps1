function ConvertTo-ExchangeRoleList
{
    [CmdletBinding()]
    param (
        [int]
        $Roles
    )
    process
    {
        $roleMap = @{
            2  = "MB"
            4  = "CAS"
            16 = "UM"
            32 = "HT"
            64 = "ET"
        }

        $roleMap.Keys | Where-Object{$_ -bAnd $Roles} | ForEach-Object{$roleMap.Get_Item($_)}
    }
}

function Get-ExchangeServers
{
    [CmdletBinding()]
    param (
        [string]
        $Domain
    )

    $discoveredExchangeServers = @()
    $baseDN = "CN=Configuration,$($Domain)"
    $strFilter = "(&(objectClass=msExchExchangeServer)(msExchCurrentServerRoles=*)(!(objectClass=msExchExchangeTransportServer)))"
    $context = "LDAP://CN=Configuration,$($Domain)"
    [array] $properties = "name", "serialNumber", "msExchMDBAvailabilityGroupLink", "msExchCurrentServerRoles", "msExchServerSite", "whenCreated", "distinguishedName"
    $exchangeServers = Search-Directory -context $context -Filter $strFilter -Properties $properties -SearchRoot $baseDN

    foreach ($exchangeServer in $exchangeServers)
    {
        $currentServer = "" | Select-Object Name, Version, DatabaseAvailabilityGroup, InstalledRoles, Site, WhenCreated, DistinguishedName

        $currentServer.Name = $exchangeServer.name
        $currentServer.Version = $exchangeServer.serialNumber
        $currentServer.DatabaseAvailabilityGroup = $exchangeServer.msExchMDBAvailabilityGroupLink
        $currentServer.Site = $exchangeServer.msExchServerSite
        $currentServer.WhenCreated = $exchangeServer.WhenCreated
        $currentServer.DistinguishedName = $exchangeServer.distinguishedName

        if($exchangeServer.msExchCurrentServerRoles)
        {
            [int] $serverRolesMask = $exchangeServer.msExchCurrentServerRoles[0].ToString()
            $currentServer.InstalledRoles = ConvertTo-ExchangeRoleList $serverRolesMask
        }

        $discoveredExchangeServers += $currentServer
    }

    $discoveredExchangeServers
}