function Get-ExchangeImapPopSettings
{
    <#

        .SYNOPSIS
            Discover Exchange POP and IMAP protocol settings.

        .DESCRIPTION
            Query Exchange to retrieve POP and IMAP protocol settings.

        .OUTPUTS
            Returns a custom object containing key Exchange POP/IMAP protocol settings.

        .EXAMPLE
            Get-ExchangeImapPopSettings -Servers $exchangeServers

    #>

    [CmdletBinding()]
    param (
        # Servers An array of server objects to run discovery against
        [array]
        $Servers
    )

    $activity = "Pop/IMAP Settings"
    $discoveredImapPopSettings = @()

    foreach ($server in $Servers)
    {
        $serverName = $null
        $serverName = $Server.Name
       
        if (!$serverName)
        {
            Write-Log -Level "ERROR" -Activity $activity -Message "Failed to find Exchange Server Name." -WriteProgress
            Continue
        }

        try
        {
            Write-Log -Level "VERBOSE" -Activity $activity -Message "Querying $serverName Exchange for Pop/Imap Settings." -WriteProgress
            $exchangePopImapSettings = @()
            $exchangePopImapSettings += Get-PopSettings -Server $serverName | select UnencryptedOrTLSBindings, SSLBindings, Guid, ProtocolName, X509CertificateName, Server
            $exchangePopImapSettings += Get-ImapSettings -Server $serverName | select UnencryptedOrTLSBindings, SSLBindings, Guid, ProtocolName, X509CertificateName, Server
        }
        catch
        {
            Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for Pop/IMAP Settings. $($_.Exception.Message)"
            Continue
        }

        if (!$exchangePopImapSettings)
        {
            Write-Log -Level "VERBOSE" -Activity $activity -Message "$serverName only has the mailbox role. Pop/Imap not Installed." -WriteProgress
            Continue
        }
        
        $exchangeServiceStatus = @()

        foreach ($exchangeService in $exchangePopImapSettings)
        {
            $exchangeServiceStatus = @()
            $protocolSetting = $null
            $protocolSetting = "" | Select-Object ObjectGuid, Protocol, SecureBindings, ServerBindings, CertificateName, ServiceStatus, Server
            $protocolSetting.ObjectGuid = $exchangeService.Guid
            $protocolSetting.Protocol = $exchangeService.ProtocolName
            $protocolSetting.SecureBindings = $exchangeService.UnencryptedOrTLSBindings
            $protocolSetting.ServerBindings = $exchangeService.SSLBindings
            $protocolSetting.CertificateName = $exchangeService.X509CertificateName
            $protocolSetting.Server = $exchangeService.Server

            $exchangeServiceConfigs = @()
            $exchangeServiceConfigs += ($exchangePopImapSettings | where {$_.ProtocolName -eq $exchangeService.ProtocolName}).UnencryptedOrTLSBindings | where {$_.AddressFamily -eq "InterNetwork"}
            $exchangeServiceConfigs += ($exchangePopImapSettings | where {$_.ProtocolName -eq $exchangeService.ProtocolName}).SSLBindings | where {$_.AddressFamily -eq "InterNetwork"}

            foreach ($exchangeServiceConfig in $exchangeServiceConfigs)
            {
                $exchangeServer = $exchangeServiceConfig.Address
                
                if ($exchangeServer -eq "0.0.0.0")
                {
                    $exchangeServer = $serverName
                }

                $PortStatus = Check-RemotePort -Server $exchangeServer -Port $exchangeServiceConfig.Port

                $remotePortResult = $null
                $remotePortResult = "" | Select-Object Address, Port, Protocol, TCPResponse
                $remotePortResult.Address = $exchangeServiceConfig.Address
                $remotePortResult.Port = $exchangeServiceConfig.Port
                $remotePortResult.Protocol = $exchangeService.ProtocolName
                $remotePortResult.TcpResponse = $PortStatus

                $exchangeServiceStatus += $remotePortResult
            }

            $protocolSetting.ServiceStatus = $exchangeServiceStatus
            $discoveredImapPopSettings += $protocolSetting
        }
    }

    $discoveredImapPopSettings
}

function Check-RemotePort
{
    <#

        .SYNOPSIS
            Check port on remote computer.

        .DESCRIPTION
            Verify Connectivity on remote port.

        .OUTPUTS
            Returns a boolean option for status of connectivity to remote port.

        .EXAMPLE
            Check-RemotePort -Server $Server -Port $Port

    #>

    [CmdletBinding()]
    param (
        # Servers An array of server objects to run discovery against
        [String]
        $Server,

        [String]
        $Port
    )
    
    $activity = "Pop/IMAP Settings"

    $portCheck = New-Object Net.Sockets.TcpClient
    
    try
    {
        $portCheck.Connect($Server, $Port)
    }
    catch
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Failed to connect to Port $Port on Server $Server. $($_.Exception.Message)"
    }
    
    if ($portCheck.Connected) {
        return $true
        $portCheck.Close()
    }
    else {
        return $false
    }
        
    $portCheck.Dispose()
    $portCheck = $null
}
