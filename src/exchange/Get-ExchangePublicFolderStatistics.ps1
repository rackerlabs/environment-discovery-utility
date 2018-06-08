function Get-ExchangePublicFolderStatistics
{
    [CmdletBinding()]
    param (
        [bool]
        $ExchangeShellConnected
    )

    if ($ExchangeShellConnected)
    {
        if (Get-PublicFolder -ErrorAction SilentlyContinue)
        {
            $discoveredPublicFolderStatistics = @()
            $publicFolderStatistics = Get-PublicFolderStatistics -ResultSize Unlimited

            foreach ($publicFolderStatistic in $publicFolderStatistics)
            {
                $percentComplete = (100 / $publicFolderStatistics.Count) * $x
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
        Write-Log -Level 'WARNING' -Activity $MyInvocation.MyCommand.Name -Message 'Skipping Exchange Public Folder statistics. No connection to Exchange.'
    }
}
