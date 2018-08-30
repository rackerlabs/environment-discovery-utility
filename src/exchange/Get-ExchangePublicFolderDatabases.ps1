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
    param ()

    $activity = "Public Folder Databases"
    $discoveredLegacyPublicFolders = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for Public Folder databases." -WriteProgress
        $legacyPublicFolders = Get-PublicFolderDatabase
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for Public Folder databases. $($_.Exception.Message)"
        return
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
