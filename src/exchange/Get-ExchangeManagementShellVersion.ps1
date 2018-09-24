function Get-ExchangeManagementShellVersion
{
        <#

        .SYNOPSIS
            Discover Exchange Management Shell Version.

        .DESCRIPTION
            Uses Get-Command Exsetup.exe to get the installed version of the management shell.

        .OUTPUTS
            Returns a custom object with the exchange version installed.

        .EXAMPLE
            Get-ExchangeManagementShellVersion

    #>

    [CmdletBinding()]
    param ()

    try
    {
        $exchangeManagementShellVersion = Get-Command Exsetup.exe
        Write-Log -Level "INFO" -Activity $activity -Message "Gathering Exchange Management Shell Version." -WriteProgress        
    }
    
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to run Get-Command. $($_.Exception.Message)"
        return
    }

    $exchangeManagementShellVersion.FileVersionInfo.Productversion
}