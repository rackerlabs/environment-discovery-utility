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
            A string to designate the file path to place all files generated by EDU. This defaults to the Users desktop file location

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
        $OutputFolder = "$((Get-Location).Path)"
    )

    begin
    {
        Clear-Host

        $OutputFolder = "$($OutputFolder.TrimEnd('/\'))"
        $environmentName = (Get-WmiObject Win32_ComputerSystem).Domain.ToLower()
        $powershellVersion = [string]$PSVersionTable.PSVersion
        $netVersion = [string]$PSVersionTable.CLRVersion
        $sessionGuid = [GUID]::NewGuid()

        $logPath = "$($OutputFolder)\edu-$environmentName.log"
        $jsonPath = "$($OutputFolder)\edu-$environmentName.json"

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
        $environment.Add("TimeStamp", $([DateTime]::UtcNow | Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"))

        Write-Log -Level "DEBUG" -Activity "Setup" -Message "Modules: $Modules"
        Write-Log -Level "DEBUG" -Activity "Setup" -Message "Output Folder: $OutputFolder"
        Write-Log -Level "DEBUG" -Activity "Setup" -Message "Environment Name: $environmentName"
        Write-Log -Level "DEBUG" -Activity "Setup" -Message "Session GUID: $sessionGuid"
        Write-Log -Level "DEBUG" -Activity "Setup" -Message "Temp Folder: $tempFolder"
        Write-Log -Level "DEBUG" -Activity "Setup" -Message "Log Path: $logPath"
        Write-Log -Level "DEBUG" -Activity "Setup" -Message "JSON Path: $jsonPath"
        Write-Log -Level "DEBUG" -Activity "Setup" -Message "PowerShell Version: $powershellVersion"
        Write-Log -Level "DEBUG" -Activity "Setup" -Message ".NET Version: $netVersion"
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

        if (Test-Path $jsonPath)
        {
            Write-Log -Level "DEBUG" -Message "Found an existing json file in the destination directory.  Cleaning it up." -Activity "Environment Discovery Utility" -WriteProgress
            Remove-Item $jsonPath -Force
        }

        $environment | SerializeTo-Json | Set-Content -Path $jsonPath -Encoding UTF8 -Force

        try
        {
            Write-Output "Zipping EDU results."
            $zipFile = New-ZipFile -OutputFolder $OutputFolder -Files "$jsonPath","$logPath" -EnvironmentName $environmentName
            Write-Output "Zip file created at $zipFile."
        }
        catch 
        {
            Write-Error "Zip function failed to create zip file. Files are located in $tempFolder. $($_.Exception)" -ErrorAction Stop    
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
