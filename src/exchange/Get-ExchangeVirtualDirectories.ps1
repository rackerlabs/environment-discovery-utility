function Get-ExchangeVirtualDirectories
{
    <#

        .SYNOPSIS
            Find Exchange virtual directory settings.

        .DESCRIPTION
            Uses Exchange PowerShell to enumerate Exchange virtual directories.

        .OUTPUTS
            Returns a custom object containing settings for all Exchange virtual directories.

        .EXAMPLE
            Get-ExchangeVirtualDirectories

    #>

    [CmdletBinding()]
    param (
        # Servers An array of servers to run discovery against
        [array]
        $Servers
    )

    $activity = "Virtual Directories"
    $discoveredVirtualDirectories = @{}
    $discoveredVirtualDirectories.EWS = @()
    $discoveredVirtualDirectories.EAS = @()
    $discoveredVirtualDirectories.ECP = @()
    $discoveredVirtualDirectories.OWA = @()
    $discoveredVirtualDirectories.MAPI = @()
    $discoveredVirtualDirectories.AutoDiscover = @()

    if ($Servers.Count -ge 1)
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for Virtual Directories" -WriteProgress

        foreach ($server in $Servers)
        {
            $serverName = $server.Name
            $exchSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$serverName/PowerShell/ -Authentication Kerberos -ErrorAction SilentlyContinue
            $ewsCommand = "Get-WebServicesVirtualDirectory -Server $serverName"
            $easCommand = "Get-ActiveSyncVirtualDirectory -Server $serverName"
            $ecpCommand = "Get-EcpVirtualDirectory -Server $serverName"
            $owaCommand = "Get-OwaVirtualDirectory -Server $serverName"
            $oabCommand = "Get-OabVirtualDirectory -Server $serverName"
            $mapiCommand = "Get-MapiVirtualDirectory -Server $serverName"
            $autoDiscoverCommand = "Get-AutodiscoverVirtualDirectory -Server $serverName"

            [array]$ewsVirtualDirectories = Get-VirtualDirectories -ServerName $serverName -Command $ewsCommand -Session $exchSession
            [array]$easVirtualDirectories = Get-VirtualDirectories -ServerName $serverName -Command $easCommand -Session $exchSession
            [array]$ecpVirtualDirectories = Get-VirtualDirectories -ServerName $serverName -Command $ecpCommand -Session $exchSession
            [array]$owaVirtualDirectories = Get-VirtualDirectories -ServerName $serverName -Command $owaCommand -Session $exchSession
            [array]$oabVirtualDirectories = Get-VirtualDirectories -ServerName $serverName -Command $oabCommand -Session $exchSession
            [array]$autoDiscoverVirtualDirectories = Get-VirtualDirectories -ServerName $serverName -Command $autoDiscoverCommand -Session $exchSession

            $discoveredVirtualDirectories["EWS"] += $ewsVirtualDirectories
            $discoveredVirtualDirectories["EAS"] += $easVirtualDirectories
            $discoveredVirtualDirectories["ECP"] += $ecpVirtualDirectories
            $discoveredVirtualDirectories["OWA"] += $owaVirtualDirectories
            $discoveredVirtualDirectories["OAB"] += $oabVirtualDirectories
            $discoveredVirtualDirectories["AutoDiscover"] += $autoDiscoverVirtualDirectories

            if ($server.AdminDisplayVersion -like "*15.*")
            {
                [array]$mapiVirtualDirectories = Get-VirtualDirectories -ServerName $serverName -Command $mapiCommand -Session $exchSession
                $discoveredVirtualDirectories["MAPI"] += $mapiVirtualDirectories
            }
            else
            {
                Write-Log -Level "DEBUG" -Activity $activity -Message "Skipping MAPI Virtual Directory discovery because of the exchange version older than 2013."
            }
        }
    }
    else
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "No Exchange server to query for Virtual Directories."
    }

    $discoveredVirtualDirectories
}

function Get-VirtualDirectories
{
    [CmdletBinding()]
    param (
        [string]
        $ServerName,

        [string]
        $Command,

        [System.Management.Automation.Runspaces.PSSession]
        $Session
    )

    [array]$virtualDirectories = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Executing Exchange command: $Command" -WriteProgress
        [array]$result = Invoke-RemoteExchangeCommand -Command $Command -Session $Session
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Exchange command execution failure.  Command: $Command `n$($_.Exception)" -WriteProgress
    }

    if ($result.Count -gt 0)
    {
        foreach ($virtualDirectory in $result)
        {
            try
            {
                $virtualDirectories += ConvertFrom-VirtualDirectory -VirtualDirectory $virtualDirectory
            }
            catch
            {
                Write-Log -Level "ERROR" -Activity $activity -Message "Failed to convert virtual directory.  $($_.Exception)" -WriteProgress
            }
        }
    }

    Write-Log -Level "VERBOSE" -Activity $activity -Message "Discovered $($virtualDirectories.Count) virtual directories." -WriteProgress

    $virtualDirectories
}

function ConvertFrom-VirtualDirectory
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [object]
        $VirtualDirectory
    )

 
        if ($VirtualDirectory.MRSProxyEnabled -notlike $null)
        {
            $currentVirtualDir = "" | Select-Object Name, Server, InternalAuthenticationMethods, ExternalAuthenticationMethods, InternalUrl, ExternalUrl, MRSProxyEnabled
            $currentVirtualDir.MRSProxyEnabled = $VirtualDirectory.MRSProxyEnabled
        }
        else
        {
            $currentVirtualDir = "" | Select-Object Name, Server, InternalAuthenticationMethods, ExternalAuthenticationMethods, InternalUrl, ExternalUrl
        }

        $currentVirtualDir.Name = [string]$VirtualDirectory.Name
        $currentVirtualDir.Server = [string]$VirtualDirectory.Server
        $currentVirtualDir.InternalUrl = [string]$VirtualDirectory.InternalUrl
        $currentVirtualDir.ExternalUrl = [string]$VirtualDirectory.ExternalUrl

        if ($VirtualDirectory.InternalAuthenticationMethods -notlike $null)
        {
            $currentVirtualDir.InternalAuthenticationMethods = [string[]]$VirtualDirectory.InternalAuthenticationMethods
        }
        else
        {
            [string[]]$currentVirtualDir.InternalAuthenticationMethods = $null
            Write-Warning "InternalAuthenticationMehods is null for $($VirtualDirectory.Name) on $($VirtualDirectory.Server)."
        }

        if ($VirtualDirectory.ExternalAuthenticationMethods -notlike $null)
        {
            $currentVirtualDir.ExternalAuthenticationMethods = [string[]]$VirtualDirectory.ExternalAuthenticationMethods
        }
        else
        {
            [string[]]$currentVirtualDir.ExternalAuthenticationMethods = $null
            Write-Warning "ExternalAuthenticationMethods is null for $($VirtualDirectory.Name) on $($VirtualDirectory.Server)."
        }

        $currentVirtualDir
}
