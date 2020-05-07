function Get-AzureADDevices
{
    <#

        .SYNOPSIS
            Discover Azure AD devices

        .DESCRIPTION
            Query Azure AD for devices

        .OUTPUTS
            Returns a custom object containing Azure AD devices

        .EXAMPLE
            Get-AzureADDevices

    #>

    [CmdletBinding()]
    param ()

    $activity = "AzureAD Devices"
    $discoveredDevices = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query AzureAD for devices." -WriteProgress
        $devices = Get-AzureAdDevice
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query AzureAD for devices. $($_.Exception.Message)"
        return
    }

    if ($devices)
    {
        foreach ($device in $devices)
        {
            $deviceObject = "" | Select-Object ApproximateLatLogonTimeStamp, DeviceId, DeviceOSType, DeviceOSVersion, DeviceTrustType, DirSyncEnabled, IsCompliant, IsManaged, LastDirSyncTime
            $deviceObject.DeviceId = [string]$device.DeviceId
            $deviceObject.ApproximateLatLogonTimeStamp = [string]$device.ApproximateLatLogonTimeStamp
            $deviceObject.DeviceOSType = [string]$device.DeviceOSType
            $deviceObject.DeviceOSVersion = [string]$device.DeviceOSVersion
            $deviceObject.DeviceTrustType = [string]$device.DeviceTrustType
            $deviceObject.DirSyncEnabled = [string]$device.DirSyncEnabled
            $deviceObject.IsCompliant = [string]$device.IsCompliant
            $deviceObject.IsManaged = [string]$device.IsManaged
            $deviceObject.LastDirSyncTime = [string]$device.LastDirSyncTime

            $discoveredDevices += $deviceObject
            
        }
    }

    $discoveredDevices
}
