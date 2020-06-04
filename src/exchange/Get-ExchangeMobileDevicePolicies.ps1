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
            Get-ExchangeMobileDevicePolicies -Recipients $exchangeEnvironment["Recipients"]

    #>

    [CmdletBinding()]
    param (
        # Recipients An array of Recipients to run discovery against
        [array]
        $Recipients
    )

    $activity = "Mobile Device Policies"
    $discoveredMobileDevicePolicies = @()
    $uniqueAssignedMailboxPolicies = @()
    $mobileDevicePolicies = @()

    try
    {
        $exchangeManagementShellVersion = Get-ExchangeManagementShellVersion
        Write-Log -Level "INFO" -Activity $activity -Message "Gathering Exchange Mobile Device Policies." -WriteProgress
        $uniqueAssignedMailboxPolicies =  $recipients | Where-Object {$null -ne $_.ActiveSyncMailboxPolicy} | Select-Object -ExpandProperty ActiveSyncMailboxPolicy | Sort-Object -Unique
                  
        foreach ($uniqueAssignedMailboxPolicy in $uniqueAssignedMailboxPolicies)
        {
            if ($null -notlike $uniqueAssignedMailboxPolicy)
            {
                if ($exchangeManagementShellVersion -like "15*")
                {
                    [array]$mobileDevicePolicies += Get-MobileDeviceMailboxPolicy -identity $uniqueAssignedMailboxPolicy
                }
                else
                {
                   [array]$mobileDevicePolicies += Get-ActiveSyncMailboxPolicy -identity $uniqueAssignedMailboxPolicy
                }
            }    
        }
    }
       
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to run Get-MobileDeviceMailboxPolicy. $($_.Exception.Message)"
        return
    }

    write-log -level "Info" -Activity $activity -Message "Found $($uniqueAssignedMailboxPolicies.count) Unique Assigned Mobile Device Policies"
    
    foreach ($mobileDevicePolicy in $mobileDevicePolicies)
    {  
        $currentMobileDevicePolicy = "" | Select-Object Guid, Name, Default
        $currentMobileDevicePolicy.Name = $mobileDevicePolicy.Name
        $currentMobileDevicePolicy.Guid = [guid]$mobileDevicePolicy.Guid
        
        if ($exchangeManagementShellVersion -like "15*")
        {
            $currentMobileDevicePolicy.Default = $mobileDevicePolicy.isDefault
        }
        else
        {
            $currentMobileDevicePolicy.Default = $mobileDevicePolicy.isDefaultPolicy
        }
    
        $discoveredMobileDevicePolicies += $currentMobileDevicePolicy
    }

    $discoveredMobileDevicePolicies
}