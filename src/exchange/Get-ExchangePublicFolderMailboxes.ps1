function Get-ExchangePublicFolderMailboxes
{
    <#

        .SYNOPSIS
            Query Exchange to pull modern public folder information.

        .DESCRIPTION
            Query Exchange to pull modern public folder information.

        .OUTPUTS
            Returns an array of modern public folders.

        .EXAMPLE
            Get-ExchangePublicFolderMailboxes

    #>

    [CmdletBinding()]
    param ()

    $activity = "Public Folder Mailboxes"
    $discoveredModernPublicFolders = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for Public Folder mailboxes." -WriteProgress
        $modernPublicFolders = Get-Mailbox -PublicFolder -ResultSize Unlimited -ErrorAction SilentlyContinue
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for Public Folder mailboxes. $($_.Exception.Message)"
        return
    }

    if ($modernPublicFolders)
    {

        foreach ($modernPublicFolder in $modernPublicFolders)
        {
            $discoveredModernPublicFolder = $null
            $discoveredModernPublicFolder = "" | Select-Object ObjectGuid, MailboxDatabase, RecipientTypeDetails, IsRootPublicFolderMailbox
            $discoveredModernPublicFolder.ObjectGuid = $modernPublicFolder.GUID
            $discoveredModernPublicFolder.MailboxDatabase = $modernPublicFolder.Database
            $discoveredModernPublicFolder.RecipientTypeDetails = $modernPublicFolder.RecipientTypeDetails
            $discoveredModernPublicFolder.IsRootPublicFolderMailbox = $modernPublicFolder.IsRootPublicFolderMailbox

            $discoveredModernPublicFolders += $discoveredModernPublicFolder
        }

        $discoveredModernPublicFolders
    }
}
