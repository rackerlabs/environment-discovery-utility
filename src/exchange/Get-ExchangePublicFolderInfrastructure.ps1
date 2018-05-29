function Get-ExchangePublicFolderInfrastructure
{
    [CmdletBinding()]
    param ()

    #Run AD Query for all PF MBX and their homeMDB
    $PublicFolderMailboxes = @()
    $ldapFilter = "(msExchRecipientTypeDetails=68719476736)"
    $context = "LDAP://$($DomainDN)"
    $searchRoot = "$($DomainDN)"
    [array] $properties = "name","homeMDB"
    $pfMailboxes = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($pfMailbox in $pfMailboxes)
    {
        $PublicFolderMailboxes = $null
        $pfMailbox = "" | Select-Object ObjectGuid, Name, homeMDB
        $pfMailbox.ObjectGuid = [GUID]  $( $recipient.objectGuid | Select-Object -First 1 )
        $pfMailbox.PFMBXName = $( $recipient.name | Select-Object -First 1 )
        $pfMailbox.ParentDatabase = $( $recipient.homeMDB | Select-Object -First 1 )

        $discoveredPublicFolderMailboxes += $PublicFolderMailboxes
    }

    $discoveredPublicFolderMailboxes
}