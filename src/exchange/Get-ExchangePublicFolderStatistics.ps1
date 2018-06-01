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
                $publicFolderStats = $null
                $publicFolderStats = "" | Select-Object Identity, ItemCount, TotalItemSizeKB    
                $publicFolderStats.ItemCount = $publicFolderStatistic.itemCount
				
                if ((Get-ExchangeServer $env:ComputerName | Select-Object AdminDisplayVersion) -like "*15.0*")
                {
                    $publicFolderStats.TotalItemSizeKB = $publicFolderStatistic.totalItemSize.ToKB()
                    $publicFolderStats.Identity = $publicFolderStatistic.identity.objectGUID  
                }
                else 
                {
                    $publicFolderStats.TotalItemSizeKB = $publicFolderStatistic.totalItemSize.value.ToKB()
                    $publicFolderStats.Identity = $publicFolderStatistic.entryID  
                }
				
                $discoveredPublicFolderStatistics += $publicFolderStats
            }
			
            $discoveredPublicFolderStatistics
        }        
    }
}
