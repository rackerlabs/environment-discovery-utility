function Get-ExchangeSMTPSettings
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "SMTP Settings"
    $discoveredSMTPSettings = @()
    $ldapFilter = "(objectClass=msExchSmtpReceiveConnector)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchSmtpReceiveBindings", "msExchSmtpReceiveConnectionInactivityTimeout", "msExchSmtpReceiveConnectionTimeout", "msExchSmtpReceiveMaxMessageSize", "msExchSmtpReceiveMaxRecipientsPerMessage"
    
    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Pop/Imap Settings." -WriteProgress
        $exchangeSMTPSettings = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Pop/IMAP Settings. $($_.Exception.Message)"
        return
    }

    foreach ($exchangeSMTPSetting in $exchangeSMTPSettings)
    {
        $smtpSettings = $null
        $smtpSettings = ""| Select-Object ConnectorGUID, SMTPReceiveBindings, SMTPInactivityTimeOut, ConnectionTimeout, MaxMessageSize, MaxRecipientsPerMessage 
        $smtpSettings.ConnectorGUID = [GUID]$($exchangeSMTPSetting.objectGUID | Select-Object -First 1)
        $smtpSettings.SMTPReceiveBindings = $exchangeSMTPSetting.msExchSmtpReceiveBindings
        $smtpSettings.SMTPInactivityTimeOut = $exchangeSMTPSetting.msExchSmtpReceiveConnectionInactivityTimeout
        $smtpSettings.ConnectionTimeout = $exchangeSMTPSetting.msExchSmtpReceiveConnectionTimeout
        $smtpSettings.MaxMessageSize = $exchangeSMTPSetting.msExchSmtpReceiveMaxMessageSize
        $smtpSettings.MaxRecipientsPerMessage = $exchangeSMTPSetting.msExchSmtpReceiveMaxRecipientsPerMessage
        
        $discoveredSMTPSettings += $smtpSettings
    }

    $discoveredSMTPSettings
}