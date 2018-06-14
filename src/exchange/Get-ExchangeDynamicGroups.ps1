function Get-ExchangeDynamicGroups
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Dynamic Group"
    $discoveredDynamicGroups = @()
    $ldapFilter = "(objectClass=msExchDynamicDistributionList)"
    $context = "LDAP://$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchGroupMemberCount"

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Dynamic Groups." -WriteProgress
        $exchangeDynamicGroups = Search-Directory -Context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Dynamic Groups. $($_.Exception.Message)"
        return
    }

    if ($exchangeDynamicGroups)
    {
        foreach ($exchangeDynamicGroup in $exchangeDynamicGroups)
        {
            $dynamicGroup = $null
            $dynamicGroup = "" | Select-Object ObjectGuid, MemberCount
            $dynamicGroup.ObjectGuid = [GUID]$($exchangeDynamicGroup.objectGUID | Select-Object -First 1)
            $dynamicGroup.MemberCount = $exchangeDynamicGroup.msExchGroupMemberCount

            $discoveredDynamicGroups += $dynamicGroup
        }
    }

    $discoveredDynamicGroups
}
