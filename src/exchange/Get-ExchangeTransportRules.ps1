function Get-ExchangeTransportRules
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $discoveredTransportRules = @()
    $searchRoot = "CN=Configuration,$($DomainDN)"
    $ldapFilter = "(objectClass=msExchTransportRule)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    [array] $properties = "objectGUID", "distinguishedName", "msExchTransportRuleXml"
    $transportRules = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($transportRule in $transportRules)
    {
        $transportRuleSettings = "" | Select-Object ObjectGUID, Type, RuleXML
        $transportRuleSettings.ObjectGUID = $transportRule.objectGUID
        $transportRuleSettings.RuleXML = $transportRule.msExchTransportRuleXml
        
        if (($transportRule.properties.distinguishedname) -like "*TransportVersioned*")
        {
            $transportRuleSettings.Type = "TransportRule"

        }
        elseif (($transportRule.properties.distinguishedname) -like "*JournalingVersioned*")
        {
            $transportRuleSettings.Type = "JournalingRule"
        }
        elseif (($transportRule.properties.distinguishedname) -like "*ClassificationDefinitions*")
        {
            continue
        }
        else
        {
            $transportRuleSettings.Type = "Other"
        }

        $discoveredTransportRules += $transportRuleSettings
    }

    $discoveredTransportRules
}