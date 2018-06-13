function Start-PublicFolderDiscovery
{
    <#
    .SYNOPSIS
        This cmdlet will return information related to the configuration and state of Public Folder in the environment.

    .DESCRIPTION
        This cmdlet will return information related to the configuration and state of Public Folder in the environment.

    .OUTPUTS
        A PSObject representation of the discovered Public Folders.

    .EXAMPLE
        Start-PublicFolderDiscovery
    #>

    [CmdletBinding()]
    param (
        [string]
        $DomainDN,

        [bool]
        $ExchangeShellConnected
    )
    begin
    {
        Write-Log -Level "VERBOSE" -Activity "Public Folder Discovery" -Message "Attempting Public Folder Discovery." -WriteProgress
        $publicFolders = @{}
    }
    process
    {
        $publicFolders.Add("Mailboxes", $(Get-ExchangePublicFolderMailboxes -DomainDN $DomainDN))
        $publicFolders.Add("Databases", $(Get-ExchangePublicFolderDatabases -DomainDN $DomainDN))
        $publicFolders.Add("Statistics", $(Get-ExchangePublicFolderStatistics -ExchangeShellConnected $exchangeShellConnected))
        Write-Log -Level "VERBOSE" -Activity "Public Folder Discovery" -Message "Completed Public Folder Discovery." -WriteProgress

        $publicFolders
    }
}
