﻿function Start-EnvironmentDiscovery
{
    <#
    .SYNOPSIS
        This cmdlet will start a run of the Environment Discovery Utility.  

    .DESCRIPTION
        This cmdlet will start a run of the Environment Discovery Utility.  This utility gathers important information regarding Microsoft products for the purpose of evaluating customer environments to aid in the scoping of projects.

    .PARAMETER Modules
        An array of strings indicating which modules the Environment Discovery Utility should run.  This defaults to 'All'

    .OUTPUTS
        A JSON representation of the discovered environment.

    .EXAMPLE
        Start-EnvironmentDiscovery -Modules All

    .EXAMPLE
        Start-EnvironmentDiscovery -Modules Exchange,AD
    #>

    [CmdletBinding()]
    param (
        # An array of strings indicating which modules the Environment Discovery Utility should run.  Possible values: AD, Exchange, All.  This defaults to 'All'
        [ValidateSet("ad","exchange","all")]
        [array]
        $Modules = @('all')
    )

    begin
    {
        $environment = @{}
        $sessionGuid = [GUID]::NewGuid()
        $environment.Add('SessionId', $sessionGuid)
        $environment.Add('TimeStamp', $( ([DateTime]::UtcNow | Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ") ))
        $outPutPath = ".\environment-$sessionGuid.json"
    }
    process
    {
        $allModules = @('ad','exchange')

        foreach ($module in $allModules)
        {
            if(($Modules -like 'all') -or ($Modules -contains $module))
            {
                switch ($module)
                {
                    'ad'
                    {
                        $activeDirectoryObject = Start-ActiveDirectoryDiscovery
                        $environment.Add("Active-Directory",$activeDirectoryObject)
                    }
                    'exchange'
                    {
                        $exchangeObject = Start-ExchangeDiscovery
                        $environment.Add("Exchange",$exchangeObject)
                    }
                }
            }
        }

        $environment | SerializeTo-Json | Set-Content -Path $outPutPath -Encoding UTF8 -Force
    }
}

New-Alias -Name "sedu" -Value "Start-EnvironmentDiscovery" -Description "Alias for Start-EnvironmentDiscovery" -Scope Global