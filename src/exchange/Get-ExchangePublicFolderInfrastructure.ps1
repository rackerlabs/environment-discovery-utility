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
    $publicFolderObjects = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    if ($publicFolderObjects)
    {
        $discoveredPublicFolderInfrastructure = @()
        foreach ($publicFolderObject in $publicFolderObjects)
        {
            $discoveredPublicFolderObject = $null
            $discoveredPublicFolderObject = "" | Select-Object publicFolderMailboxGUID, parentServer, parentDatabase
            $discoveredPublicFolderObject.publicFolderMailboxGUID = [GUID]$($publicFolderObject.objectguid | Select-Object -First 1)
            $discoveredPublicFolderObject.parentServer = $null
            $discoveredPublicFolderObject.parentDatabase = $publicFolderObject.homemdb

            $discoveredPublicFolderInfrastructure += $discoveredPublicFolderObject
        }

        $discoveredPublicFolderInfrastructure
    }
    
    else 
    {
        $discoveredPublicFolderInfrastructure = @()
        $ldapFilter = "(objectClass=msExchPublicMDB)"
        $context = "LDAP://CN=Configuration,$($DomainDN)"
        $searchRoot = "CN=Configuration,$($DomainDN)"
        [array] $properties = "objectGUID","msExchOwningServer"
        $publicFolderObjects = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
        
        if ($publicFolderObjects)
        {
            foreach ($publicFolderObject in $publicFolderObjects)
            {
                $discoveredPublicFolderObject = $null
                $discoveredPublicFolderObject = "" | Select-Object publicFolderMailboxGUID, parentServer, parentDatabase
                $discoveredPublicFolderObject.publicFolderMailboxGUID = [GUID]$($publicFolderObject.objectguid | Select-Object -First 1)
                $discoveredPublicFolderObject.parentServer = $publicFolderObject.msexchowningserver
                $discoveredPublicFolderObject.parentDatabase = $null
                
                $discoveredPublicFolderInfrastructure += $discoveredPublicFolderObject
            }

            $discoveredPublicFolderInfrastructure
        }
    }
}
