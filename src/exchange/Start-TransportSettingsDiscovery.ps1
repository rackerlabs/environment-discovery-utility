function Start-TransportSettingsDiscovery
{
    <#
    .SYNOPSIS
        This cmdlet will return information related to the configuration and state of Transport Settings in the environment.

    .DESCRIPTION
        This cmdlet will return information related to the configuration and state of Transport Settings in the environment.

    .OUTPUTS
        A PSObject representation of the discovered Transport Settingss.

    .EXAMPLE
        Start-TransportSettingsDiscovery
    #>

    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )
    begin
    {
        Write-Log -Level "VERBOSE" -Activity "Transport Settings Discovery" -Message "Attempting Transport Settings Discovery." -WriteProgress
        $transportSettings = @{}
    }
    process
    {
        $transportSettings.Add("RecieveConnectors", $(Get-ExchangeReceiveConnectors -DomainDN $DomainDN))
        $transportSettings.Add("SendConnectors", $(Get-ExchangeSendConnectors -DomainDN $DomainDN))
        Write-Log -Level "VERBOSE" -Activity "Transport Settings Discovery" -Message "Completed Transport Settings Discovery." -WriteProgress

        $transportSettings
    }
}


