function Initialize-ExoPowerShell
{
    <#

        .SYNOPSIS
            Used to initialize the Exchange Online PowerShell session.

        .DESCRIPTION
            Verifies that the pre-requisites are met and initializes the Exchange Online PowerShell session.

        .OUTPUTS
            None

        .EXAMPLE
            Initialize-ExchangeOnlinePowerShell -Credential $cred

    #>

    [CmdletBinding()]
    param
    (
        # The credential to use to connect to Exchange Online Powershell
        [System.Management.Automation.PSCredential]
        $Credential
    )

    [bool]$connectedToExchangeOnline = $false
    $activity = "Initialize Exchange Online PowerShell"
    
    Import-ExchangeOnlineModernModule -Credential $Credential

    if ($Script:EXOSessionTime -le (Get-Date).AddMinutes(-45))
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Exchange shell age has exceeded safe limit, forcing a reconnect to preserve session." -WriteProgress
        Get-PSSession | Where-Object { ($_.ConfigurationName -eq 'Microsoft.Exchange') } | Remove-PSSession
    }

    if (Get-ExchangeOnlineSession)
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Successfully connected Exchange Online PowerShell." -WriteProgress
        $connectedToExchangeOnline = $true
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "Failed to connect Exchange Online PowerShell."
    }

    $connectedToExchangeOnline
}

function Get-ExchangeOnlineSession
{
    <#

        .SYNOPSIS
            Gets an open Exchange Online PowerShell session if one exists.

        .DESCRIPTION
            Gets an open Exchange Online PowerShell session if one exists.

        .OUTPUTS
            None

        .EXAMPLE
            Get-ExchangeOnlineSession

    #>

    $openSession = (Get-PSSession | Where-Object { ($_.ConfigurationName -eq 'Microsoft.Exchange') -and ($_.State -eq 'Opened') }) | Select-Object -First 1

    if ($null -notlike $openSession)
    {
        Write-Log -Level "DEBUG" -Activity $activity -Message "Found an existing Exchange Online session in the open state."
        $openSession
    }
    else
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Did not find an existing Exchange Online session in the open state."
    }
}

function Import-ExchangeOnlineModernModule
{
    <#

        .SYNOPSIS
            Used to initialize the Exchange Online PowerShell session.

        .DESCRIPTION
            Verifies that the pre-requisites are met and initializes the Exchange Online PowerShell session.

        .OUTPUTS
            None

        .EXAMPLE
            Import-ExchangeOnlineModernModule -Credential $cred

    #>

    [CmdletBinding()]
    param
    (
        # The UPN to use to connect to Exchange Online Powershell
        [System.Management.Automation.PSCredential]
        $Credential
    )

    $currentLocation = Get-Location
    Write-Log -Level "INFO" -Activity $activity -Message "Loading the Exchange Online Management PowerShell Module." -WriteProgress
    $existingModules = Get-Module -ListAvailable -Name "ExchangeOnlineManagement"
    
    if ($existingModules.Count -like 0)
    {
        if ($PSVersionTable.PSVersion.Major -ge 5)
        {
            try
            {
                Write-Log -Level "INFO" -Activity $activity -Message "Installing the Exchange Online Management PowerShell Module." -WriteProgress
                Install-Module ExchangeOnlineManagement -Confirm:$false -Scope CurrentUser -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null
            }
            catch
            {
                Write-Log -Level "ERROR" -Activity $activity -Message "Failed to install the Exchange Online Management  PowerShell Module. $($_.Exception.Message)"
                return
            }
        }
        else
        {
            Write-Log -Level "ERROR" -Activity "Exchange Online Discovery" -Message "Exchange Online Management module could not be automatically installed due to PowerShell Version."
            return
        }
    }
    
    $openSession = Get-ExchangeOnlineSession

    if ($null -notlike $openSession)
    {
        Import-PSSession $openSession -AllowClobber
        return
    }

    try
    {
        if ($Credential -like $null)
        {
            $Credential = Get-Credential -Message "Exchange Online PowerShell Admin credentials"
        }
        
        try
        {
            Connect-ExchangeOnline -Credential $Credential
        }
        catch
        {
            if ($_.Exception.Message -like '*multi-factor*')
            {
                Write-Log -Level "INFO" -Activity $activity -Message "Failed to pass credentials to Exchange Online Management Module due to MFA Requirements.  Provide credentials when prompted." -WriteProgress
                Connect-ExchangeOnline -UserPrincipalName $Credential.Username
            }
        }
        
        $Script:EXOSessionTime = $(Get-Date)
        $exchangeOnlineSession = Get-ExchangeOnlineSession
        $exchangeOnlineSession
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to connect to Exchange Online PowerShell.  $($_.Exception.Message)"
    }

    Set-Location $currentLocation -ErrorAction SilentlyContinue
}

function Remove-ExchangeOnlineSession
{
        <#

        .SYNOPSIS
            Used to dispose of the Exchange Online PowerShell session.

        .DESCRIPTION
            Looks for an open Exchange Online PowerShell session and disposes of it.

        .OUTPUTS
            None

        .EXAMPLE
            Remove-ExchangeOnlineSession

    #>
    
    [CmdletBinding()]
    param()

    Disconnect-ExchangeOnline -Confirm:$false  
    Get-PSSession | Where-Object {$_.Name -like "ExchangeOnlineInternalSession_*"} | Remove-PSSession
}