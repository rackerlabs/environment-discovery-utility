function Get-ExoEmailAddressPolicies
{
    <#

        .SYNOPSIS
            Discover Exchange Online Email Address Policies

        .DESCRIPTION
            Query Exchange Online for configured Email Address Policies

        .OUTPUTS
            Returns a custom object containing configured Exchange Online Email Address Policies

        .EXAMPLE
            Get-ExoEmailAddressPolicies

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Online Email Address Policies"
    $discoveredEmailAddressPolicies = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange Online for configured Email Address Policies." -WriteProgress
        $emailAddressPolicies = Get-EmailAddressPolicy
        $properties = $emailAddressPolicies | Get-Member | Where-Object {$_.MemberType -like "Property" -and $_.Definition -like "System.*"} | Select-Object -ExpandProperty Name

        foreach ($emailAddressPolicy in $emailAddressPolicies)
        {
            $policy = $emailAddressPolicy | Select-Object $properties
            $discoveredEmailAddressPolicies += $policy
        }
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange Online for configured Email Address Policies. $($_.Exception.Message)"
        return
    }

    $discoveredEmailAddressPolicies
}
