function Get-ActiveDirectoryCurrentForest
{
    <#

    .SYNOPSIS
        Extract Active Directory attributes for the current forest.
    
    .DESCRIPTION
        Uses .NET framework calls to get current forest information.
    
    .OUTPUTS
        Returns Active Directory forest information.
    
    .EXAMPLE
        Get-ActiveDirectoryCurrentForest

    #>
    
    [CmdletBinding()]
    param ()

    try
    {
        $currentForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $MyInvocation.MyCommand.Name -Message "Failed to get Active Directory forest information. $($_.Exception.Message)"
    }

    $currentForest
}
