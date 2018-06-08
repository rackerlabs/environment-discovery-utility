function Get-ExchangePublicFolderInfrastructure
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $ldapFilter = "(msExchRecipientTypeDetails=68719476736)"
    $context = "LDAP://$($DomainDN)"
    $searchRoot = "$DomainDN"
    [array]$properties = "objectGUID","homeMDB"
    try
    {
        $modernPublicFolders = Search-Directory -Context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level 'ERROR' -Activity $MyInvocation.MyCommand.Name -Message "Failed to search Active Directory for Modern Public Folders. $($_.Exception.Message)"
    }

    if ($modernPublicFolders)
    {
        $discoveredModernPublicFolders = @()

        foreach ($modernPublicFolder in $modernPublicFolders)
        {
            $discoveredModernPublicFolder = $null
            $discoveredModernPublicFolder = "" | Select-Object PublicFolderGUID, ParentServer, ParentDatabase
            $discoveredModernPublicFolder.PublicFolderGUID = [GUID]$($modernPublicFolder.objectguid | Select-Object -First 1)
            $discoveredModernPublicFolder.ParentServer = $null
            $discoveredModernPublicFolder.ParentDatabase = $modernPublicFolder.homemdb

            $discoveredModernPublicFolders += $discoveredModernPublicFolder
        }
    }
    else
    {
        $discoveredLegacyPublicFolders = @()

        $ldapFilter = "(objectClass=msExchPublicMDB)"
        $context = "LDAP://CN=Configuration,$($DomainDN)"
        $searchRoot = "CN=Configuration,$($DomainDN)"
        [array]$properties = "objectGUID","msExchOwningServer"

        try
        {
            $legacyPublicFolders = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
        }
        catch
        {
            Write-Log -Level 'ERROR' -Activity $MyInvocation.MyCommand.Name -Message "Failed to search Active Directory for Legacy Public Folders. $($_.Exception.Message)"
        }

        if ($legacyPublicFolders)
        {
            foreach ($legacyPublicFolder in $legacyPublicFolders)
            {
                $discoveredLegacyPublicFolder = $null
                $discoveredLegacyPublicFolder = "" | Select-Object PublicFolderGUID, ParentServer, ParentDatabase
                $discoveredLegacyPublicFolder.PublicFolderGUID = [GUID]$($legacyPublicFolder.objectguid | Select-Object -First 1)
                $discoveredLegacyPublicFolder.ParentServer = $legacyPublicFolder.msexchowningserver
                $discoveredLegacyPublicFolder.ParentDatabase = $null

                $discoveredLegacyPublicFolders += $discoveredLegacyPublicFolder
            }
        }

        $discoveredLegacyPublicFolders
    }
}
