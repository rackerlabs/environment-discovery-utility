function Initialize-AzureADPowerShell
{
    <#

        .SYNOPSIS
            Used to initialize the AzureAD PowerShell session.

        .DESCRIPTION
            Verifies that the pre-requisites are met and initializes the AzureAD PowerShell session.

        .OUTPUTS
            None

        .EXAMPLE
            Initialize-AzureADPowerShell

    #>

    [CmdletBinding()]
    param (
        # The credential to use to connect to AzureAD Powershell
        [System.Management.Automation.PSCredential]
        $Credential
    )

    [bool]$connectedToAzureAD = $false
    $activity = "Initialize AzureAD PowerShell"
    Clear-Host
    Write-Log -Level "INFO" -Activity $activity -Message "Initializing AzureAD Powershell.  Please provide adminsitrator access if prompted." -WriteProgress
    
    $existingModules = Get-Module -ListAvailable -Name "AzureAD"
    
    if ($existingModules.Count -like 0)
    {
        if ($PSVersionTable.PSVersion.Major -ge 5)
        {
            try
            {
                Write-Log -Level "INFO" -Activity $activity -Message "Installing the AzureAD Powershell Module." -WriteProgress
                Install-Module azuread -Confirm:$false -Scope CurrentUser -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -Force | Out-Null
            }
            catch
            {
                Write-Log -Level "ERROR" -Activity $activity -Message "Failed to install the Azure AD PowerShell Module. $($_.Exception.Message)"
                return
            }
        }
        else
        {
            Write-Log -Level "ERROR" -Activity $activity -Message "Azure AD Discovery skipped due to missing PowerShell Module.  Could not use Install-Module due to PowerShell Version."
            return
        }
    }

    if ($Credential -like $null)
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Prompting for Azure AD Credentials"
        $Credential = Get-Credential -Message "Azure AD PowerShell admin credentials"
    }
    
    try
    {
        Connect-AzureAD -Credential $Credential
    }
    catch
    {
        if ($_.Exception.Message -like '*multi-factor*')
        {
            Write-Log -Level "INFO" -Activity $activity -Message "Failed to pass credentials to Azure AD Module due to MFA Requirements.  Provide credentials when prompted." -WriteProgress
            Connect-AzureAD
        }
    }

    if (Test-AzureADConnection)
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Successfully connected AzureAD PowerShell." -WriteProgress
        $connectedToAzureAD = $true
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "Failed to connect AzureAD PowerShell."
    }

    $connectedToAzureAD
}

function Test-AzureADConnection
{
    try
    {
        $azureADSessionInfo = Get-AzureADCurrentSessionInfo -ErrorAction SilentlyContinue
        if (($azureADSessionInfo -notlike $null) -and ($azureADSessionInfo.TenantId -notlike $null))
        {
            $true
        }
        else
        {
            $false
        }
    }
    catch
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "Failed to run Get-AzureADCurrentSessionInfo to check for existing sessions."
        $false
    }
}
