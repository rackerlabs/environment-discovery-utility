function Get-ExchangePublicFolderStatistics
{
    [CmdletBinding()]
    param (
        [bool]
        $ExchangeShellConnected
    )

    if ($ExchangeShellConnected)
    {
        $PublicFolderStatistics = Get-PublicFolderStatistics -resultSize Unlimited | Select-Object Name,FolderPath,ItemCount,TotalItemSize
        $DiscoveredPublicFolderStatistics = $null
        foreach ($publicFolderStatistic in $PublicFolderStatistics)
        {
            
            $PublicFolderStats = $null
            $PublicFolderStats = "" | Select-Object Name,FolderPath,ItemCount,TotalItemSize    
            $PublicFolderStats.Name = $publicFolderStatistic.Name        
                        
            if($publicFolderStatistic.FolderPath -is [system.array])
            {
                $PublicFolderStats.FolderPath = "\" + ($publicFolderStatistic.FolderPath) -join '\'
            }
            
            else 
            {
                $PublicFolderStats.FolderPath = $publicFolderStatistic.FolderPath
            }

            $PublicFolderStats.ItemCount = $publicFolderStatistic.ItemCount
            $PublicFolderStats.TotalItemSize = $publicFolderStatistic.TotalItemSize
            $DiscoveredPublicFolderStatistics += $PublicFolderStats
        }
        $DiscoveredPublicFolderStatistics
    }
}