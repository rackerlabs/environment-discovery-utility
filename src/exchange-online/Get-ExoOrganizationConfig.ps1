function Get-ExoOrganizationConfig
{
    <#

        .SYNOPSIS
            Discover Exchange Online Organization Config

        .DESCRIPTION
            Query Exchange Online for configured organization config

        .OUTPUTS
            Returns a custom object containing configured Exchange Online organization config

        .EXAMPLE
            Get-ExoOrganizationConfig

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Online Organization Config"

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange Online for existing Organization Configuration." -WriteProgress
        $orgConfig = Get-OrganizationConfig
        $properties = $orgConfig | Get-Member | Where-Object {$_.MemberType -like "Property" -and $_.Definition -like "System.*"} | Select-Object -ExpandProperty Name

        $orgConfig = $orgConfig | Select-Object $properties
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange Online for exustubg Organization Configuration. $($_.Exception.Message)"
        return
    }

    $orgConfig
}
