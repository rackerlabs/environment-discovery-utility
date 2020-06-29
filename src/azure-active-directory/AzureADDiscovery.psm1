function Start-AzureADDiscovery
{
    <#

        .SYNOPSIS
            This cmdlet will return information related to the configuration of Azure Active Directory.

        .DESCRIPTION
            This cmdlet will return information related to the configuration of Azure Active Directory.  This is not meant to be run independently and is part of the Environment Discovery Utility package.

        .OUTPUTS
            A PSObject representation of the discovered Exchange environment.

        .EXAMPLE
            Start-AzureADDiscovery

    #>

    [CmdletBinding()]
    param ()
    begin
    {
        $activity = "AzureAD Discovery"
        Write-Log -Level "INFO" -Activity  $activity -Message "Attempting to connect to AzureAD Powershell." -WriteProgress
        $azureADEnvironment = @{}
        $azureADShellConnected = Test-AzureADConnection
    }
    process
    {

        if ($azureADShellConnected -like $true)
        {
            [array]$azureADDomains = Get-AzureADDomains
            $sessionInfo = Get-AzureADCurrentSessionInfo
            [array]$applications = Get-AzureADApplications
            [array]$devices = Get-AzureADDevices
            [array]$users = Get-AzureADUsers

            $azureADEnvironment.Add("TenantId", [string]$sessionInfo.TenantId)
            $azureADEnvironment.Add("TenantDomain", [string]$sessionInfo.TenantDomain)
            $azureADEnvironment.Add("Domains", $azureADDomains)
            $azureADEnvironment.Add("Applications", $applications)
            $azureADEnvironment.Add("Devices", $devices)
            $azureADEnvironment.Add("Users", $users)

            Write-Log -Level "INFO" -Activity  $activity -Message "Completed AzureAD Discovery." -WriteProgress
        }
        else
        {
            Write-Log -Level "WARNING" -Activity $activity -Message "Unable to execute AzureAD Discovery because no AzureAD PowerShell session could be established." -WriteProgress
        }

        $azureADEnvironment
    }
}
