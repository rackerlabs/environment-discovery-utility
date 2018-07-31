function New-ZipFile
{
    <#
    
    .SYNOPSIS
        Function to zip all files provided.

    .DESCRIPTION
        Zips files provided to the desired output

    .PARAMETER OutputFolder
        Used to specify export directory location.

    .PARAMETER Files
        Used to specify files to be zipped.

    .PARAMETER EnvironmentName
        Unique Identifier to the envrionment to be used to name the zip file.
    
    .OUTPUTS
        Returns zip file location to user.

    .EXAMPLE
        New-ZipFile -OutputFolder $OutputFolder -Files "$jsonPath","$logPath" -EnvironmentName $environmentName
    
    #>
    

    [CmdletBinding()]
    param (
        [string]
        $OutputFolder,

        [array]
        $Files,

        [string]
        $EnvironmentName
    )

    $zipFilename = "edu-$EnvironmentName.zip"
    $zipFile = "$OutputFolder\$zipFilename"

    if (Test-Path $zipFile)
    {
        Remove-Item $zipFile -Force
    }

    if (!(test-path($zipFile)))
    {
        set-content $zipFile ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
        (Get-ChildItem $zipFile).IsReadOnly = $false  
    }

    $shellApplication = new-object -com shell.application
    $zipPackage = $shellApplication.NameSpace($zipFile)
    
    foreach ($file in $files)
    { 
        $fileAttributes = Get-ChildItem $file
        $zipPackage.CopyHere($fileAttributes.FullName)
        while ($zipPackage.Items().Item($fileAttributes.Name) -eq $null)
        {
            Start-sleep -seconds 1
        }
    }

    $zipFile
}
