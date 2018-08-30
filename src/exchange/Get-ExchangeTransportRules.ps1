function Get-ExchangeTransportRules
{
    <#

        .SYNOPSIS
            Find transport rule settings in Exchange.

        .DESCRIPTION
            Query Exchange to return key settings for Exchange transport rules.

        .OUTPUTS
            Returns a custom object which contains key settings for Exchange transport rules.

        .EXAMPLE
            Get-ExchangeTransportRules

    #>

    [CmdletBinding()]
    param ()

    try
    {
        $ErrorActionPreference = "silentlycontinue"
        $activity = "Transport Rules"
        $discoveredTransportRules = @()

        try
        {
            Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for Transport Rules." -WriteProgress
            $transportRules = Get-TransportRule
        }
        catch
        {
            Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for Transport Rules. $($_.Exception.Message)"
            break
        }
        if ($transportRules)
        {
            foreach ($transportRule in $transportRules)
            {
                $transportRuleSettings = $null
                $transportRuleSettings = "" | Select-Object ObjectGuid, Condition, Exemption, Action, Type
                $transportRuleSettings.ObjectGuid = [GUID]$($transportRule.Guid)

                if (($transportRule.distinguishedName) -like "*TransportVersioned*")
                {
                    $transportRuleSettings.Type = "TransportRule"
                    $objectGuid = [string]($transportRuleSettings).ObjectGuid
                    $exchangeTransportRule = Get-TransportRule -Identity $objectGuid
                    $transportRuleSettings.Condition = ($exchangeTransportRule | Select-Object -ExpandProperty Conditions).name
                    $transportRuleSettings.Exemption = ($exchangeTransportRule | Select-Object -ExpandProperty Exemptions).name
                    $transportRuleSettings.Action = ($exchangeTransportRule | Select-Object -ExpandProperty Actions).name
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
