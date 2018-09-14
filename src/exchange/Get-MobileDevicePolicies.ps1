function Get-MobileDevicePolicies
{
        <#

        .SYNOPSIS
            Discover Exchange Mobile Device Policies.

        .DESCRIPTION
            Uses native Exchange cmdlets to discover Mobile Device Policies.

        .OUTPUTS
            Returns a custom object containing Mobile Device Policies.

        .EXAMPLE
            Get-MobileDevicePolicies

    #>

    [CmdletBinding()]
    param ()

    $activity = "Mobile Device Policies"
    $discoveredMobileDevicePolicies = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Gathering Exchange Mobile Device Policies." -WriteProgress
        $MobileDevicePolicies = Get-MobileDeviceMailboxPolicy
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to run Get-MobileDeviceMailboxPolicy. $($_.Exception.Message)"
        return
    }
    
    foreach ($MobileDevicePolicy in $MobileDevicePolicies)
    {
        $currentMobileDevicePolicy = "" | Select-Object Guid, Name, Default
        $currentMobileDevicePolicy.Name = $MobileDevicePolicy.Name
        $currentMobileDevicePolicy.Guid = [guid]$MobileDevicePolicy.Guid
        $currentMobileDevicePolicy.Default = $MobileDevicePolicy.isDefault
        $discoveredMobileDevicePolicies += $currentMobileDevicePolicy
    }

    $discoveredMobileDevicePolicies
}