function Get-ExchangeFederationTrust
{
    <#

        .SYNOPSIS
            Discover Exchange federation trust settings.

        .DESCRIPTION
            Query Exchange to get all Exchange federation trusts.

        .OUTPUTS
            Returns a custom object representing key federation trust properties.

        .EXAMPLE
            Get-ExchangeFederationTrust

    #>

    [CmdletBinding()]
    param ()

    $activity = "Federation Trusts"
    $discoveredFederationTrusts = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for Federation Trusts." -WriteProgress
        [array]$exchangeFederationTrusts = Get-FederatedOrganizationIdentifier
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for Federation Trusts. $($_.Exception.Message)"
        return
    }

    if ($exchangeFederationTrusts)
    {
        foreach ($exchangeFederationTrust in $exchangeFederationTrusts)
        {
            $federationTrust = $null
            $federationTrust = "" | Select-Object ObjectGuid, Enabled, Domains, DelegationTrustLink, IsValid
            $federationTrust.ObjectGuid = $exchangeFederationTrust.GUID
            $federationTrust.Enabled = [bool]$exchangeFederationTrust.Enabled
            $federationTrust.Domains = [array]$exchangeFederationTrust.Domains
            $federationTrust.DelegationTrustLink = $exchangeFederationTrust.DelegationTrustLink
            $federationTrust.IsValid = [bool]$exchangeFederationTrust.IsValid

            $discoveredFederationTrusts += $federationTrust
        }
    }

    $discoveredFederationTrusts
}
