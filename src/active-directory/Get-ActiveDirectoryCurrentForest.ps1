function Get-ActiveDirectoryCurrentForest
{
    [CmdletBinding()]
    param ()

    try
    {
        $currentForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
    }
    catch
    {
        Write-Error "Failed to get Active Directory Forest information. $($_.Exception.Message)"
    }

    $currentForest
}