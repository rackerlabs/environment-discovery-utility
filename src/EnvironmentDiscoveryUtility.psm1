function Start-EnvironmentDiscovery
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
		#clear
        $sessionGuid = [GUID]::NewGuid()
        $logPath = ".\environment-$sessionGuid.log"
        Enable-Logging -FilePath $logPath
        $environment = @{}
        $environment.Add('SessionId', $sessionGuid)
        $environment.Add('TimeStamp', $( ([DateTime]::UtcNow | Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ") ))
        $outPutPath = ".\environment-$sessionGuid.json"
    }
    process
    {
        $allModules = @('ad','exchange')
		Write-Log -Level 'VERBOSE' -Message 'Initializing EDU Module' -ProgressId 1 -Activity 'Environment Discovery Utility'

        foreach ($module in $allModules)
        {
            if (( $Modules -like 'all') -or ($Modules -contains $module))
            {
                switch ($module)
                {
                    'ad'
                    {
                        $activeDirectoryObject = Start-ActiveDirectoryDiscovery -ProgressId 2
                        $environment.Add("Active-Directory",$activeDirectoryObject)
                    }
                    'exchange'
                    {
                        $exchangeObject = Start-ExchangeDiscovery -ProgressId 3
                        $environment.Add("Exchange",$exchangeObject)
                    }
                }
            }
        }

        $environment | SerializeTo-Json | Set-Content -Path $outPutPath -Encoding UTF8 -Force
    }
    end
    {
        Write-Log -Level 'VERBOSE' -Message 'end' -ProgressId 99 -Activity 'Environment Discovery Utility' -ProgressComplete $true
        Disable-Logging -LogFile $Global:logFile
    }
}

New-Alias -Name "sedu" -Value "Start-EnvironmentDiscovery" -Description "Alias for Start-EnvironmentDiscovery" -Scope Global