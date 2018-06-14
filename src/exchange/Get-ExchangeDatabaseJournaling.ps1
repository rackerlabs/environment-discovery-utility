function Get-ExchangeDatabaseJournaling
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Database Journaling"
    $discoveredDatabaseJournaling = @()
    $searchRoot = "CN=Configuration,$($DomainDN)"
    $ldapFilter = "(objectClass=msExchPrivateMDB)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    [array] $properties = "objectGUID", "msExchMessageJournalRecipient"

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Database Journaling." -WriteProgress
        $databases = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Database Journaling. $($_.Exception.Message)"
        return
    }
    
    if ($databases)
    {
        foreach ($database in $databases)
        {
            $distinguishedName = $database.msExchMessageJournalRecipient
            
            if ($distinguishedName)
            {
                $ldapFilter = "(distinguishedName=$($distinguishedName))"
                $context = $null
                $searchRoot = $domainDN
                [array]$properties = "objectGUID", "objectClass"
                $journalingTarget = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
                
                $databaseJournaling = $null
                $databaseJournaling = "" | Select-Object ObjectGuid, TargetGuid, TargetObjectClass
                $databaseJournaling.ObjectGuid = [GUID]$($database.objectGUID | Select-Object -First 1)
                $databaseJournaling.TargetGuid = [GUID]$($journalingTarget.objectGUID | Select-Object -First 1)
                $databaseJournaling.TargetObjectClass = [array]$journalingTarget.objectClass
                
                $discoveredDatabaseJournaling += $DatabaseJournaling
            }
        }
    }
    
    $discoveredDatabaseJournaling
}
