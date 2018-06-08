function Initialize-ExchangePowershell
{
    [CmdletBinding()]
    param ()

    $connectedToExchange = $false

    if (-not (Get-Command Get-ExchangeServer -ErrorAction SilentlyContinue))
    {
        if (Test-Path "C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1")
        {
            . 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1' -RedirectStandardOutput $null | Out-Null
            Connect-ExchangeServer -Auto -RedirectStandardOutput $null | Out-Null
        } 
        elseif (Test-Path "C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1")
        {
            . 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1' -RedirectStandardOutput $null | Out-Null
            Connect-ExchangeServer -Auto -RedirectStandardOutput $null | Out-Null
        }
        elseif (Test-Path "C:\Program Files\Microsoft\Exchange Server\bin\Exchange.ps1")
        {
            Add-PSSnapIn Microsoft.Exchange.Management.PowerShell.Admin -RedirectStandardOutput $null| Out-Null
        }
    }

    $testCommand = Get-Command Get-ExchangeServer -ErrorAction SilentlyContinue

    if ($testCommand)
    {
        Write-Log -Level 'VERBOSE' -Activity $MyInvocation.MyCommand.Name -Message "Successfully connected Exchange PowerShell"
        $connectedToExchange = $true
    }
    else
    {
        Write-Log -Level 'WARNING' -Activity $MyInvocation.MyCommand.Name -Message "Failed to connect to Exchange PowerShell"
    }

    $connectedToExchange
}
