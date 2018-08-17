function Get-ExchangeReceiveConnectors
{
    <#

        .SYNOPSIS
            Discovers Exchange recieve connector settings.

        .DESCRIPTION
            Run an LDAP queries against the Active Directory configuration partition which finds all Exchange recieve connector settings.

        .OUTPUTS
            Returns a custom object containing several key settings for the recieve connectors.

        .EXAMPLE
            Get-ExchangeRecieveConnectors -DomainDN $domainDN

    #>

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
        Write-Log -Level "INFO" -Activity $activity -Message "Searching Active Directory for Receive Connector Settings." -WriteProgress
        $receiveConnectorSettings = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $DomainDN
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Receive Connector Settings. $($_.Exception.Message)"
        return
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
