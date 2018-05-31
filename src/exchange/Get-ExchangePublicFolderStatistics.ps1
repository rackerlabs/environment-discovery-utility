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
                $publicFolderStats.itemCount = $publicFolderStatistic.itemCount
                if ((Get-ExchangeServer $env:ComputerName | Select-Object AdminDisplayVersion) -like "*15.0*")
                {
                    $publicFolderStats.totalItemSizeKB = $publicFolderStatistic.totalItemSize.ToKB()
                    $publicFolderStats.Identity = $publicFolderStatistic.Identity.ObjectGUID  
                }
                else 
                {
                    $publicFolderStats.totalItemSizeKB = $publicFolderStatistic.totalItemSize.value.ToKB()
                    $publicFolderStats.Identity = $publicFolderStatistic.EntryID  
                }
                $discoveredPublicFolderStatistics += $PublicFolderStats
            }
            $discoveredPublicFolderStatistics
        }        
    }
}
