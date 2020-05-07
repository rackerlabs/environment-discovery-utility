function Get-ExchangePublicFolderStatistics
{
    <#

        .SYNOPSIS
            Discover Exchange public folder statistics.

        .DESCRIPTION
            Uses native Exchange cmdlets to discover public folder statistics.

        .OUTPUTS
            Returns a custom object containing public folder statistics.

        .EXAMPLE
            Get-ExchangePublicFolderStatistics -PublicFolders $publicFolders

    #>

    [CmdletBinding()]
    param (
        # PublicFolders The PublicFolders object from Exchange Discovery
        [object]
        $PublicFolders
    )

    $activity = "Public Folder Statistics"
    $discoveredPublicFolderStatistics = @()

    if ($PublicFolders.Mailboxes)
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Gathering modern public folder statistics. This may take some time without feedback." -WriteProgress
        $publicFolderStatistics = Get-PublicFolderStatistics
    }
    elseif ($PublicFolders.Databases)
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Gathering legacy public folder statistics. This may take some time without feedback." -WriteProgress

        foreach ($database in ($PublicFolders.Databases))
        {
            [string]$server = $database.Server

            $version = Get-ExchangeServer $server | Select-Object AdminDisplayVersion
            if ($version -like "*14.*")
            {
                $publicFolderStatistics += Get-PublicFolderStatistics -Server $server -ResultSize Unlimited
            }
            elseif ($version -like "*15.*")
            {
                $publicFolderStatistics += Get-PublicFolderStatistics
            }
            else
            {
                try 
                {
                    $publicFolderStatistics += Get-PublicFolderStatistics -Server $server
                }
                catch 
                {
                    Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for Public Folder statistics. $($_.Exception.Message)"
                }
            }
        }

        $publicFolderStatistics = $publicFolderStatistics | Sort-Object entryID -unique
    }
    else
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Did not find any Legacy or Modern Public Folders.  Skipping Statistics."
        return
    }

    if ($publicFolderStatistics.Count -gt 0)
    {
        foreach ($publicFolderStatistic in $publicFolderStatistics)
        {
            $publicFolder = Get-PublicFolder -Identity ($publicFolderStatistic.EntryID.tostring())
            $publicFolderStats = $null
            $publicFolderStats = "" | Select-Object Identity, ItemCount, TotalItemSizeKB, IsMailEnabled, LastModificationTime
            $publicFolderStats.ItemCount = $publicFolderStatistic.itemCount
            $publicFolderStats.Identity = $publicFolderStatistic.entryID
            $publicFolderStats.IsMailEnabled = [bool]$publicFolder.MailEnabled
            $publicFolderStats.LastModificationTime =  $publicFolderStatistic.LastModificationTime

            if ($version -like "*14.*")
            {
                $publicFolderStats.TotalItemSizeKB = Convert-ExchangeDataStatisticToKB -Property $publicFolderStatistic.totalItemSize.value
            }
            elseif ($PublicFolders.Mailboxes)
            {
                $publicFolderStats.TotalItemSizeKB = Convert-ExchangeDataStatisticToKB -Property $publicFolderStatistic.totalItemSize
            }

            $discoveredPublicFolderStatistics += $publicFolderStats
        }
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "Did not get any results from Get-PublicFolderStatistics."
    }

    $discoveredPublicFolderStatistics
}
