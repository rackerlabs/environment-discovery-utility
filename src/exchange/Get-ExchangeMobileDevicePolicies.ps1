function Get-ExchangeMobileDevicePolicies
{
    <#

        .SYNOPSIS
            Discover Exchange Mobile Device Policies.

        .DESCRIPTION
            Uses native Exchange cmdlets to discover Mobile / ActiveSync Device Policies.

        .OUTPUTS
            Returns a custom object containing Mobile Device Policies.

        .EXAMPLE
            Get-ExchangeMobileDevicePolicies

    #>

    [CmdletBinding()]
    param ()

    $activity = "Mobile Device Policies"
    $discoveredMobileDevicePolicies = @()

    try
    {
        $exchangeManagementShellVersion = Get-ExchangeManagementShellVersion
        Write-Log -Level "INFO" -Activity $activity -Message "Gathering Exchange Mobile Device Policies." -WriteProgress

        if ($exchangeManagementShellVersion -like "15*")
        {
            $MobileDevicePolicies = Get-MobileDeviceMailboxPolicy
        }
        else
        {
            $MobileDevicePolicies = Get-ActiveSyncMailboxPolicy
        }        
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to run Get-MobileDeviceMailboxPolicy. $($_.Exception.Message)"
        return
    }
    
    foreach ($mobileDevicePolicy in $mobileDevicePolicies)
    {
        $currentMobileDevicePolicy = "" | Select-Object Guid, Name, Default
        $currentMobileDevicePolicy.Name = $mobileDevicePolicy.Name
        $currentMobileDevicePolicy.Guid = [guid]$mobileDevicePolicy.Guid
        $currentMobileDevicePolicy.Default = $mobileDevicePolicy.isDefault
        $discoveredMobileDevicePolicies += $currentMobileDevicePolicy
    }

    $discoveredMobileDevicePolicies
}