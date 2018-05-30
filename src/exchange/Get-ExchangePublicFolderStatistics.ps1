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
            $publicFolderStatistics = Get-PublicFolderStatistics -resultSize Unlimited
            $discoveredPublicFolderStatistics = @()
            
            if ((Get-ExchangeServer $env:ComputerName).AdminDisplayVersion -like "Version 15*")
            {
                foreach ($publicFolderStatistic in $publicFolderStatistics)
                {
                    
                    $publicFolderStats = $null
                    $publicFolderStats = "" | Select-Object name,folderPath,itemCount,totalItemSizeKB    
                    $publicFolderStats.name = $publicFolderStatistic.name        
                    $publicFolderStats.folderPath = ($publicFolderStatistic.folderPath) -join '\'
                    $publicFolderStats.itemCount = $publicFolderStatistic.itemCount
                    $publicFolderStats.totalItemSizeKB = $publicFolderStatistic.totalItemSize.ToKB()
                    $discoveredPublicFolderStatistics += $PublicFolderStats
                }
                $discoveredPublicFolderStatistics
            }
            
            else 
            {
                foreach ($publicFolderStatistic in $publicFolderStatistics)
                {
                    $publicFolderStats = $null
                    $publicFolderStats = "" | Select-Object name,folderPath,itemCount,totalItemSizeKB    
                    $publicFolderStats.name = $publicFolderStatistic.name        
                    $publicFolderStats.folderPath = $publicFolderStatistic.folderPath
                    $publicFolderStats.itemCount = $publicFolderStatistic.itemCount
                    $publicFolderStats.totalItemSizeKB = $publicFolderStatistic.totalItemSize.Value.ToKB()
                    $discoveredPublicFolderStatistics += $PublicFolderStats
                }
                $discoveredPublicFolderStatistics
            }
        }        
    }
}
