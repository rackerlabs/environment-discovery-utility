function Get-ExoSafeAttachmentPolicy
{
    <#

        .SYNOPSIS
            Discover Exchange Online Advanced Threat Protection Safe Attachment Policy

        .DESCRIPTION
            Query Exchange Online for the ATP Safe Attachment Policy

        .OUTPUTS
            Returns a custom object containing configured Exchange Online ATP Safe Attachment Policy

        .EXAMPLE
            Get-ExoSafeAttachmentPolicy

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Online ATP Safe Attachment Policy"
    $discoveredPolicies = @()
    $cmdlet = Get-Command Get-SafeAttachmentPolicy -ErrorAction SilentlyContinue

    if ($null -notlike $cmdlet)
    {
        try
        {
            Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange Online for ATP Safe Attachment Policies." -WriteProgress
            $policy = Get-SafeAttachmentPolicy
        }
        catch
        {
            Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange Online for Safe Attachment Policy. $($_.Exception.Message)"
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
        Write-Log -Level "WARNING" -Activity $activity -Message "Skipped query Get-SafeAttachmentPolicy because the command was not found. $($_.Exception.Message)"
    }

    $discoveredPolicies
}
