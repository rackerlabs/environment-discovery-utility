function Get-ExoTransportConfig
{
    <#

        .SYNOPSIS
            Discover Exchange Online transport configuration

        .DESCRIPTION
            Query Exchange Online for configured transport configuration

        .OUTPUTS
            Returns a custom object containing configured Exchange Online transport configuration

        .EXAMPLE
            Get-ExoTransportConfig

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Online Transport Config"

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange Online for transport configuration." -WriteProgress
        $transportConfig = Get-TransportConfig
        $properties = $transportConfig | Get-Member | Where-Object {$_.MemberType -like "Property" -and $_.Definition -like "System.*"} | Select-Object -ExpandProperty Name
        $transportConfig = $transportConfig | Select-Object $properties
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange Online for transport configuration. $($_.Exception.Message)"
        return
    }

    $transportConfig 
}
