function Get-ExchangeServers
{
    <#

        .SYNOPSIS
            Discover all Exchange servers in an Active Directory forest.

        .DESCRIPTION
            Uses Exchange PowerShell to enumerate Exchange servers.

        .OUTPUTS
            Returns a custom object containing Exchange server settings.

        .EXAMPLE
            Get-ExchangeServers

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Servers"
    $discoveredExchangeServers = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Discovering Exchange servers." -WriteProgress
        $exchangeServers = Get-ExchangeServer
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
            $currentServer = "" | Select-Object Name, Version, Edition, InstalledRoles, Site, Domain, DistinguishedName
            $currentServer.Name = $exchangeServer.name
            $currentServer.Version = $exchangeServer.AdminDisplayVersion
            $currentServer.Edition = $exchangeServer.Edition
            $currentServer.InstalledRoles = $exchangeServer.ServerRole
            $currentServer.Site = $exchangeServer.Site
            $currentServer.Domain = $exchangeServer.Domain
            $currentServer.DistinguishedName = $exchangeServer.DistinguishedName

            $discoveredExchangeServers += $currentServer
        }
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "No Exchange servers detected.  This condition should not occur."
    }

    Write-Log -Level "INFO" -Activity $activity -Message "Exchange Server Count: $($discoveredExchangeServers.Count)"

    $discoveredExchangeServers
}
