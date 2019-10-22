function Get-OrganizationalUnits
{
    <#

        .SYNOPSIS 
            Discover all Active Directory Organizational Units in the on premises directory.

        .DESCRIPTION 
            Uses the ADSISearcher type accelerator to discover all Organizational Units.

        .OUTPUTS 
            Returns the DistinguishedName of all Organizational Units within Active Directory.

        .EXAMPLE
            Get-OrganizationalUnits

    #>

    [CmdletBinding()] 
    param (
        #An array of domains.
        [array]
        $Domains
    )

    $activity = "Active Directory Organizational Units"
    Write-Log -Level "INFO" -Activity $activity -Message "Enumerating Active Directory Organizational Units." -WriteProgress

    $allDistinguishedNames = @()

    if ($null -ne $domains)
    {
        foreach ($domain in $domains)
        {
            $domainDistinguishedName = "DC="+($domain.name.replace(".",",DC="))
            $adsiSearcher = [ADSISearcher]'ObjectClass=OrganizationalUnit'
            $adsiSearcher.PageSize = 1000
            $adsiSearcher.SearchRoot = "LDAP://"+$domainDistinguishedName
            $organizationalUnits = $adsiSearcher.FindAll()

            foreach ($organizationalUnit in $organizationalUnits)
            {
                $properties = $organizationalUnit.Properties
                $allDistinguishedNames += $properties.distinguishedname
            }
        }
    }

    if ($null -ne $allDistinguishedNames)
    {
    $allDistinguishedNames
    }
    else
    {
    Write-Log -Level "ERROR" -Activity $activity -Message "Failed to find Active Directory Organizational Units."
    }
}
