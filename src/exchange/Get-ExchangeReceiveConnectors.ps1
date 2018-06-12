function Get-ExchangeReceiveConnectors
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Receive Connector Settings"
    $discoveredReceiveConnectorSettings = @()
    $ldapFilter = "(objectClass=msExchSmtpReceiveConnector)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchSmtpReceiveBindings", "msExchSmtpReceiveConnectionInactivityTimeout", "msExchSmtpReceiveConnectionTimeout", "msExchSmtpReceiveMaxMessageSize", "msExchSmtpReceiveMaxRecipientsPerMessage"
    
    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Receive Connector Settings." -WriteProgress
        $exchangeReceiveConnectorSettings = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Receive Connector Settings. $($_.Exception.Message)"
        return
    }

    foreach ($exchangeReceiveConnectorSetting in $exchangeReceiveConnectorSettings)
    {
        $receiveConnectorSettings = $null
        $receiveConnectorSettings = ""| Select-Object ConnectorGUID, SMTPReceiveBindings, SMTPInactivityTimeOut, ConnectionTimeout, MaxMessageSize, MaxRecipientsPerMessage 
        $receiveConnectorSettings.ConnectorGUID = [GUID]$($exchangeReceiveConnectorSetting.objectGUID | Select-Object -First 1)
        $receiveConnectorSettings.SMTPReceiveBindings = $exchangeReceiveConnectorSetting.msExchSmtpReceiveBindings
        $receiveConnectorSettings.SMTPInactivityTimeOut = $exchangeReceiveConnectorSetting.msExchSmtpReceiveConnectionInactivityTimeout
        $receiveConnectorSettings.ConnectionTimeout = $exchangeReceiveConnectorSetting.msExchSmtpReceiveConnectionTimeout
        $receiveConnectorSettings.MaxMessageSize = $exchangeReceiveConnectorSetting.msExchSmtpReceiveMaxMessageSize
        $receiveConnectorSettings.MaxRecipientsPerMessage = $exchangeReceiveConnectorSetting.msExchSmtpReceiveMaxRecipientsPerMessage
        
        $discoveredReceiveConnectorSettings += $receiveConnectorSettings
    }

    $discoveredReceiveConnectorSettings
}