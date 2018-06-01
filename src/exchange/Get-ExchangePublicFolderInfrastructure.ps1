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
    [array] $properties = "objectGUID","homeMDB"
    $modernPublicFolders = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    if ($modernPublicFolders)
    {
        $discoveredModernPublicFolders = @()
        foreach ($modernPublicFolder in $modernPublicFolders)
        {
            $discoveredModernPublicFolder = $null
            $discoveredModernPublicFolder = "" | Select-Object publicFolderGUID, parentServer, parentDatabase
            $discoveredModernPublicFolder.publicFolderGUID = [GUID]$($modernPublicFolder.objectguid | Select-Object -First 1)
            $discoveredModernPublicFolder.parentServer = $null
            $discoveredModernPublicFolder.parentDatabase = $modernPublicFolder.homemdb

            $discoveredModernPublicFolders += $discoveredModernPublicFolder
        }

        $discoveredModernPublicFolders
    }
    
    else 
    {
        $discoveredLegacyPublicFolders = @()
        $ldapFilter = "(objectClass=msExchPublicMDB)"
        $context = "LDAP://CN=Configuration,$($DomainDN)"
        $searchRoot = "CN=Configuration,$($DomainDN)"
        [array] $properties = "objectGUID","msExchOwningServer"
        $legacyPublicFolders = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
        
        if ($legacyPublicFolders)
        {
            foreach ($legacyPublicFolder in $legacyPublicFolders)
            {
                $discoveredPublicFolder = $null
                $discoveredPublicFolder = "" | Select-Object publicFolderGUID, parentServer, parentDatabase
                $discoveredPublicFolder.publicFolderGUID = [GUID]$($legacyPublicFolder.objectguid | Select-Object -First 1)
                $discoveredPublicFolder.parentServer = $legacyPublicFolder.msexchowningserver
                $discoveredPublicFolder.parentDatabase = $null
                
                $discoveredLegacyPublicFolders += $discoveredPublicFolder
            }

            $discoveredLegacyPublicFolders
        }
    }
}
