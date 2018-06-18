function Start-EnvironmentDiscovery
{
    <#
        .SYNOPSIS
            This cmdlet will start a run of the Environment Discovery Utility.  

        .DESCRIPTION
            This cmdlet will start a run of the Environment Discovery Utility.  This utility gathers important information regarding Microsoft products for the purpose of evaluating customer environments to aid in the scoping of projects.

        .PARAMETER Modules
            An array of strings indicating which modules the Environment Discovery Utility should run.  This defaults to 'All'

        .PARAMETER OutputFolder
            A string to designate the file path they want all files to be created on. This defaults to the Users AppData Temp file location

        .OUTPUTS
            A JSON representation of the discovered environment.

        .EXAMPLE
            Start-EnvironmentDiscovery -Modules All -OutputFolder c:\temp

        .EXAMPLE
            Start-EnvironmentDiscovery -Modules Exchange,AD -OutputFolder c:\temp
    #>

    [CmdletBinding()]
    param (
        # An array of strings indicating which modules the Environment Discovery Utility should run.  Possible values: AD, Exchange, All.  This defaults to "All"
        [ValidateSet("ad","exchange","all")]
        [array]
        $Modules = @("all"),
        [string]
        $OutputFolder = "$env:USERPROFILE\AppData\Local\Temp"
    )

    begin
    {
        clear
        $sessionGuid = [GUID]::NewGuid()
        try {
            if (Test-Path "$OutputFolder\EnvironmentDiscovery")
            {
                mkdir -Path $OutputFolder -name EnvironmentDiscovery
            }
            else 
            {
                Write-Host "File Location already created. Skipping Folder Creation"    
            }
        }
        catch {
            Write-Host "The user does not have the required permissions to create objects in $OutputFolder. Reverting to UserProfile's Desktop"
            $outputFolder = "$env:USERPROFILE\AppData\Local\Temp"
            mkdir -Path $OutputFolder -name EnvironmentDiscovery
        }
        $logPath = "$OutputFolder\EnvironmentDiscovery\environment-$sessionGuid.log"
        Enable-Logging $logPath
        $environment = @{}
        $environment.Add("SessionId", $sessionGuid)
        $environment.Add("TimeStamp", $(([DateTime]::UtcNow | Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")))
        $jsonPath = "$OutputFolder\EnvironmentDiscovery\environment-$sessionGuid.json"
    }
    process
    {
        $allModules = @("ad","exchange")
        Write-Log -Level "VERBOSE" -Message "Initializing EDU Module" -Activity "Environment Discovery Utility" -WriteProgress

        foreach ($module in $allModules)
        {
            Write-Log -Level "VERBOSE" -Message "Executing $($module.ToUpper()) Module." -Activity "Environment Discovery Utility"
            if (($Modules -like "all") -or ($Modules -contains $module))
            {
                switch ($module)
                {
                    "ad"
                    {
                        $activeDirectoryObject = Start-ActiveDirectoryDiscovery
                        $environment.Add("ActiveDirectory",$activeDirectoryObject)
                    }
                    "exchange"
                    {
                        $exchangeObject = Start-ExchangeDiscovery
                        $environment.Add("Exchange",$exchangeObject)
                    }
                }
            }
        }

        Write-Log -Level "VERBOSE" -Message "Packaging EDU Results" -Activity "Environment Discovery Utility" -WriteProgress
        $environment.Add("Log",$Global:logEntries)
        $environment | SerializeTo-Json | Set-Content -Path $jsonPath -Encoding UTF8 -Force
    }
    end
    {
        Write-Log -Level "VERBOSE" -Message "Environment Discovery Utility completed" -Activity "Environment Discovery Utility" -ProgressComplete $true -WriteProgress
        Write-Host "Files are located in $OutputFolder"
        Disable-Logging
    }
}

New-Alias -Name "sedu" -Value "Start-EnvironmentDiscovery" -Description "Alias for Start-EnvironmentDiscovery" -Scope Global
