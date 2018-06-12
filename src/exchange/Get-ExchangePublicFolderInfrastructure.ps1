function Get-ExchangePublicFolderInfrastructure
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
            $discoveredModernPublicFolder = "" | Select-Object PublicFolderGUID, ParentServer, ParentDatabase
            $discoveredModernPublicFolder.PublicFolderGUID = [GUID]$($modernPublicFolder.objectGUID | Select-Object -First 1)
            $discoveredModernPublicFolder.ParentServer = $null
            $discoveredModernPublicFolder.ParentDatabase = $modernPublicFolder.homeMDB

            $discoveredModernPublicFolders += $discoveredModernPublicFolder
        }

        $discoveredModernPublicFolders
    }
    else
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Did not find Public Folder mailboxes in Active Directory. Checking for legacy Public Folders." -WriteProgress
        $discoveredLegacyPublicFolders = @()

        $ldapFilter = "(objectClass=msExchPublicMDB)"
        $context = "LDAP://CN=Configuration,$($DomainDN)"
        $searchRoot = "CN=Configuration,$($DomainDN)"
        [array]$properties = "objectGUID","msExchOwningServer"

        try
        {
            Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Public Folder databases." -WriteProgress
            $legacyPublicFolders = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
        }
        catch
        {
            Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Public Folder databases. $($_.Exception.Message)"
            return
        }

        if ($legacyPublicFolders)
        {
            foreach ($legacyPublicFolder in $legacyPublicFolders)
            {
                $discoveredLegacyPublicFolder = $null
                $discoveredLegacyPublicFolder = "" | Select-Object PublicFolderGUID, ParentServer, ParentDatabase
                $discoveredLegacyPublicFolder.PublicFolderGUID = [GUID]$($legacyPublicFolder.objectGUID | Select-Object -First 1)
                $discoveredLegacyPublicFolder.ParentServer = $legacyPublicFolder.msExchOwningServer
                $discoveredLegacyPublicFolder.ParentDatabase = $null

                $discoveredLegacyPublicFolders += $discoveredLegacyPublicFolder
            }
        }
        else
        {
            Write-Log -Level "VERBOSE" -Activity $activity -Message "Did not find Public Folder databases in Active Directory." -WriteProgress
        }

        $discoveredLegacyPublicFolders
    }
}