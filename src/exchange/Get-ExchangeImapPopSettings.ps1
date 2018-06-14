function Get-ExchangeImapPopSettings
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Pop/IMAP Settings"
    $discoveredImapPopSettings = @()
    $ldapFilter = "(|(objectClass=protocolCfgIMAP)(objectClass=protocolCfgPOP))"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchSecureBindings", "msExchServerBindings", "portNumber"
    
    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Pop/Imap Settings." -WriteProgress
        $exchangeImapPopSettings = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Pop/IMAP Settings. $($_.Exception.Message)"
        return
    }

    if ($exchangeImapPopSettings)
    {
        foreach ($exchangeImapPopSetting in $exchangeImapPopSettings)
        {
            $imapPopSetting = $null
            $imapPopSetting = "" | Select-Object ObjectGuid, SecureBindings, ServerBindings, Port
            $imapPopSetting.ObjectGuid = [GUID]$($exchangeImapPopSetting.objectGUID | Select-Object -First 1)
            $imapPopSetting.SecureBindings = $exchangeImapPopSetting.msExchSecureBindings
            $imapPopSetting.ServerBindings = $exchangeImapPopSetting.msExchServerBindings
            $imapPopSetting.Port = $exchangeImapPopSetting.portNumber

            $discoveredImapPopSettings += $imapPopSetting
        }
    }

    $discoveredImapPopSettings
}
