<#

    .SYNOPSIS
        Deploy and test EDU against a test lab.

    .DESCRIPTION
        This script copies a pre-generated EDU zip file to a lab for testing purposes.  Once copied,
        the contents are extracted and the primary EDU script is run in the remote environment.  
        After the script completes, the json output is analyzed against an expected result.  The script 
        will return $True if successful, $False if the result does not match the expected output.

    .PARAMETER BuildNumber
        Used to generate the final zip file name.
        
    .PARAMETER LabIpAddress
        Server IP address used to deploy and test the EDU module.
        
    .PARAMETER Password
        Password used to log onto the server specified by LabIpAddress.
        
    .PARAMETER PsExec
        Path to PsExec executable, default to .\build\PsExec.exe.
        
    .PARAMETER Username
        Username used to log onto the server specified by LabIpAddress.

    .PARAMETER EduZipFile
        Path to zip file containing EDU module files.
        
    .PARAMETER ZipLibrary
        Path to Ionic.Zip.Dll library, used to decompress zip file on remote server.
        
    .OUTPUTS
        Returns the number of errors found in the log file.

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $BuildNumber,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $EduZipFile,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $LabIpAddress,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Password,

    [string]
    [ValidateNotNullOrEmpty()]
    $PsExec = ".\build\lib\PsExec.exe",
        
    [string]
    [ValidateNotNullOrEmpty()]
    $Username,
    
    [string]
    [ValidateNotNullOrEmpty()]
    $ZipLibrary = ".\build\lib\Ionic.Zip.dll"
)

$ErrorActionPreference = "Stop"

$Script:errorCount = 0

$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $Username, $securePassword

$remoteBaseFolder = "\\$LabIpAddress\c$\edu_ci"
$remoteBuildFolder = "$remoteBaseFolder\$BuildNumber"

$buildFolder = "c:\edu_ci\$BuildNumber"   

function Set-PSDrive()
{
    $labName = $LabIpAddress.Replace(".", "")

    Write-Host "Connecting PSDrive to $remoteBaseFolder"

    New-PSDrive -Name "EDU_CI_$labName" -PSProvider FileSystem -Root $remoteBaseFolder -Credential $credential 

    Confirm-RemoteFolders
}

function Confirm-RemoteFolders()
{
    Write-Host "Verifying $remoteBuildFolder exists"

    if (!(Test-Path -Path $remoteBuildFolder))
    {
        Write-Host "Folder $remoteBuildFolder was not found, creating new folder"
        New-Item -ItemType Directory -Path $remoteBuildFolder
    }
    else
    {
        Write-Host "Folder $remoteBuildFolder was found, clearing existing folder"
        Remove-Item "$remoteBuildFolder" -Force -Recurse
        New-Item -ItemType Directory -Path $remoteBuildFolder
    }

    Copy-Files
}

function Copy-Files()
{
    Write-Host "Copying $EduZipFile to $remoteBuildFolder"
    Copy-Item $EduZipFile -Destination $remoteBuildFolder

    Write-Host "Copying $ZipLibrary to $remoteBuildFolder"
    Copy-Item $ZipLibrary -Destination $remoteBuildFolder
    
    Install-RemoteModule
}

function Install-RemoteModule()
{
    $zipName = [System.IO.Path]::GetFileName($EduZipFile)
    $remoteZipFile = "c:\edu_ci\$BuildNumber\$zipName"

    Write-Host "Extracting zip files from $remoteZipFile to $buildFolder on $LabIpAddress"

    $scriptBlock = 
    {
        param(
            [string]
            $EduZipFile,

            [string]
            $OutputPath
        )
        
        Add-Type -Path "$OutputPath\Ionic.Zip.dll"
        
        $zip = [Ionic.Zip.ZIPFile]::Read($EduZipFile)
        $zip | ForEach-Object { $_.Extract($OutputPath, [Ionic.Zip.ExtractExistingFileAction]::OverWriteSilently) }
        $zip.Dispose()
    }
    
    Invoke-Command -ComputerName $LabIpAddress -Credential $credential -ScriptBlock $scriptBlock -ArgumentList $remoteZipFile, $buildFolder

    Invoke-RemoteModule
}

