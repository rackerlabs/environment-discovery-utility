function Get-AzureADApplications
{
    <#

        .SYNOPSIS
            Discover Azure AD Applications

        .DESCRIPTION
            Query Azure AD for configured applications

        .OUTPUTS
            Returns a custom object containing configured Azure AD applications

        .EXAMPLE
            Get-AzureADApplications

    #>

    [CmdletBinding()]
    param ()

    $activity = "AzureAD Applications"
    $discoveredApplications = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query AzureAD for configured applications." -WriteProgress
        $applications = Get-AzureAdApplication
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query AzureAD for configured applications. $($_.Exception.Message)"
        return
    }

    if ($applications)
    {
        foreach ($application in $applications)
        {
            $applicationObject = "" | Select-Object ObjectId, DisplayName, AppId
            $applicationObject.ObjectId = [string]$application.ObjectId
            $applicationObject.DisplayName = [string]$application.DisplayName
            $applicationObject.AppId = [string]$application.AppId

            $discoveredApplications += $applicationObject
        }
    }

    $discoveredApplications
}
