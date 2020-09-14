function Get-ExoSafeLinksPolicy
{
    <#

        .SYNOPSIS
            Discover Exchange Online Advanced Threat Protection Safe Links Policy

        .DESCRIPTION
            Query Exchange Online for the ATP Safe Links Policy

        .OUTPUTS
            Returns a custom object containing configured Exchange Online ATP Safe Links Policy

        .EXAMPLE
            Get-ExoSafeLinksPolicy

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Online ATP Safe Links Policy"
    $discoveredPolicies = @()
    $cmdlet = Get-Command Get-SafeLinksPolicy -ErrorAction SilentlyContinue

    if ($null -notlike $cmdlet)
    {
        try
        {
            Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange Online for ATP SafeLinks Policies for O365." -WriteProgress
            $policy = Get-SafeLinksPolicy            
        }
        catch
        {
            Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange Online for ATP SafeLinks Policies. $($_.Exception.Message)"
            return
        }

        if ($policy)
        {
            $properties = $policy | Get-Member | Where-Object {$_.MemberType -like "Property" -and $_.Definition -like "System.*"} | Select-Object -ExpandProperty Name

            $policy = $policy | Select-Object $properties
            $discoveredPolicies += $policy
        }
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "Skipped query Get-SafeLinksPolicy because the command was not found. $($_.Exception.Message)"
    }

    $discoveredPolicies
}
