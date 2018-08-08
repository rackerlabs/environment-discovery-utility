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

    if (-not (Get-Command Get-ExchangeServer -ErrorAction SilentlyContinue))
    {
        if (Test-Path "C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1")
        {
            . "C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1" -RedirectStandardOutput $null | Out-Null
            Connect-ExchangeServer -Auto -RedirectStandardOutput $null | Out-Null
        }
        elseif (Test-Path "C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1")
        {
            . "C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1" -RedirectStandardOutput $null | Out-Null
            Connect-ExchangeServer -Auto -RedirectStandardOutput $null | Out-Null
        }
        elseif (Test-Path "C:\Program Files\Microsoft\Exchange Server\bin\Exchange.ps1")
        {
            Add-PSSnapIn Microsoft.Exchange.Management.PowerShell.Admin | Out-Null
        }
    }

    $testCommand = Get-Command Get-ExchangeServer -ErrorAction SilentlyContinue
    
    if ($testCommand)
    {
        Write-Log -Level "VERBOSE" -Activity $MyInvocation.MyCommand.Name -Message "Successfully connected Exchange PowerShell."
        $connectedToExchange = $true
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $MyInvocation.MyCommand.Name -Message "Failed to connect to Exchange PowerShell."
    }
    
    $connectedToExchange
}
