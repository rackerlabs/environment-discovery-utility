function Get-ExchangeTransportRules
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN,

        [bool]
        $ExchangeShellConnected
    )

    try
    {
        $ErrorActionPreference = "silentlycontinue"
        $activity = 'Exchange Transport Rule Discovery'
        $discoveredTransportRules = @()
        $searchRoot = "CN=Configuration,$($DomainDN)"
        $ldapFilter = "(objectClass=msExchTransportRule)"
        $context = "LDAP://CN=Configuration,$($DomainDN)"
        [array] $properties = "objectGUID", "distinguishedName"

        try
        {
            Write-Log -Level 'VERBOSE' -Activity $activity -Message 'Searching Active Directory for Transport Rules.' -WriteProgress
            $transportRules = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
        }
        catch
        {
            Write-Log -Level 'ERROR' -Activity $activity -Message "Failed to search Active Directory for Transport Rules. $($_.Exception.Message)"
        }

        if ($transportRules)
        {
            foreach ($transportRule in $transportRules)
            {
                $transportRuleSettings = $null
                $transportRuleSettings = "" | Select-Object ObjectGUID, Type, Condition, Exemption, Action
                $transportRuleSettings.ObjectGUID = [GUID]$($transportRule.objectGUID | Select-Object -First 1)

                if (($transportRule.distinguishedName) -like "*TransportVersioned*")
                {
                    $transportRuleSettings.Type = "TransportRule"
                    
                    if ($ExchangeShellConnected)
                    {
                        $objectGuid = [string]($transportRuleSettings).ObjectGUID
                        $exchangeTransportRule = Get-TransportRule -Identity $objectGuid
                        $transportRuleSettings.Condition = ($exchangeTransportRule | Select-Object -ExpandProperty Conditions).name
                        $transportRuleSettings.Exemption = ($exchangeTransportRule | Select-Object -ExpandProperty Exemptions).name
                        $transportRuleSettings.Action = ($exchangeTransportRule | Select-Object -ExpandProperty Actions).name
                    }
                }
                elseif (($transportRule.distinguishedName) -like "*JournalingVersioned*")
                {
                    $transportRuleSettings.Type = "JournalingRule"
                }
                elseif (($transportRule.distinguishedName) -like "*ClassificationDefinitions*")
                {
                    continue
                }
                else
                {
                    $transportRuleSettings.Type = "Other"
                }

                $discoveredTransportRules += $transportRuleSettings
            }
        }
    }

    finally 
    {
        $ErrorActionPreference = "continue"
    }

    $discoveredTransportRules
}