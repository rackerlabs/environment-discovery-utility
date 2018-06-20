function Get-ExchangeReceiveConnectors
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Receive Connectors"
    $discoveredReceiveConnectors = @()
    $ldapFilter = "(objectClass=msExchSmtpReceiveConnector)"
    $context = "LDAP://CN=Configuration,$DomainDN"
    [array]$properties = "objectGUID", "msExchSmtpReceiveBindings", "msExchSmtpReceiveConnectionInactivityTimeout", "msExchSmtpReceiveConnectionTimeout", "msExchSmtpReceiveMaxMessageSize", "msExchSmtpReceiveMaxRecipientsPerMessage"

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Receive Connector Settings." -WriteProgress
        $receiveConnectorSettings = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $DomainDN
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Receive Connector Settings. $($_.Exception.Message)"
        break
    }

    foreach ($receiveConnectorSetting in $receiveConnectorSettings)
    {
        $receiveConnector = $null
        $receiveConnector = ""| Select-Object ConnectorGuid, SmtpReceiveBindings, SmtpInactivityTimeOut, ConnectionTimeout, MaxMessageSize, MaxRecipientsPerMessage
        $receiveConnector.ConnectorGuid = [GUID]$($receiveConnectorSetting.objectGUID | Select-Object -First 1)
        $receiveConnector.SmtpReceiveBindings = $receiveConnectorSetting.msExchSmtpReceiveBindings
        $receiveConnector.SmtpInactivityTimeOut = $receiveConnectorSetting.msExchSmtpReceiveConnectionInactivityTimeout
        $receiveConnector.ConnectionTimeout = $receiveConnectorSetting.msExchSmtpReceiveConnectionTimeout
        $receiveConnector.MaxMessageSize = $receiveConnectorSetting.msExchSmtpReceiveMaxMessageSize
        $receiveConnector.MaxRecipientsPerMessage = $receiveConnectorSetting.msExchSmtpReceiveMaxRecipientsPerMessage

        $discoveredReceiveConnectors += $receiveConnector
    }

    $discoveredReceiveConnectors
}
