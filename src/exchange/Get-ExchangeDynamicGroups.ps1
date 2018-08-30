function Get-ExchangeDynamicGroups
{
    <#

        .SYNOPSIS
            Discover Exchange dynamic groups.

        .DESCRIPTION
            Query Exchange to find Exchange Dynamic Groups.

        .OUTPUTS
            Returns a custom object containing Exchange dynamic distribution groups.

        .EXAMPLE
            Get-ExchangeDynamicGroups

    #>

    [CmdletBinding()]
    param ()

    $activity = "Dynamic Group"
    $discoveredDynamicGroups = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for Dynamic Groups." -WriteProgress
        $exchangeDynamicGroups = Get-DynamicDistributionGroup -ResultSize Unlimited
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for Dynamic Groups. $($_.Exception.Message)"
        return
    }

    if ($exchangeDynamicGroups)
    {
        foreach ($exchangeDynamicGroup in $exchangeDynamicGroups)
        {
            $dynamicGroup = $null
            $dynamicGroup = "" | Select-Object ObjectGuid, HiddenFromAddressListsEnabled
            $dynamicGroup.ObjectGuid = $exchangeDynamicGroup.GUID
            $dynamicGroup.HiddenFromAddressListsEnabled = $exchangeDynamicGroup.HiddenFromAddressListsEnabled

            $discoveredDynamicGroups += $dynamicGroup
        }
    }

    $discoveredDynamicGroups
}
