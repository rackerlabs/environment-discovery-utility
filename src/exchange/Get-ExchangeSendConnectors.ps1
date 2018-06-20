function Get-ExchangeSendConnectors
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Send Connectors"
    $discoveredSendConnectors = @()
    $ldapFilter = "(objectClass=msExchRoutingSMTPConnector)"
    $context = "LDAP://CN=Configuration,$DomainDN"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchSmtpSendPort", "msExchSmtpSendTlsDomain", "msExchSmtpSendConnectionTimeout", "msExchSmtpMaxMessagesPerConnection"

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Send Connector Settings." -WriteProgress
        $sendConnectorSettings = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Send Connector Settings. $($_.Exception.Message)"
        break
    }

    if ($sendConnectorSettings)
    {
        foreach ($sendConnectorSetting in $sendConnectorSettings)
        {
            $sendConnector = $null
            $sendConnector = ""| Select-Object ConnectorGuid, SmtpSendPort, TlsEnabled, ConnectionTimeout, MaxMessagesPerConnection 
            $sendConnector.ConnectorGuid = [GUID]$($sendConnectorSetting.objectGUID | Select-Object -First 1)
            $sendConnector.SmtpSendPort= $sendConnectorSetting.msExchSmtpSendPort
            $sendConnector.ConnectionTimeout = $sendConnectorSetting.msExchSmtpSendConnectionTimeout
            $sendConnector.MaxMessagesPerConnection = $sendConnectorSetting.msExchSmtpMaxMessagesPerConnection

            if ($sendConnectorSetting.msExchSmtpSendTlsDomain)
            {
                $sendConnector.TlsEnabled = $true
            }
            else
            {
                $sendConnector.TlsEnabled = $false
            }

            $discoveredSendConnectors += $sendConnector
        }
    }

    $discoveredSendConnectors
}
