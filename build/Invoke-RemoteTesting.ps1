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
        Returns $True if a non-zero json file was generated by the script, $False if not.

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
    $PsExec = ".\build\PsExec.exe",
        
    [string]
    [ValidateNotNullOrEmpty()]
    $Username,
    
    [string]
    [ValidateNotNullOrEmpty()]
    $ZipLibrary = ".\build\Ionic.Zip.dll"
)

$ErrorActionPreference = "Stop"

$Script:result = $false

$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $Username, $securePassword

$remoteBaseFolder = "\\$LabIpAddress\c$\edu_ci"
$remoteBuildFolder = "$remoteBaseFolder\$BuildNumber"

$buildFolder = "c:\edu_ci\$BuildNumber"   

function Map-PSDrive()
{
    $labName = $LabIpAddress.Replace(".", "")

    Write-Host "Connecting PSDrive to $remoteBaseFolder"

    New-PSDrive -Name "EDU_CI_$labName" -PSProvider FileSystem -Root $remoteBaseFolder -Credential $credential 

    Verify-RemoteFolders
}

function Verify-RemoteFolders()
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

    Transfer-Files
}

function Transfer-Files()
{
    Write-Host "Copying $EduZipFile to $remoteBuildFolder"
    Copy-Item $EduZipFile -Destination $remoteBuildFolder

    Write-Host "Copying $ZipLibrary to $remoteBuildFolder"
    Copy-Item $ZipLibrary -Destination $remoteBuildFolder
    
    Extract-ZipContents
}

function Extract-ZipContents()
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
    }
    
    Invoke-Command -ComputerName $LabIpAddress -Credential $credential -ScriptBlock $scriptBlock -ArgumentList $remoteZipFile, $buildFolder

    Invoke-RemoteEduModule
}

function Invoke-RemoteEduModule()
{
    $command = "$buildFolder\Invoke-Discovery.ps1";
    $outputFolder = "-OutputFolder $buildFolder";

    Write-Host "Executing EDU script remotely on $LabIpAddress, remote command is $command, output folder is $outputFolder"

    & $PsExec "\\$LabIpAddress" -w $buildFolder -u $Username -p $Password /accepteula cmd /c "powershell -noninteractive -command $command $outputFolder -Verbose;"
       
    if ($LastExitCode -ne 0)
    {
	    throw "Detected failure condition when running edu in PsExec session"
    }

    Prepare-OutputDirectory
}

function Prepare-OutputDirectory()
{
     New-Item -ItemType Directory -Force -Path "$PSScriptRoot\$LabIpAddress"

     Remove-Item "$PSScriptRoot\$LabIpAddress\edu-*.zip" -Force | Out-Null

     Copy-Results
}

function Copy-Results()
{   
    Copy-Item "$remoteBuildFolder\edu-*.zip" -Destination "$PSScriptRoot\$LabIpAddress"

    Analyze-Results
}

function Analyze-Results()
{
    $output = Get-ChildItem "$PSScriptRoot\$LabIpAddress\edu-*.zip" | Select-Object -First 1

    if ($output.length -gt 0kb) 
    {
        Write-Host "EDU zip file size was greater than 0, setting result to $true"      
        $Script:result = $true
    }
    else
    {
        throw "EDU zip file size was 0, test failed"
    }
    
    Rename-Artifact
}

function Rename-Artifact()
{
    Get-ChildItem "$PSScriptRoot\$LabIpAddress\edu-*.zip" | Select-Object -First 1 | Rename-Item -NewName "edu-$LabIpAddress.zip"

    Output-TestResults
}

function Output-TestResults()
{
    if ($Script:result -eq $true)
    {   
        Write-Host "Test completed successfully"
    }
    else
    {
        throw "Tests failed, please check the log file for more information"
    }
}

Map-PSDrive

$Script:result 