function Get-ExchangeImapPopSettings
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $discoveredImapPopSettings = @()
    $ldapFilter = "(|(objectClass=protocolCfgIMAP)(objectClass=protocolCfgPOP))"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchSecureBindings", "msExchServerBindings", "portNumber"
    $exchangeImapPopSettings = Search-Directory -Context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($exchangeImapPopSetting in $exchangeImapPopSettings)
    {
        $imapPopSetting = $null
        $imapPopSetting = "" | Select-Object ObjectGUID, ExternalConnectionSetting, InternalConnectionSetting, X509CertificateName, SecureBindings, ServerBindings, portNumber
        $imapPopSetting.ObjectGUID = [GUID]$( $exchangeImapPopSetting.objectGUID | Select-Object -First 1 )
        $imapPopSetting.SecureBindings = $exchangeImapPopSetting.msExchSecureBindings
        $imapPopSetting.ServerBindings = $exchangeImapPopSetting.msExchServerBindings
        $imapPopSetting.portNumber = $exchangeImapPopSetting.portNumber

        $discoveredImapPopSettings += $imapPopSetting
    }

    $discoveredImapPopSettings
}