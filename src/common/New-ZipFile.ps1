function New-ZipFile
{
    [CmdletBinding()]
    param (
        [string]
        $OutputFolder,

        [array]
        $Files,

        [string]
        $SessionGuid,

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
