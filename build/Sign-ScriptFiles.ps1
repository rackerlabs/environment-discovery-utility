<#

    .SYNOPSIS
        Signs all EDU script files.

    .DESCRIPTION
        Extract certificate information from PasswordSafe and sign all .PSD1, .PSM1 and .PS1 files.
        
    .PARAMETER BuildToolsDir
        Build tools repository checkout location, used to retrieve password safe credentials.
        
    .PARAMETER CertificateFile
        Full path to certificate location in the filesystem.

    .PARAMETER Password
        Service account password used to access PasswordSafe credentials.

    .PARAMETER ProjectId
        PasswordSafe project id.
        
    .PARAMETER Username
        Service account username used to access PasswordSafe credentials.
        
    .EXAMPLE
        Sign-ScriptFiles -Username some_user -Password asdf123! -Certificate .\cert.pfx

#>

[CmdletBinding()]
param (
    [string]
    $BuildToolsDir = "$PSScriptRoot\tools",
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]    
	[string]
    $CertificateFile,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Password,

    [int]
    $ProjectId = 22502,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Username
)

$ErrorActionPreference = "Stop"

Function Get-Credentials()
{
    param( 
        [int]$CredentialId = $CredentialId,
        [int]$ProjectId = $ProjectId
    )

    $creds = & $BuildToolsDir\passwordsafe\Deserialize-Credentials.ps1 `
        -Application $BuildToolsDir\passwordsafe\PasswordSafeClient.Console.dll `
        -Username $Username `
        -Password $Password `
        -CredentialId $CredentialId `
        -ProjectId $ProjectId

    $creds
}

Function Get-CertificatePassword()
{
    Write-Host "Getting certificate password from PasswordSafe"

    $creds = Get-Credentials -CredentialId 196192

    if ($LastExitCode -ne 0)
    {
	    throw "Failed to retrieve certificate password from PasswordSafe"
    }

    $Script:certificatePassword = $creds.credential.Password

    Get-Certificate
}

Function Get-Certificate()
{
    Write-Host "Reading certificate file $CertificateFile"

    $Script:certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $Script:certificate.Import($CertificateFile, $Script:certificatePassword, "DefaultKeySet")

    Get-Scripts
}

Function Get-Scripts()
{
    Write-Host "Getting all script files using pattern $PSScriptRoot\..\src\*.*"

    Get-ChildItem "$PSScriptRoot\..\src\*.*" -Recurse | `
        Where { $_.FullName -notlike "*\src\logging\PowerShellLogging\*" -and ($_.Extension -like ".ps1" -or $_.Extension -like ".psm1" -or $_.Extension -like ".psd1") }  | `
        Sign-Files
}

Function Sign-Files
{	
    foreach ($file in @($input))
    {
        Write-Host "Signing $($file.VersionInfo.FileName)"
        
        Set-AuthenticodeSignature -FilePath $file.VersionInfo.FileName -Certificate $Script:certificate
    }
}

Get-CertificatePassword