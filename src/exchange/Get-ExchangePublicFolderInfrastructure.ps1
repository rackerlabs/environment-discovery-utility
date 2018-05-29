function Get-ExchangePublicFolderInfrastructure
{
    [CmdletBinding()]
    param ()

    #Run AD Query for all PF MBX and their homeMDB
    $discoveredPublicFolderMailboxes = @()
    $ldapFilter = "(msExchRecipientTypeDetails=68719476736)"
    $context = "LDAP://$($DomainDN)"
    $searchRoot = "$($DomainDN)"
    [array] $properties = "name","homeMDB"
    $pfMailboxes = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($pfMailbox in $pfMailboxes)
    {
        $PublicFolderMailboxes = $null
        $PublicFolderMailboxes = "" | Select-Object ObjectGuid, Name, homeMDB
        $PublicFolderMailboxes.ObjectGuid = [GUID]  $( $pfMailbox.objectGuid | Select-Object -First 1 )
        $PublicFolderMailboxes.PFMBXName = $( $pfMailbox.name | Select-Object -First 1 )
        $PublicFolderMailboxes.ParentDatabase = $( $pfMailbox.homeMDB | Select-Object -First 1 )

        $discoveredPublicFolderMailboxes += $PublicFolderMailboxes
    }

    $discoveredPublicFolderMailboxes
}