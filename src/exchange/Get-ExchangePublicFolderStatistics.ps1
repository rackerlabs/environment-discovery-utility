function Get-ExchangePublicFolderStatistics
{
    [CmdletBinding()]
    param (
        [bool]
        $ExchangeShellConnected
    )

    $activity = "Public Folder Statistics"

    if ($ExchangeShellConnected)
    {
        if (Get-PublicFolder -ErrorAction SilentlyContinue)
        {
            $discoveredPublicFolderStatistics = @()
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

            $discoveredPublicFolderStatistics
        }
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "Skipping Exchange Public Folder statistics. No connection to Exchange."
    }
}
