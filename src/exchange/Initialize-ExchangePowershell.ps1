function Initialize-ExchangePowershell
{
    <#

        .SYNOPSIS
            Used to start the RemoteExchange.ps1 script which in turn opens an Exchange Shell.

        .DESCRIPTION
            Detect the Exchange version and start an Exchange shell using built-in Exchange scripts.

        .OUTPUTS
            Returns an Exchange shell or nothing if an Exchange shell is already loaded.

        .EXAMPLE
            Initialize-ExchangePowershell

    #>

    [CmdletBinding()]
    param ()

    $connectedToExchange = $false
    $activity = "Initialize Exchange PowerShell"
    $currentLocation = Get-Location

    if (-not (Get-Command Get-ExchangeServer -ErrorAction SilentlyContinue))
    {
        $v14Path = "C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1"
        $v15Path = "C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1"
        $legacyPath = "C:\Program Files\Microsoft\Exchange Server\bin\Exchange.ps1"

        if (Test-Path $v15Path)
        {
            . $v15Path -RedirectStandardOutput $null | Out-Null
            Connect-ExchangeServer -Auto -RedirectStandardOutput $null | Out-Null
            Set-AdServerSettings -ViewEntireForest $true
            Write-Log -Level "VERBOSE" -Activity $activity -Message "Connected using $v15Path"
        }
        elseif (Test-Path $v14Path)
        {
            . $v14Path -RedirectStandardOutput $null | Out-Null
            Connect-ExchangeServer -Auto -RedirectStandardOutput $null | Out-Null
            Set-AdServerSettings -ViewEntireForest $true
            Write-Log -Level "VERBOSE" -Activity $activity -Message "Connected to Exchange PowerShell using $v15Path"
        }
        elseif (Test-Path $legacyPath)
        {
            Add-PSSnapIn Microsoft.Exchange.Management.PowerShell.Admin | Out-Null
            $AdminSessionADSettings.ViewEntireForest = $true
            Write-Log -Level "VERBOSE" -Activity $activity -Message "Connected to Exchange PowerShell using legacy PSSnapin."
        }
        else
        {
            Write-Log -Level "WARNING" -Activity $activity -Message "Failed to find method to connect to Exchange PowerShell."
        }
    }

    $session = Get-PSSession | Where-Object {$_.ConfigurationName -like 'Microsoft.Exchange'} | Select-Object -First 1
    
    if ($null -notlike $session)
    {
        Import-PSSession $session -AllowClobber -ErrorAction SilentlyContinue | Out-Null
    }

    $testCommand = Get-Command Get-ExchangeServer -ErrorAction SilentlyContinue

    if ($testCommand)
    {
        Write-Log -Level "INFO" -Activity $MyInvocation.MyCommand.Name -Message "Successfully connected Exchange PowerShell."
        $connectedToExchange = $true
    }
    else
    {
        Write-Log -Level "ERROR" -Activity $MyInvocation.MyCommand.Name -Message "Failed to Initialize Exchange PowerShell."
    }

    Set-Location $currentLocation
    $connectedToExchange
}
