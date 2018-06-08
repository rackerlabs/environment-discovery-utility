function Get-ExchangeDynamicGroups
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $discoveredDynamicGroups = @()
    $ldapFilter = "(objectClass=msExchDynamicDistributionList)"
    $context = "LDAP://$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID", "msExchGroupMemberCount"

    try
    {
        $exchangeDynamicGroups = Search-Directory -Context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level 'ERROR' -Activity $MyInvocation.MyCommand.Name -Message "Failed to search Active Directory for Dynamic Groups. $($_.Exception.Message)"
    }

    foreach ($exchangeDynamicGroup in $exchangeDynamicGroups)
    {
        $dynamicGroup = $null
        $dynamicGroup = ""| Select-Object ObjectGUID, GroupMemberCount
        $dynamicGroup.ObjectGUID = [GUID]$($exchangeDynamicGroup.objectGUID | Select-Object -First 1)
        $dynamicGroup.GroupMemberCount = $exchangeDynamicGroup.msExchGroupMemberCount

        $discoveredDynamicGroups += $dynamicDistributionGroup
    }

    $discoveredDynamicGroups
}
