function Get-ExchangePublicFolderStatistics
{
    [CmdletBinding()]
    param (
        [bool]
        $ExchangeShellConnected
    )

    if ($ExchangeShellConnected)
    {
        $publicFolderStatistics = Get-PublicFolderStatistics -resultSize Unlimited | Select-Object name,folderPath,itemCount,totalItemSize
        $discoveredPublicFolderStatistics = $null
        foreach ($publicFolderStatistic in $publicFolderStatistics)
        {
            
            $publicFolderStats = $null
            $publicFolderStats = "" | Select-Object name,folderPath,itemCount,totalItemSize    
            $publicFolderStats.name = $publicFolderStatistic.name        
                        
            if($publicFolderStatistic.folderPath -is [system.array])
            {
                $publicFolderStats.folderPath = "\" + ($publicFolderStatistic.folderPath) -join '\'
            }
            
            else 
            {
                $publicFolderStats.folderPath = $publicFolderStatistic.folderPath
            }

            $publicFolderStats.itemCount = $publicFolderStatistic.itemCount
            $publicFolderStats.totalItemSize = $publicFolderStatistic.totalItemSize
            $discoveredPublicFolderStatistics += $PublicFolderStats
        }
        $discoveredPublicFolderStatistics
    }
}