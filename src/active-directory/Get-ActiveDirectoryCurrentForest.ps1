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
        Write-Log -Level 'ERROR' -Activity $MyInvocation.MyCommand.Name -Message "Failed to get Active Directory Forest information. $($_.Exception.Message)"
    }

    $currentForest
}