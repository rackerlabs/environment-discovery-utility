function Get-ExchangeSendConnectors
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Send Connector Settings"
    $discoveredSendConnectorSettings = @()
    $ldapFilter = "(objectClass=msExchRoutingSMTPConnector)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchSmtpSendPort", "msExchSmtpSendTlsDomain", "msExchSmtpSendConnectionTimeout", "msExchSmtpMaxMessagesPerConnection"
    
    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Send Connector Settings." -WriteProgress
        $exchangeSendConnectorSettings = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Send Connector Settings. $($_.Exception.Message)"
        return
    }

    foreach ($exchangeSendConnectorSetting in $exchangeSendConnectorSettings)
    {
        $sendConnectorSettings = $null
        $sendConnectorSettings = ""| Select-Object ConnectorGUID, SMTPSendPort, TLSEnabled, ConnectionTimeout, MaxMessagesPerConnection 
        $sendConnectorSettings.ConnectorGUID = [GUID]$($exchangeSendConnectorSetting.objectGUID | Select-Object -First 1)
        $sendConnectorSettings.SMTPSendPort= $exchangeSendConnectorSetting.msExchSmtpSendPort
        if ($exchangeSendConnectorSetting.msExchSmtpSendTlsDomain)
        {
            $sendConnectorSettings.TLSEnabled = $true
        }
        else 
        {
            $sendConnectorSettings.TLSEnabled = $false
        }
        $sendConnectorSettings.ConnectionTimeout = $exchangeSendConnectorSetting.msExchSmtpSendConnectionTimeout
        $sendConnectorSettings.MaxMessagesPerConnection = $exchangeSendConnectorSetting.msExchSmtpMaxMessagesPerConnection
        
        $discoveredSendConnectorSettings += $sendConnectorSettings
    }

    $discoveredSendConnectorSettings
}