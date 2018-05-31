<#

.SYNOPSIS
    Deploy and test EDU against a test lab.

.DESCRIPTION
    This script copies a pre-generated EDU zip file to a lab for testing purposes.  Once copied,
    the contents are extracted and the primary EDU script is run in the remote environment.  
    After the script completes, the json output is analyzed against an expected result.  The script 
    will return $True if successful, $False if the result does not match the expected output.

#>

[CmdletBinding()]
param (
    [string]
    $BuildNumber,

    [string]
    $LabIpAddress,
    
    [string]
    $Password,
    
    [string]
    $Username,
    
    [string]
    $ZipLibrary = ".\Ionic.Zip.dll",

    [string]
    $ZipFile
)

function Map-PSDrive()
{
    Write-Host "Connecting PSDrive to $eduFolderUnc"

    New-PSDrive -Name "EDU_CI_$labName" -PSProvider FileSystem -Root $eduFolderUnc -Credential $credential 

    Verify-RemoteFolders
}

function Verify-RemoteFolders()
{
    Write-Host "Verifying $buildFolderUnc exists"

    if (!(Test-Path -Path $buildFolderUnc))
    {
        Write-Host "Folder $buildFolderUnc was not found, creating new folder"
        New-Item -ItemType Directory -Path $buildFolderUnc
    }
    else
    {
        Write-Host "Folder $buildFolderUnc was found, clearing existing folder"
        Remove-Item "$buildFolderUnc" -Force -Recurse
        New-Item -ItemType Directory -Path $buildFolderUnc
    }

    Transfer-Files
}

function Transfer-Files()
{
    Write-Host "Copying $ZipFile to $buildFolderUnc"
    Copy-Item $ZipFile -Destination $buildFolderUnc

    Write-Host "Copying $ZipLibrary to $buildFolderUnc"
    Copy-Item $ZipLibrary -Destination $buildFolderUnc
    
    Extract-ZipContents
}

function Extract-ZipContents()
{
    Write-Host "Extracting zip files from $remoteZipFile to $remoteBuildFolder on $LabIpAddress"

    $scriptBlock = 
    {
        param(
            [string]
            $ZipFile,

            [string]
            $OutputPath
        )
        
        Add-Type -Path "$OutputPath\Ionic.Zip.dll"
        
        $zip = [Ionic.Zip.ZIPFile]::Read($ZipFile)
        $zip | % { $_.Extract($OutputPath, [Ionic.Zip.ExtractExistingFileAction]::OverWriteSilently) }
    }
    
    Invoke-Command -ComputerName $LabIpAddress -Credential $credential -ScriptBlock $scriptBlock -ArgumentList $remoteZipFIle, $remoteBuildFolder

    Execute-Script
}

function Execute-Script()
{
    Write-Host "Executing EDU script remotely on $LabIpAddress"

	& .\PsExec.exe "\\$LabIpAddress" -w $remoteBuildFolder -u $Username -p $Password /accepteula cmd /c "echo . | powershell -noninteractive -command Import-Module $remoteBuildFolder\EnvironmentDiscoveryUtility.psd1; Start-EnvironmentDiscovery;"

    Analyze-Results
}

function Analyze-Results()
{

}

#region Fields

$result = $false

$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $Username, $securePassword

$zipName = [System.IO.Path]::GetFileName($ZipFile)

$labName = $LabIpAddress.Replace(".", "")

$eduFolderUnc = "\\$LabIpAddress\c$\edu_ci"
$buildFolderUnc = "$eduFolderUnc\$BuildNumber"

$remoteBuildFolder = "c:\edu_ci\$BuildNumber"	
$remoteZipFile = "c:\edu_ci\$BuildNumber\$zipName"

#endregion

Map-PSDrive

Write-Host "Test results were $result"

$result




