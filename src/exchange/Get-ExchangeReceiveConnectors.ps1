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
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchSmtpReceiveBindings", "msExchSmtpReceiveConnectionInactivityTimeout", "msExchSmtpReceiveConnectionTimeout", "msExchSmtpReceiveMaxMessageSize", "msExchSmtpReceiveMaxRecipientsPerMessage"
    
    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Receive Connector Settings." -WriteProgress
        $receiveConnectorSettings = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Receive Connector Settings. $($_.Exception.Message)"
        return
    }

    foreach ($receiveConnectorSetting in $receiveConnectorSettings)
    {
        $receiveConnector = $null
        $receiveConnector = ""| Select-Object ConnectorGUID, SMTPReceiveBindings, SMTPInactivityTimeOut, ConnectionTimeout, MaxMessageSize, MaxRecipientsPerMessage 
        $receiveConnector.ConnectorGUID = [GUID]$($receiveConnectorSetting.objectGUID | Select-Object -First 1)
        $receiveConnector.SMTPReceiveBindings = $receiveConnectorSetting.msExchSmtpReceiveBindings
        $receiveConnector.SMTPInactivityTimeOut = $receiveConnectorSetting.msExchSmtpReceiveConnectionInactivityTimeout
        $receiveConnector.ConnectionTimeout = $receiveConnectorSetting.msExchSmtpReceiveConnectionTimeout
        $receiveConnector.MaxMessageSize = $receiveConnectorSetting.msExchSmtpReceiveMaxMessageSize
        $receiveConnector.MaxRecipientsPerMessage = $receiveConnectorSetting.msExchSmtpReceiveMaxRecipientsPerMessage
        
        $discoveredReceiveConnectors += $receiveConnector
    }

    $discoveredReceiveConnectors
}