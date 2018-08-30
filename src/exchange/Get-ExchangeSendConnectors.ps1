function Get-ExchangeSendConnectors
{
    <#

        .SYNOPSIS
            Discover all send connector settings within Exchange.

        .DESCRIPTION
            Query Exchange to discover all Exchange send connector settings.

        .OUTPUTS
            Returns a custom object containing key settings for Exchange send connectors.

        .EXAMPLE
            Get-ExchangeSendConnectors

    #>

    [CmdletBinding()]
    param ()

    $activity = "Send Connectors"
    $discoveredSendConnectors = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Getting Send Connector Settings." -WriteProgress
        $sendConnectorSettings = Get-SendConnector
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to get Send Connector Settings. $($_.Exception.Message)"
        return
    }

    if ($sendConnectorSettings)
    {
        foreach ($sendConnectorSetting in $sendConnectorSettings)
        {
            $sendConnector = $null
            $sendConnector = ""| Select-Object SmtpSendPort, ConnectionTimeout, MaxMessagesPerConnection, Fqdn, Enabled, MaxMessageSize, UseExternalDNSServersEnabled, AddressSpaces, SmartHostString, RequireTLS, DomainSecureEnabled
            $sendConnector.SmtpSendPort = $sendConnectorSetting.Port
            $sendConnector.ConnectionTimeout = $sendConnectorSetting.ConnectionInactivityTimeOut
            $sendConnector.MaxMessagesPerConnection = $sendConnectorSetting.SmtpMaxMessagesPerConnection
            $sendConnector.Fqdn = $sendConnectorSetting.Fqdn
            $sendConnector.Enabled = $sendConnectorSetting.Enabled
            $sendConnector.MaxMessageSize = $sendConnectorSetting.MaxMessageSize
            $sendConnector.UseExternalDNSServersEnabled = $sendConnectorSetting.UseExternalDNSServersEnabled
            $sendConnector.AddressSpaces = $sendConnectorSetting.AddressSpaces
            $sendConnector.SmartHostString = $sendConnectorSetting.SmartHostString
            $sendConnector.RequireTLS = $sendConnectorSetting.RequireTLS
            $sendConnector.DomainSecureEnabled = $sendConnectorSetting.DomainSecureEnabled

            $discoveredSendConnectors += $sendConnector
        }
    }

    $discoveredSendConnectors
}
