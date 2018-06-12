function Get-ExchangePublicFolderMailboxes
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Public Folder Infrastructure"
    $ldapFilter = "(msExchRecipientTypeDetails=68719476736)"
    $context = "LDAP://$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID","homeMDB"

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Public Folder mailboxes." -WriteProgress
        $modernPublicFolders = Search-Directory -Context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Public Folder mailboxes. $($_.Exception.Message)"
    }

    if ($modernPublicFolders)
    {
        $discoveredModernPublicFolders = @()

        foreach ($modernPublicFolder in $modernPublicFolders)
        {
            $discoveredModernPublicFolder = $null
            $discoveredModernPublicFolder = "" | Select-Object ObjectGUID, MailboxDatabase, ParentDatabase
            $discoveredModernPublicFolder.ObjectGUID = [GUID]$($modernPublicFolder.objectGUID | Select-Object -First 1)
            $discoveredModernPublicFolder.MailboxDatabase = $modernPublicFolder.homeMDB

            $discoveredModernPublicFolders += $discoveredModernPublicFolder
        }

        $discoveredModernPublicFolders
    }
}
