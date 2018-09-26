function Get-ExchangeHybridConfig
{
    <#

        .SYNOPSIS
            Discover Hybrid Configuration Settings.
    
        .DESCRIPTION
            Run queries against Exchange to determine Hybrid Configuration settings. 
    
        .OUTPUTS
            Returns a custom object containing Hybrid Configuration status.
    
        .EXAMPLE
            Get-ExchangeHybridConfig
    
    #>

    [CmdletBinding()]
    param ()

    $activity = "Hybrid Configuration"
    $discoveredHybridConfiguration = @()
    $exchangeVersion = (Get-ExchangeServer $(hostname)).AdminDisplayVersion

    if (($exchangeVersion.Major -lt 14) -or ($exchangeVersion.Major -eq 14 -and $exchangeVersion.Minor -lt 3))
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "Querying Exchange for Hybrid Configuration Requires Exchange 2010 SP3 or Higher."
        return
    }

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Querying Exchange for Hybrid Configuration." -WriteProgress
        $exchangeHybridConfig = Get-HybridConfiguration
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for Hybrid Configuration. $($_.Exception.Message)"
        return
    }

    if ($exchangeHybridConfig)
    {
        foreach ($hybridConfig in $exchangeHybridConfig)
        {
            $hybridConfig = "" | Select-Object ObjectGuid, Domains, OnPremisesSmartHost, ClientAccessServers, EdgeTransportServers, ReceivingTransportServers, SendingTransportServers
            $hybridConfig.ObjectGuid = $exchangeHybridConfig.Guid
            $hybridConfig.Domains = $exchangeHybridConfig.Domains
            $hybridConfig.OnPremisesSmartHost = $exchangeHybridConfig.OnPremisesSmartHost
            $hybridConfig.ClientAccessServers = $exchangeHybridConfig.ClientAccessServers
            $hybridConfig.EdgeTransportServers = $exchangeHybridConfig.EdgeTransportServers
            $hybridConfig.ReceivingTransportServers = $exchangeHybridConfig.ReceivingTransportServers
            $hybridConfig.SendingTransportServers = $exchangeHybridConfig.SendingTransportServers

            $discoveredHybridConfiguration += $hybridConfig
        }
    }

    $discoveredHybridConfiguration
}