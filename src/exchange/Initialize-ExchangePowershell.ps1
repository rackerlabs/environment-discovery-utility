function Initialize-ExchangePowershell
{
    [CmdletBinding()]
    param ()

    $connectedToExchange = $false

    if (-not (Get-Command Get-ExchangeServer -ErrorAction SilentlyContinue))
    {
        if (Test-Path "C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1")
        {
            . 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1' | Out-Null
            Connect-ExchangeServer -Auto | Out-Null
        } 
        elseif (Test-Path "C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1")
        {
            . 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1' | Out-Null
            Connect-ExchangeServer -Auto | Out-Null
        }
        elseif (Test-Path "C:\Program Files\Microsoft\Exchange Server\bin\Exchange.ps1")
        {
            Add-PSSnapIn Microsoft.Exchange.Management.PowerShell.Admin | Out-Null
        }
    }

    $testCommand = Get-Command Get-ExchangeServer -ErrorAction SilentlyContinue

    if ($testCommand)
    {
        Write-Verbose 'Successfully Connected to Exchange Powershell.'
        $connectedToExchange = $true
    }
    else
    {
        Write-Warning 'Failed to connect to Exchange Powershell. Some components of discovery will not fully function.'
    }

    $connectedToExchange
}