<#

.SYNOPSIS
	Deploy and test EDU against a test lab.

.DESCRIPTION
	This script will copy a pre-generated EDU zip file to a lab for testing purposes.  Once copied,
	the contents will be extracted and the primary EDU script will be run in the remote environment.  
	After the script completes, the json output is analyzed against an expected result.  The script 
	will return $True if successful, $False if the result does not match the expected output.

#>

[CmdletBinding()]
param (
	[string]
	$ZipFile,
	
	[string[]]
	$LabIpAddress,
	
	[string]
	$Username,
	
	[string]
	$Password
)

[bool]$result = $false

function Copy-ZipFile()
{
	Extract-ZipContents
}

function Extract-ZipContents()
{
	Execute-Script
}

function Execute-Script()
{
	Analyze-Results
}

function Analyze-Results()
{

}

Copy-ZipFile

$result




