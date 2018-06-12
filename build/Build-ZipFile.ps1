<#

	.SYNOPSIS
		Zip all EDU files.

	.DESCRIPTION
		Zip EDU scripts and libaries into one file for testing and distribution.

	.PARAMETER BuildNumber
		EDU build number.

	.EXAMPLE
		Build-ZipFile -BuildNumber 25

#>

[CmdletBinding()]
param (
	[Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
	[string]
	$BuildNumber
)

function Add-ZipFiles
{	
	foreach ($file in @($input))
	{
		$file.VersionInfo.FileName
		
		$relativePath = $file.VersionInfo.FileName -replace [Regex]::Escape($rootDir), ""
		$relativePath = $relativePath -replace [Regex]::Escape($file.Name), ""
		$relativePath
		
		$zipFile.AddFile($file.VersionInfo.FileName, $relativePath) | Out-Null
	}
}

function Zip-Scripts()
{
	Get-ChildItem "$rootDir\*.*" -Recurse | Add-ZipFiles
}

Set-Location -Path "$PSScriptRoot\..\src"
$rootDir = (Get-Location).Path
Set-Location -Path "$PSScriptRoot"

Add-Type -Path "$PSScriptRoot\Ionic.Zip.dll"
$zipFile = New-Object Ionic.Zip.ZipFile
$zipPath = "$PSScriptRoot\edu.v$BuildNumber.zip"

Zip-Scripts

if (Test-Path $zipPath)
{
	Remove-Item -Force -Confirm:$false $zipPath
}

$zipFile.UseZip64WhenSaving = "AsNecessary"
$zipFile.Save($zipPath)
$zipFile.Dispose()