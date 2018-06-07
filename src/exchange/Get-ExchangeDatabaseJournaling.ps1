function Get-ExchangeDatabaseJournaling
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $discoveredDatabaseJournaling = @()
    $searchRoot = "CN=Configuration,$($DomainDN)"
    $ldapFilter = "(objectClass=msExchPrivateMDB)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    [array] $properties = "objectGUID", "msExchMessageJournalRecipient"
    $databases = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot

    foreach ($database in $databases)
    {
        $distinguishedName = $database.msExchMessageJournalRecipient
        $ldapFilter = "(distinguishedName=$($distinguishedName))"
        $context = $null
        $searchRoot = $domainDN
        [array]$properties = "objectGUID", "objectClass"
        $journalingTarget = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
        
        $databaseJournaling = $null
        $databaseJournaling = "" | Select-Object DatabaseGUID, JournalTargetGUID, JournalTargetObjectClass
        $databaseJournaling.DatabaseGUID = [GUID] $( $database.objectGUID | Select-Object -First 1 )
        $databaseJournaling.JournalTargetGUID = [GUID] $( $journalingTarget.objectGUID | Select-Object -First 1 )
        $databaseJournaling.JournalTargetObjectClass = [array]$journalingTarget.objectClass
        
        $discoveredDatabaseJournaling += $DatabaseJournaling
    }

    $discoveredDatabaseJournaling
}