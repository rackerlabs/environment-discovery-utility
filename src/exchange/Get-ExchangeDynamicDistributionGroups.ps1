function Get-ExchangeDynamicDistributionGroups
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $ldapFilter = "(objectClass=msExchDynamicDistributionList)"
    $context = "LDAP://$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchGroupMemberCount"

    $exchangeDynamicDistributionGroups = Search-Directory -Context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    $discoveredDynamicDitributionGroups = @()

    foreach ($exchangeDynamicDistributionGroup in $exchangeDynamicDistributionGroups)
    {
        $dynamicDistributionGroup = $null
        $dynamicDistributionGroup = ""| Select-Object ObjectGUID, GroupMemberCount
        $dynamicDistributionGroup.ObjectGUID = [GUID]$($exchangeDynamicDistributionGroup.objectGUID | Select-Object -First 1)
        $dynamicDistributionGroup.GroupMemberCount = $exchangeDynamicDistributionGroup.msExchGroupMemberCount
        
        $discoveredDynamicDitributionGroups += $dynamicDistributionGroup
    }
    
    $discoveredDynamicDitributionGroups
}