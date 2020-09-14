function Get-ExoTransportRules
{
    <#

        .SYNOPSIS
            Discover Exchange Online transport rules

        .DESCRIPTION
            Query Exchange Online for configured transport rules

        .OUTPUTS
            Returns a custom object containing configured Exchange Online transport rules

        .EXAMPLE
            Get-ExoTransportRules

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Online Transport Rules"
    $discoveredRules = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange Online for configured transport rules." -WriteProgress
        $transportRules = Get-TransportRule
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange Online for configured transport rules. $($_.Exception.Message)"
        return
    }

    if ($transportRules)
    {
        $properties = $transportRules | Get-Member | Where-Object {$_.MemberType -like "Property" -and $_.Definition -like "System.*"} | Select-Object -ExpandProperty Name

        foreach ($transportRule in $transportRules)
        {
            $rule = $transportRule | Select-Object $properties
            $discoveredRules += $rule
        }
    }

    $discoveredRules
}
