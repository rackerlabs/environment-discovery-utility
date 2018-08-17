function Get-ExchangeTransportRules
{
    <#

        .SYNOPSIS
            Find transport rule settings in Exchange.

        .DESCRIPTION
            Runs LDAP queries against the Active Directory configuration partition to return key settings for Exchange transport rules.

        .OUTPUTS
            Returns a custom object which contains key settings for Exchange transport rules.

        .EXAMPLE
            Get-ExchangeTransportRules -DomainDN $domainDN -ExchangeShellConnected $exchangeShellConnected

    #>

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
        $activity = "Transport Rules"
        $discoveredTransportRules = @()
        $searchRoot = "CN=Configuration,$DomainDN"
        $ldapFilter = "(objectClass=msExchTransportRule)"
        $context = "LDAP://CN=Configuration,$DomainDN"
        [array] $properties = "objectGUID", "distinguishedName"

        try
        {
            Write-Log -Level "INFO" -Activity $activity -Message "Searching Active Directory for Transport Rules." -WriteProgress
            $transportRules = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
        }
        catch
        {
            Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Transport Rules. $($_.Exception.Message)"
            break
        }
        if ($transportRules)
        {
            foreach ($transportRule in $transportRules)
            {
                $transportRuleSettings = $null
                $transportRuleSettings = "" | Select-Object ObjectGuid, Type, Condition, Exemption, Action
                $transportRuleSettings.ObjectGuid = [GUID]$($transportRule.objectGUID | Select-Object -First 1)

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
