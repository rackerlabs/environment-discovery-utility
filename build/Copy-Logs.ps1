<#

    .SYNOPSIS
        Copy EDU logs from a test lab.

    .DESCRIPTION
        Copy EDU logs from a test lab.

    .PARAMETER BuildNumber
        Used to find log files.
        
    .PARAMETER LabIpAddress
        IP address the logs are located at.
        
    .PARAMETER Password
        Password used to log onto the server specified by LabIpAddress.
        
    .PARAMETER Username
        Username used to log onto the server specified by LabIpAddress.

    .OUTPUTS
        None

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
    $LabIpAddress,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Password,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Username
)

$ErrorActionPreference = "Stop"

$remoteBaseFolder = "\\$LabIpAddress\c$\edu_ci"
$remoteBuildFolder = "$remoteBaseFolder\$BuildNumber"

function Set-PSDrive()
{
    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential $Username, $securePassword

    $labName = $LabIpAddress.Replace(".", "")

    Write-Host "Connecting PSDrive to $remoteBaseFolder"

    New-PSDrive -Name "EDU_CI_$labName" -PSProvider FileSystem -Root $remoteBaseFolder -Credential $credential 

    Confirm-OutputDirectory
}

function Confirm-OutputDirectory()
{
     New-Item -ItemType Directory -Force -Path "$PSScriptRoot\$LabIpAddress"

     Remove-Item "$PSScriptRoot\$LabIpAddress\*.log" -Force | Out-Null

     Copy-Logs
}

function Copy-Logs()
{
    try
    {
        Get-ChildItem $remoteBuildFolder -Filter "*.log" -File | Select -First 1 | Copy-Item -Destination "$PSScriptRoot\$LabIpAddress\$LabIpAddress.log"
    }
    catch
    {
        Write-Host "Unable to copy log file $remoteBuildFolder\*.log to $PSScriptRoot\$LabIpAddress\$LabIpAddress.log"
        throw
    }

    Comfirm-Logs
}

function Comfirm-Logs()
{
    if (Test-Path -Path "$PSScriptRoot\$LabIpAddress\$LabIpAddress.log" -PathType Leaf)
    {
        Write-Host "Verified logs were copied from $LabIpAddress, running log analysis"
    }
    else
    {
        Write-Host "Unable to find logs for $LabIpAddress"
        throw
    }
}

Set-PSDrive