function Get-ExchangePublicFolderDatabases
{
    <#

        .SYNOPSIS
            Discover Active Directory attributes for legacy public folder databases in Exchange.
    
        .DESCRIPTION
            Uses LDAP queries to find public folder database settings in Active Directory.
    
        .PARAMETER DomainDN
            The current forest distinguished name to use in the LDAP query.

        .OUTPUTS
            Returns a custom object containing public folder database properties.
    
        .EXAMPLE
            Get-ExchangePublicFolderDatabases -DomainDN $domainDN
    
    #>

    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Public Folder Databases"
    $discoveredLegacyPublicFolders = @()
    $ldapFilter = "(objectClass=msExchPublicMDB)"
    $context = "LDAP://CN=Configuration,$DomainDN"
    $searchRoot = "CN=Configuration,$DomainDN"
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
            $discoveredLegacyPublicFolder = "" | Select-Object ObjectGuid, ParentServer, ParentDatabase
            $discoveredLegacyPublicFolder.ObjectGuid = [GUID]$($legacyPublicFolder.objectGUID | Select-Object -First 1)
            $discoveredLegacyPublicFolder.ParentServer = $legacyPublicFolder.msExchOwningServer

            $discoveredLegacyPublicFolders += $discoveredLegacyPublicFolder
        }
    }
    else
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Did not find Public Folder databases in Active Directory." -WriteProgress
    }

    $discoveredLegacyPublicFolders
}
