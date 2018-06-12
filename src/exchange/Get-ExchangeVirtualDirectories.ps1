function Get-ExchangeVirtualDirectories
{
    [CmdletBinding()]
    param (
        [string]
        $DomainDN
    )

    $activity = "Exchange Virtual Directory"
    $discoveredVirtualDirectories = @()
    $ldapFilter = "(objectClass=msExchVirtualDirectory)"
    $context = "LDAP://CN=Configuration,$($DomainDN)"
    $searchRoot = "CN=Configuration,$($DomainDN)"
    [array]$properties = "name", "distinguishedName", "msExchExternalHostName", "msExchInternalHostName", "msExchMetabasePath", "msExchExternalAuthenticationMethods", "msExchInternalAuthenticationMethods", "objectClass"

    try
    {
        Write-Log -Level "VERBOSE" -Activity $activity -Message "Searching Active Directory for Virtual Directories." -WriteProgress
        $virtualDirectories = Search-Directory -context $context -Filter $ldapFilter -Properties $properties -SearchRoot $searchRoot
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Virtual Direatories. $($_.Exception.Message)"
        return
    }

    if ($virtualDirectories)
    {
        foreach ($virtualDirectory in $virtualDirectories)
        {
            $computerName = ($virtualDirectory.distinguishedname | Select-Object -First 1).Split(",")[3]
            $computerName = $computerName.Split("=")[1]
            $virtualDirectorySettings = "" | Select-Object ComputerName, Name, ExternalHostName, InternalHostName, ExternalAuthenticationMethods, InternalAuthenticationMethods, ObjectClasses, DistinguishedName
            $virtualDirectorySettings.ComputerName = $computerName
            $virtualDirectorySettings.Name = $virtualDirectory.name | Select-Object -First 1
            $virtualDirectorySettings.ExternalAuthenticationMethods = $virtualDirectory.msExchExternalAuthenticationMethods | Select-Object -First 1
            $virtualDirectorySettings.InternalAuthenticationMethods = $virtualDirectory.msExchInternalAuthenticationMethods | Select-Object -First 1
            $virtualDirectorySettings.ExternalHostName = $virtualDirectory.msExchExternalHostName | Select-Object -First 1
            $virtualDirectorySettings.InternalHostName = $virtualDirectory.msExchInternalHostName | Select-Object -First 1
            $virtualDirectorySettings.ObjectClasses = [array] $virtualDirectory.objectClass
            $virtualDirectorySettings.DistinguishedName = $virtualDirectory.distinguishedName | Select-Object -First 1

            $discoveredVirtualDirectories += $virtualDirectorySettings
        }
    }

    $discoveredVirtualDirectories
}
