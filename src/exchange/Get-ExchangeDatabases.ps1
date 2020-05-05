function Get-ExchangeDatabases
{
    <#

        .SYNOPSIS
            Discover Exchange database settings and configuration.

        .DESCRIPTION
            Query Exchange database settings and configuration.

        .OUTPUTS
            Returns a custom object containing Exchange database settings.

        .EXAMPLE
            Get-ExchangeDatabases

    #>

    [CmdletBinding()]
    param ()

    $activity = "Databases Configuration"
    $discoveredDatabases = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for Databases." -WriteProgress
        $databases = Get-MailboxDatabase -Status
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Exchange for Databases. $($_.Exception.Message)"
        return
    }

    foreach ($database in $databases)
    {
        $databaseSettings = $null
        $databaseSettings = "" | Select-Object Name, AdminDisplayVersion, MaintenanceSchedule
        $databaseSettings.Name = $database.Name
        $databaseSettings.AdminDisplayVersion = $database.AdminDisplayVersion
        $databaseSettings.MaintenanceSchedule = ($database.MaintenanceSchedule).ToString()

        $discoveredDatabases += $databaseSettings
    }

    $discoveredDatabases
}
