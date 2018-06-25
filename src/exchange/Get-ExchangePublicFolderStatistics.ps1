function Get-ExchangePublicFolderStatistics
{
    [CmdletBinding()]
    param (
        [bool]
        $ExchangeShellConnected,

        [object]
        $PublicFolders
    )

    $activity = "Public Folder Statistics"
    $discoveredPublicFolderStatistics = @()

    if ($PublicFolders.Mailboxes -or $PublicFolders.Databases)
    {
        if ($ExchangeShellConnected)
        {
            Write-Log -Level "VERBOSE" -Activity $activity -Message "Gathering Public Folder statistics. This may take some time without feedback." -WriteProgress
            $publicFolderStatistics = Get-PublicFolderStatistics -ResultSize Unlimited

            foreach ($publicFolderStatistic in $publicFolderStatistics)
            {
                $publicFolderStats = $null
                $publicFolderStats = "" | Select-Object Identity, ItemCount, TotalItemSizeKB
                $publicFolderStats.ItemCount = $publicFolderStatistic.itemCount

                if ((Get-ExchangeServer $env:ComputerName | Select-Object AdminDisplayVersion) -like "*15.*")
                {
                    $publicFolderStats.Identity = $publicFolderStatistic.identity.objectGUID
                }
                else
                {
                    $publicFolderStats.Identity = $publicFolderStatistic.entryID
                }

                if ($PSVersionTable.PSVersion.Major -ge 3)
                {
                    $publicFolderStats.TotalItemSizeKB = $publicFolderStatistic.totalItemSize.ToKB()
                }
                else
                {
                    $publicFolderStats.TotalItemSizeKB = $publicFolderStatistic.totalItemSize.value.ToKB()
                }

                $discoveredPublicFolderStatistics += $publicFolderStats
            }
        }
        else
        {
            Write-Log -Level "WARNING" -Activity $activity -Message "Skipping Exchange Public Folder statistics. No connection to Exchange."
            return
        }
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "Skipping Exchange Public Folder statistics, no public folders found."
        return
    }

    $discoveredPublicFolderStatistics
}
