function Get-ExchangePublicFolderDatabases
{
    <#

        .SYNOPSIS
            Discover attributes for legacy public folder databases in Exchange.
    
        .DESCRIPTION
            Query Exchange to find public folder database settings in Active Directory.
    
        .OUTPUTS
            Returns a custom object containing public folder database properties.
    
        .EXAMPLE
            Get-ExchangePublicFolderDatabases -DomainDN $domainDN
    
    #>

    [CmdletBinding()]
    param (
        # Servers An array of servers to run discovery against
        [array]
        $exchangeServers
    )

    $activity = "Public Folder Databases"
    $discoveredLegacyPublicFolders = @()
    $mailboxServers = $exchangeServers | Where-Object {$_.ServerRole -like "*Mailbox*"}

    if ($mailboxServers.Count -ge 1)
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for Public Folder databases." -WriteProgress

        foreach ($mailboxServer in $mailboxServers)
        {
            try
            {
                $legacyPublicFolders = Get-PublicFolderDatabase -Server $mailboxServer.Name
            }
            catch
            {
                Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for Public Folder databases. $($_.Exception.Message)"
                return
            }
        }
    }

    if ($legacyPublicFolders)
    {
        foreach ($legacyPublicFolder in $legacyPublicFolders)
        {
            $discoveredLegacyPublicFolder = $null
            $discoveredLegacyPublicFolder = "" | Select-Object ObjectGuid, Server
            $discoveredLegacyPublicFolder.ObjectGuid = $legacyPublicFolder.GUID
            $discoveredLegacyPublicFolder.Server = $legacyPublicFolder.Server

            $discoveredLegacyPublicFolders += $discoveredLegacyPublicFolder
        }
    }
    else
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Did not find Legacy Public Folder databases in Exchange." -WriteProgress
    }

    $discoveredLegacyPublicFolders
}
