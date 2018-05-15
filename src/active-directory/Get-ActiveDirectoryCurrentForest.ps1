function Get-ActiveDirectoryCurrentForest
{
    [CmdletBinding()]
    param ()

    $currentForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()

    $currentForest
}