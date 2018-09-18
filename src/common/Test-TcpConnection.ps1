function Test-TcpConnection
{
    <#

        .SYNOPSIS
            Test connectivity to remote TCP host and port.

        .DESCRIPTION
            Test connectivity to remote TCP host and port. Returns $true or $false.

        .OUTPUTS
            Returns a boolean option for status of connectivity to remote port.

        .EXAMPLE
            Test-TCPConnection -Host $Server -Port $Port

    #>

    [CmdletBinding()]
    param (
        # Host The host to attemt the connection against
        [String]
        $Host,

        # Port The TCP port to test
        [int]
        $Port
    )

    $tcpClient = New-Object Net.Sockets.TcpClient
    $result = $false

    try
    {
        $tcpClient.Connect($Host, $Port)
    }
    catch
    {
        Write-Verbose "Failed to connect to Port $Port on Server $Host. $($_.Exception.Message)"
    }

    if ($tcpClient.Connected)
    {
        Write-Verbose "Successfully connected to Port $Port on Server $Host."
        $result = $true
        $tcpClient.Close()

        if ($tcpClient | Get-Member Dispose)
        {
            $tcpClient.Dispose()
        }

        $tcpClient = $null
    }
    else
    {
        $result = $false
    }

    $result
}
