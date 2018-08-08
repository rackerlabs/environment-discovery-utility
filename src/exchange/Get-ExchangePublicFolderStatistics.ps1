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
            Get-ExchangePublicFolderStatistics -ExchangeShellConnected $exchangeShellConnected -PublicFolders $publicFolders

    #>

    [CmdletBinding()]
    param (
        [bool]
        $ExchangeShellConnected,

        [object]
        $PublicFolders
    )

    $activity = "Public Folder Statistics"
    $discoveredPublicFolderStatistics = @()

    if ($ExchangeShellConnected)
    {
        if ($PublicFolders.Mailboxes)
        {
            Write-Log -Level "VERBOSE" -Activity $activity -Message "Gathering modern public folder statistics. This may take some time without feedback." -WriteProgress
            $publicFolderStatistics = Get-PublicFolderStatistics

            if ($publicFolderStatistics.Count -gt 0)
            {
                foreach ($publicFolderStatistic in $publicFolderStatistics)
                {
                    $publicFolderStats = $null
                    $publicFolderStats = "" | Select-Object Identity, ItemCount, TotalItemSizeKB
                    $publicFolderStats.ItemCount = $publicFolderStatistic.itemCount
                    $publicFolderStats.Identity = $publicFolderStatistic.identity.objectGUID

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
                Write-Log -Level "WARNING" -Activity $activity -Message "Did not get any results from Get-PublicFolderStatistics."
            }
        }
        elseif ($PublicFolders.Databases)
        {
            Write-Log -Level "VERBOSE" -Activity $activity -Message "Gathering legacy public folder statistics. This may take some time without feedback." -WriteProgress
            $publicFolderStatistics = @()

            foreach ($database in ($PublicFolders.Databases))
            {
                [string]$server = $database.ParentServer
                $version = Get-ExchangeServer $server | Select-Object AdminDisplayVersion
                if ($version -like "*14.*")
                {
                    $publicFolderStatistics += Get-PublicFolderStatistics -Server $server -ResultSize Unlimited
                }
                else
                {
                    $publicFolderStatistics += Get-PublicFolderStatistics -Server $server
                }
            }

            $publicFolderStatistics = $publicFolderStatistics | Sort-Object entryID -unique

            if ($publicFolderStatistics.Count -gt 0)
            {
                foreach ($publicFolderStatistic in $publicFolderStatistics)
                {
                    $publicFolderStats = $null
                    $publicFolderStats = "" | Select-Object Identity, ItemCount, TotalItemSizeKB
                    $publicFolderStats.ItemCount = $publicFolderStatistic.itemCount
                    $publicFolderStats.Identity = $publicFolderStatistic.entryID

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
                Write-Log -Level "WARNING" -Activity $activity -Message "Did not get any results from Get-PublicFolderStatistics."
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
