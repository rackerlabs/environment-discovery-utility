function Get-ExchangeClientAccessConfig
{
    <#

        .SYNOPSIS
            Discover Exchange Client Access server settings.

        .DESCRIPTION
            Query Exchange to get all Client Access server settings.

        .OUTPUTS
            Returns a custom object representing key Client Access server properties.

        .EXAMPLE
            Get-ExchangeClientAccessServer

    #>

    [CmdletBinding()]
    param ()

    $activity = "CAS Config"
    $discoveredCASSettings = @()


    try
    {
        $exchangeManagementShellVersion = Get-Command Exsetup.exe
        
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for CAS Config." -WriteProgress

        if (($exchangeManagementShellVersion | where {$_.fileversioninfo.productversion -like "15.1*"}) -ne $null)
        {
            $discoveredCASConfig = Get-ClientAccessService
        }
        else
        {
            $discoveredCASConfig = Get-ClientAccessServer
        }

    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for CAS Config. $($_.Exception.Message)"
        return
    }

    if ($discoveredCASConfig)
    {
        $discoveredCASSetting = "" | Select-Object ObjectGuid, Fqdn, OutlookAnywhereEnabled, AutoDiscoverServiceInternalUri, AutoDiscoverSiteScope
        $discoveredCASSetting.ObjectGuid = $discoveredCASConfig.Guid
        $discoveredCASSetting.Fqdn = $discoveredCASConfig.Fqdn
        $discoveredCASSetting.OutlookAnywhereEnabled = [bool]$discoveredCASConfig.OutlookAnywhereEnabled
        $discoveredCASSetting.AutoDiscoverServiceInternalUri = $discoveredCASConfig.AutoDiscoverServiceInternalUri
        $discoveredCASSetting.AutoDiscoverSiteScope = $discoveredCASConfig.AutoDiscoverSiteScope

        $discoveredCASSettings += $discoveredCASSetting
    }

    $discoveredCASSettings
}
