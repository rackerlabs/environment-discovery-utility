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
        $exchangeManagementShellVersion = Get-Command Exsetup.exe
        Write-Log -Level "INFO" -Activity $activity -Message "Gathering Exchange Mobile Device Policies." -WriteProgress

        if ($exchangeManagementShellVersion -like "*15*")
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