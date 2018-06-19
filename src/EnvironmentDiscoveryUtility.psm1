﻿function Start-EnvironmentDiscovery
{
    <#
        .SYNOPSIS
            This cmdlet will start a run of the Environment Discovery Utility.  

        .DESCRIPTION
            This cmdlet will start a run of the Environment Discovery Utility.  This utility gathers important information regarding Microsoft products for the purpose of evaluating customer environments to aid in the scoping of projects.

        .PARAMETER Modules
            An array of strings indicating which modules the Environment Discovery Utility should run.  This defaults to 'All'

        .PARAMETER OutputFolder
            A string to designate the file path they want all files to be created on. This defaults to the Users desktop file location

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
        $OutputFolder = "$env:USERPROFILE\Desktop"
    )

    begin
    {
        Clear-Host
        $tempFolder = "$env:USERPROFILE\AppData\Local\Temp"
        $sessionGuid = [GUID]::NewGuid()
        $logPath = "$tempFolder\environment-$sessionGuid.log"
        $jsonPath = "$tempFolder\environment-$sessionGuid.json"
        
        try 
        {
            Enable-Logging $logPath
        }
        catch 
        {
            Write-Error "Failed to enable logging check to ensure $tempFolder exists and the account has write permissions. $($_.Exception.Message)" -ErrorAction Stop
        }
        
        $environment = @{}
        $environment.Add("SessionId", $sessionGuid)
        $environment.Add("TimeStamp", $(([DateTime]::UtcNow | Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")))
        
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
        Clear-Host
        try 
        {
            Write-Output "Zipping results of Environment Discover"
            $zipFilename = New-ZipFile -OutputFolder $OutputFolder -JsonPath $jsonPath -LogPath $logPath -SessionGUID $sessionGuid 
            Write-Output "Zip file $zipFilename created in $OutputFolder."
        }
        catch 
        {
            Write-Error "Zip function failed to create zip file. Files are located in $tempFolder. $($_.Exception.Message)" -ErrorAction Stop    
        }
        
    }
    end
    {
        Disable-Logging
        Write-Output "Removing files from temp location."
        Remove-Item $logPath -Force
        Remove-Item $jsonPath -Force  
        Write-Output "Cleanup completed."
    }
}

New-Alias -Name "sedu" -Value "Start-EnvironmentDiscovery" -Description "Alias for Start-EnvironmentDiscovery" -Scope Global
