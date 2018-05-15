function Get-ActiveDirectoryCurrentForest
{
    [CmdletBinding()]
    Param ()
    
    $currentForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
    
    $currentForest
}