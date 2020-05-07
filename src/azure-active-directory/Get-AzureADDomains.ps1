function Get-AzureADDomains
{
    <#

        .SYNOPSIS
            Discover Azure AD Domains

        .DESCRIPTION
            Query Azure AD for configured domains

        .OUTPUTS
            Returns a custom object containing configured Azure AD domains

        .EXAMPLE
            Get-AzureADDomains

    #>

    [CmdletBinding()]
    param ()

    $activity = "AzureAD Domains"
    $discoveredDomains = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query AzureAD for configured domains." -WriteProgress
        $domains = Get-AzureAdDomain
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query AzureAD for configured domains. $($_.Exception.Message)"
        return
    }

    if ($domains)
    {
        foreach ($domain in $domains)
        {
            $domainObject = "" | Select-Object Name, AvailabilityStatus, AuthenticationType
            $domainObject.Name = [string]$domain.Name
            $domainObject.AvailabilityStatus = [string]$domain.AvailabilityStatus
            $domainObject.AuthenticationType = [string]$domain.AuthenticationType

            $discoveredDomains += $domainObject
            
        }
    }

    $discoveredDomains
}
