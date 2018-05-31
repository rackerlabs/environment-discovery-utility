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
    $pfMailboxes = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    if ($pfMailboxes)
    {
        $discoveredPublicFolderMailboxes = @()
        foreach ($pfMailbox in $pfMailboxes)
        {
            $publicFolderMailboxes = $null
            $publicFolderMailboxes = "" | Select-Object pfMBXGUID, parentDatabase
            $publicFolderMailboxes.pfMBXGUID = [GUID]  $( $pfMailbox.objectguid | Select-Object -First 1 )
            $publicFolderMailboxes.parentDatabase = $pfMailbox.homemdb

            $discoveredPublicFolderMailboxes += $publicFolderMailboxes
        }

        $discoveredPublicFolderMailboxes
    }
    
    else 
    {
        $discoveredPublicFolderMailboxes = @()
        $ldapFilter = "(objectClass=msExchPublicMDB)"
        $context = "LDAP://CN=Configuration,$($DomainDN)"
        $searchRoot = "CN=Configuration,$($DomainDN)"
        [array] $properties = "objectGUID","msExchOwningServer"
        $pfMailboxes = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
        
        if ($pfMailboxes)
        {
            foreach ($pfMailbox in $pfMailboxes)
            {
                $publicFolderMailboxes = $null
                $publicFolderMailboxes = "" | Select-Object pfMBXGUID, parentServer
                $publicFolderMailboxes.pfMBXGUID = [GUID]  $( $pfMailbox.objectguid | Select-Object -First 1 )
                $publicFolderMailboxes.parentServer = $pfMailbox.msexchowningserver

                $discoveredPublicFolderMailboxes += $publicFolderMailboxes
            }

            $discoveredPublicFolderMailboxes
        }
    }
}
