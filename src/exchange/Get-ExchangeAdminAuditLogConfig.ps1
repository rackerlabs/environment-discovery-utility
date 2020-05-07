function Get-ExchangeAdminAuditLogConfig
{
    <#

        .SYNOPSIS
            Checks if the Admin Audit Log is enabled for Exchange

        .DESCRIPTION
            Query Exchange to find Admin Audit log

        .OUTPUTS
            Returns a custom object containing Exchange Admin Audit Log Configuration

        .EXAMPLE
            Get-AdminAuditLogConfig

    #>

    [CmdletBinding()]
    param ()

    $activity = "Exchange Admin Audit Log Configuration"
    $discoveredAdminAuditLogConfig = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange Admin Audit Log Configuration" -WriteProgress
        $exchangeAdminAuditLogConfiguration = Get-AdminAuditLogConfig
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to determine Admin Audit Log Configuration. $($_.Exception.Message)"
        return
    }

    if ($null -notlike $exchangeAdminAuditLogConfiguration)
    {   
        $discoveredAdminAuditLogConfig = $exchangeAdminAuditLogConfiguration | select AdminAuditLogEnabled
    }

    $discoveredAdminAuditLogConfig
}
