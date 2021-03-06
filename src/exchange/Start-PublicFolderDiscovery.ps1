function Start-PublicFolderDiscovery
{

   <#

        .SYNOPSIS
            Calls a set of child scripts used to discover public folder settings.

        .DESCRIPTION
            Call public folder discovery scripts and return information related to the configuration and state of public folders in the environment.

        .OUTPUTS
            A custom object representing discovered public folders.

        .EXAMPLE
            Start-PublicFolderDiscovery

    #>

    [CmdletBinding()]
    param (
        # An array of servers to run discovery against
        [array]
        $Servers
    )

    begin
    {
        Write-Log -Level "INFO" -Activity "Public Folder Discovery" -Message "Attempting Public Folder Discovery." -WriteProgress
        $publicFolders = @{}
    }
    process
    {
        $publicFolders.Add("Mailboxes", [array]$(Get-ExchangePublicFolderMailboxes))
        $publicFolders.Add("Databases", [array]$(Get-ExchangePublicFolderDatabases -exchangeServers $Servers))
        $publicFolders.Add("Statistics", [array]$(Get-ExchangePublicFolderStatistics -PublicFolders $publicFolders))
        Write-Log -Level "INFO" -Activity "Public Folder Discovery" -Message "Completed Public Folder Discovery." -WriteProgress

        $publicFolders
    }
}