function Invoke-RemoteModule()
{
    $command = "$buildFolder\Invoke-Discovery.ps1";
    $outputFolder = "-OutputFolder $buildFolder";

    Write-Host "Executing EDU script remotely on $LabIpAddress, remote command is $command, output folder is $outputFolder"

    & $PsExec "\\$LabIpAddress" -w $buildFolder -u $Username -p $Password /accepteula cmd /c "powershell -noninteractive -command $command $outputFolder -Verbose;"
       
    if ($LastExitCode -ne 0)
    {
	    throw "Detected failure condition when running EDU in PsExec session"
    }

    Confirm-OutputDirectory
}

function Confirm-OutputDirectory()
{
    Write-Host "Preparing output directory $PSScriptRoot\$LabIpAddress"

    New-Item -ItemType Directory -Force -Path "$PSScriptRoot\$LabIpAddress"

    Remove-Item "$PSScriptRoot\$LabIpAddress\*.*" -Force | Out-Null

    Get-Results
}

function Get-Results()
{   
    Write-Host "Copying $remoteBuildFolder\edu-*.zip to $PSScriptRoot\$LabIpAddress"

    Copy-Item "$remoteBuildFolder\edu-*.zip" -Destination "$PSScriptRoot\$LabIpAddress" -Force

    Set-Artifact
}

function Set-Artifact()
{
    Write-Host "Renaming $PSScriptRoot\$LabIpAddress\edu-*.zip to edu-$LabIpAddress.zip"

    Get-ChildItem "$PSScriptRoot\$LabIpAddress\edu-*.zip" | Select-Object -First 1 | Rename-Item -NewName "edu-$LabIpAddress.zip"

    Confirm-Results
}

function Confirm-Results()
{
    Write-Host "Verifying $PSScriptRoot\$LabIpAddress\edu-*.zip size is greater than 0"

    $output = Get-ChildItem "$PSScriptRoot\$LabIpAddress\edu-*.zip" | Select-Object -First 1

    if ($output.length -gt 0kb) 
    {
        Write-Host "EDU zip file size was greater than 0"      
    }
    else
    {
        throw "EDU zip file size was 0, test failed"
    }
    
    Get-Logs
}

function Get-Logs()
{
    Write-Host "Extracting logs from zip file $PSScriptRoot\$LabIpAddress\edu-$LabIpAddress.zip"

    Add-Type -Path $ZipLibrary

    $zip = [Ionic.Zip.ZIPFile]::Read("$PSScriptRoot\$LabIpAddress\edu-$LabIpAddress.zip")
    $zip | ForEach-Object { $_.Extract("$PSScriptRoot\$LabIpAddress", [Ionic.Zip.ExtractExistingFileAction]::OverWriteSilently) }
    $zip.Dispose()

    Search-Logs
}

function Search-Logs()
{
    $logFile = Get-ChildItem "$PSScriptRoot\$LabIpAddress\edu-*.log" | Select-Object -First 1

    Write-Host "Parsing logs from $logFile"

    . $PSScriptRoot\Get-LogErrors.ps1
    $Script:errorCount = Get-LogErrors -LabIpAddress $LabIpAddress -LogFile $logFile
    
    Write-Host "Found $($Script:errorCount) errors in $logFile"

    Show-TestResults
}

function Show-TestResults()
{
    if ($errorCount -gt 0)
    {
        Write-Host "Remote EDU script execution completed with $errorCount logged errors, please check the log file for more information"
    }
    else
    {
        Write-Host "Remote EDU script execution completed successfully"
    }
}

Set-PSDrive

$Script:errorCount