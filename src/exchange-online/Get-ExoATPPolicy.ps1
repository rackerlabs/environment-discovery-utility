function Get-ExoAtpPolicy
{
    <#

        .SYNOPSIS
            Discover Exchange Online Advanced Threat Protection Policies

        .DESCRIPTION
            Query Exchange Online for the ATP policy for O365

        .OUTPUTS
            Returns a custom object containing configured Exchange Online ATP Policy

        .EXAMPLE
            Get-ExoAtpPolicies

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Online ATP Policy"
    $cmdlet = Get-Command Get-AtpPolicyForO365 -ErrorAction SilentlyContinue

    if ($null -notlike $cmdlet)
    {
        try
        {
            Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange Online for ATP Policy for O365." -WriteProgress
            $policy = Get-AtpPolicyForO365
            $properties = $policy | Get-Member | Where-Object {$_.MemberType -like "Property" -and $_.Definition -like "System.*"} | Select-Object -ExpandProperty Name
    
            $policy = $policy | Select-Object $properties
        }
        catch
        {
            Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange Online for ATP Policy for O365. $($_.Exception.Message)"
            return
        }
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "Skipped query Get-AtpPolicyForO365 because the command was not found. $($_.Exception.Message)"
    }

    $policy
}
