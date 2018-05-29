function Get-ExchangePublicFolderInfrastructure
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $discoveredPublicFolderMailboxes = @()
    $ldapFilter = "(&(msExchRecipientTypeDetails=68719476736)(objectClass=msExchPublicMDB))"
    $context = "LDAP://$($DomainDN)"
    $searchRoot = "$($DomainDN)"
    [array] $properties = "name","homeMDB"
    $pfMailboxes = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($pfMailbox in $pfMailboxes)
    {
        $publicFolderMailboxes = $null
        $publicFolderMailboxes = "" | Select-Object objectGuid, pfMBXName, parentDatabase
        $publicFolderMailboxes.objectGuid = [GUID]$pfMailbox.objectGuid
        $publicFolderMailboxes.pfMBXName = $pfMailbox.name
        $publicFolderMailboxes.parentDatabase = $pfMailbox.homeMDB
        $discoveredPublicFolderMailboxes += $publicFolderMailboxes
        $discoveredPublicFolderMailboxes
    }
}