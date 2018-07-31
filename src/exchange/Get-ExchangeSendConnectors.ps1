function Get-ExchangeSendConnectors
{
    <#
    .SYNOPSIS
        Discover all send connector settings within Exchange.

    .DESCRIPTION
        Uses LDAP queries run against the Active Directory configuration partition to discover all Exchange send connector settings.

    .OUTPUTS
        Returns a custom object containing key settings for Exchange send connectors.

    .EXAMPLE
        Get-ExchangeSendConnectors -DomainDN $domainDN
    #>

    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Send Connectors"
    $discoveredSendConnectors = @()
    $ldapFilter = "(objectClass=msExchRoutingSMTPConnector)"
    $context = "LDAP://CN=Configuration,$DomainDN"
    [array]$properties = "objectGUID", "msExchSmtpSendPort", "msExchSmtpSendTlsDomain", "msExchSmtpSendConnectionTimeout", "msExchSmtpMaxMessagesPerConnection"

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Send Connector Settings." -WriteProgress
        $sendConnectorSettings = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $DomainDN
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Send Connector Settings. $($_.Exception.Message)"
        return
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
