function Get-ExchangeReceiveConnectors
{
    <#

        .SYNOPSIS
            Discovers Exchange receive connector settings.

        .DESCRIPTION
            Query Exchange to find all Exchange receive connector settings.

        .OUTPUTS
            Returns a custom object containing several key settings for the receive connectors.

        .EXAMPLE
            Get-ExchangereceiveConnectors

    #>

    [CmdletBinding()]
    param ()

    $activity = "Receive Connectors"
    $discoveredReceiveConnectors = @()
    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Getting Receive Connector Settings." -WriteProgress
        $receiveConnectorSettings = Get-ReceiveConnector  
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to get Receive Connector Settings. $($_.Exception.Message)"
        return
    }

    foreach ($receiveConnectorSetting in $receiveConnectorSettings)
    {
        $receiveConnector = $null
        $receiveConnector = ""| Select-Object ConnectorGuid, SmtpReceiveBindings, SmtpInactivityTimeOut, ConnectionTimeout, MaxMessageSize, MaxRecipientsPerMessage, PermissionGroups, AuthMechanism, Enabled, Fqdn, TransportRole, Server
        $receiveConnector.ConnectorGuid = [GUID]$($receiveConnectorSetting.GUID | Select-Object -First 1)
        $receiveConnector.SmtpReceiveBindings = $receiveConnectorSetting.Bindings
        $receiveConnector.SmtpInactivityTimeOut = $receiveConnectorSetting.ConnectionInactivityTimeout
        $receiveConnector.ConnectionTimeout = $receiveConnectorSetting.ConnectionTimeout
        $receiveConnector.MaxMessageSize = $receiveConnectorSetting.MaxMessageSize
        $receiveConnector.MaxRecipientsPerMessage = $receiveConnectorSetting.MaxRecipientsPerMessage
        $receiveConnector.PermissionGroups = $receiveConnectorSetting.PermissionGroups
        $receiveConnector.AuthMechanism = $receiveConnectorSetting.AuthMechanism
        $receiveConnector.Enabled = $receiveConnectorSetting.Enabled
        $receiveConnector.Fqdn = $receiveConnectorSetting.Fqdn
        $receiveConnector.TransportRole = $receiveConnectorSetting.TransportRole
        $receiveConnector.Server = $receiveConnectorSetting.Server

        $discoveredReceiveConnectors += $receiveConnector
    }

    $discoveredReceiveConnectors
}
