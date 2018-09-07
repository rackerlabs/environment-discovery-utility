function Get-ExchangeOrganizationConfig
{
    <#

        .SYNOPSIS
            Discover Exchange Organization Config settings.

        .DESCRIPTION
            Query Exchange to get all Organization Config Settings.

        .OUTPUTS
            Returns a custom object representing key Organization Config properties.

        .EXAMPLE
            Get-ExchangeOrganizationConfig

    #>

    [CmdletBinding()]
    param ()

    $activity = "Organization Config"
    $discoveredOrganizationConfig = @()

    try
    {
        Write-Log -Level "INFO" -Activity $activity -Message "Query Exchange for Organization Config." -WriteProgress
        $exchangeOrganizationConfig = Get-OrganizationConfig
    }
    catch
    {
        Write-Log -Level "ERROR" -Activity $activity -Message "Failed to query Exchange for Organization Config. $($_.Exception.Message)"
        return
    }

    if ($exchangeOrganizationConfig)
    {
        $organizationConfig = $null
        $organizationConfig = "" | Select-Object ObjectGuid, MaxConcurrentMigrations, MapiHttpEnabled, OAuth2ClientProfileEnabled, WACDiscoveryEndpoint, AdfsIssuer, AdfsAudienceUris
        $organizationConfig.ObjectGuid = $exchangeOrganizationConfig.GUID
        $organizationConfig.MaxConcurrentMigrations = $exchangeOrganizationConfig.MaxConcurrentMigrations
        $organizationConfig.MapiHttpEnabled = $exchangeOrganizationConfig.MapiHttpEnabled
        $organizationConfig.OAuth2ClientProfileEnabled = $exchangeOrganizationConfig.OAuth2ClientProfileEnabled
        $organizationConfig.WACDiscoveryEndpoint = $exchangeOrganizationConfig.WACDiscoveryEndpoint
        $organizationConfig.AdfsIssuer = $exchangeOrganizationConfig.AdfsIssuer
        $organizationConfig.AdfsAudienceUris = $exchangeOrganizationConfig.AdfsAudienceUris

        $discoveredOrganizationConfig += $organizationConfig
    }

    $discoveredOrganizationConfig
}
