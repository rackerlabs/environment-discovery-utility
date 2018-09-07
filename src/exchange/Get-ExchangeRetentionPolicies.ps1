function Get-ExchangeRetentionPolicies
{
    <#

        .SYNOPSIS
            Discovers Exchange Retention Policy settings.

        .DESCRIPTION
            Query Exchange to find all Exchange Retention Policy settings.

        .OUTPUTS
            Returns a custom object containing several key settings for the Retention Policies.

        .EXAMPLE
            Get-ExchangeRetentionPolicies

    #>

    [CmdletBinding()]
    param ()

    $activity = "Retention Policies"
    $discoveredRetentionPolicies = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Getting Retention Policy Settings." -WriteProgress
        $retentionPolicies = Get-RetentionPolicy  
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to get Retention Policy Settings. $($_.Exception.Message)"
        return
    }

    foreach ($retentionPolicySetting in $retentionPolicies)
    {
        $retentionPolicy = $null
        $retentionPolicy = ""| Select-Object Guid, IsDefault, WhenChanged, WhenCreated, RetentionPolicyTagLinks
        $retentionPolicy.Guid = $retentionPolicySetting.Guid
        $retentionPolicy.IsDefault = [bool]$retentionPolicySetting.IsDefault
        $retentionPolicy.WhenCreated = $retentionPolicySetting.WhenCreated
        $retentionPolicy.WhenChanged = $retentionPolicySetting.WhenChanged

        $retentionPolicyTagLinks = @()
        $retentiontags = $retentionPolicySetting.RetentionPolicyTagLinks

        foreach ($retentiontag in $retentiontags)
        {
            $retentionPolicytag = $null
            $retentionPolicytag = ""| Select-Object ObjectGuid, Name
            $retentionPolicytag.ObjectGuid = $retentiontag.ObjectGuid
            $retentionPolicytag.Name = $retentiontag.Name

            $RetentionPolicyTagLinks += $retentionPolicytag
        }

        $retentionPolicy.RetentionPolicyTagLinks = $retentionPolicyTagLinks
        $discoveredRetentionPolicies += $retentionPolicy
    }

    $discoveredRetentionPolicies
}
