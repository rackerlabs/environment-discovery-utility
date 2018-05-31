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
            foreach ($publicFolderStatistic in $publicFolderStatistics)
            {
                
                $publicFolderStats = $null
                $publicFolderStats = "" | Select-Object Identity,itemCount,totalItemSizeKB    
                $publicFolderStats.Identity = $publicFolderStatistic.Identity.ObjectGUID  
                $publicFolderStats.itemCount = $publicFolderStatistic.itemCount
                $publicFolderStats.totalItemSizeKB = $publicFolderStatistic.totalItemSize.ToKB()
                $discoveredPublicFolderStatistics += $PublicFolderStats
            }
            $discoveredPublicFolderStatistics
        }        
    }
}
