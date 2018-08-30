function Get-ExchangeAcceptedDomains
{
    <#

        .SYNOPSIS
            Discover Exchange accepted domains.

        .DESCRIPTION
            Uses Exchange PowerShell to enumerate accepted domains.

        .PARAMETER DomainDN
            The current forest distinguished name to use in the LDAP query.

        .OUTPUTS
            Returns a custom object containing Exchange accepted domains.

        .EXAMPLE
            Get-ExchangeAcceptedDomains

    #>

    [CmdletBinding()]
    param ()

    $activity = "Accepted Domains"
    $discoveredAcceptedDomains = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Discovering Accepted Domains." -WriteProgress
        $acceptedDomains = Get-AcceptedDomain
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to search Active Directory for Accepted Domains. $($_.Exception.Message)"
        return
    }

    if ($acceptedDomains)
    {
        foreach ($acceptedDomain in $acceptedDomains)
        {
            $currentAcceptedDomain = "" | Select-Object Name, AcceptedDomain, DomainType, IsDefault
            $currentAcceptedDomain.Name = $acceptedDomain.Name
            $currentAcceptedDomain.AcceptedDomain = $acceptedDomain.DomainName
            $currentAcceptedDomain.DomainType = $acceptedDomain.DomainType
            $currentAcceptedDomain.IsDefault = $acceptedDomain.Default

            $discoveredAcceptedDomains += $currentAcceptedDomain
        }
    }
    else
    {
        Write-Log -Level "WARNING" -Activity $activity -Message "No Accepted Domains detected.  This condition should not occur."
    }

    Write-Log -Level "INFO" -Activity $activity -Message "Accepted Domain Count: $($discoveredAcceptedDomains.Count)"

    $discoveredAcceptedDomains
}
