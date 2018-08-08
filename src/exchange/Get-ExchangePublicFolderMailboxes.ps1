function Get-ExchangePublicFolderMailboxes
{
    <#

        .SYNOPSIS
            Load attributes for a single "modern" public folder mailbox information in Exchange.

        .DESCRIPTION
            Use LDAP queries to pull modern public folder information.

        .OUTPUTS
            Returns a custom object containing modern public folder mailbox objectGUID and the database it is mounted on.

        .EXAMPLE
            Get-ExchangePublicFolderMailboxes -DomainDN $domainDN

    #>

    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Public Folder Mailboxes"
    $ldapFilter = "(msExchRecipientTypeDetails=68719476736)"
    $context = "LDAP://$DomainDN"
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
        return
    }

    if ($modernPublicFolders)
    {
        $discoveredModernPublicFolders = @()

        foreach ($modernPublicFolder in $modernPublicFolders)
        {
            $discoveredModernPublicFolder = $null
            $discoveredModernPublicFolder = "" | Select-Object ObjectGuid, MailboxDatabase, ParentDatabase
            $discoveredModernPublicFolder.ObjectGuid = [GUID]$($modernPublicFolder.objectGUID | Select-Object -First 1)
            $discoveredModernPublicFolder.MailboxDatabase = $modernPublicFolder.homeMDB

            $discoveredModernPublicFolders += $discoveredModernPublicFolder
        }

        $discoveredModernPublicFolders
    }
}
