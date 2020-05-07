function Start-ExchangeOnlineDiscovery
{
    <#

        .SYNOPSIS
            This cmdlet will return information related to the configuration of  Exchange Online.

        .DESCRIPTION
            This cmdlet will return information related to the configuration of Exchange Online.  This is not meant to be run independently and is part of the Environment Discovery Utility package.

        .OUTPUTS
            A PSObject representation of the discovered Exchange Online environment.

        .EXAMPLE
            Start-ExchangeOnlineDiscovery

    #>

    [CmdletBinding()]
    param ()
    begin
    {
        $activity = "Exchange Online Discovery"
        $exoEnvironment = @{}
        $exoShellConnected = Get-ExchangeOnlineSession
    }
    process
    {
        if ($null -notlike $exoShellConnected)
        {
            [array]$acceptedDomains = Get-ExoAcceptedDomains
            [array]$recipients = Get-ExoRecipients
            [array]$organizationRelationships = Get-ExoOrganizationRelationships
            [array]$federationTrusts = Get-ExoFederationTrusts
            [array]$transportRules = Get-ExoTransportRules
            $transportConfig = Get-ExoTransportConfig
            $organizationConfig = Get-ExoOrganizationConfig
            [array]$emailAddressPolicies = Get-ExoEmailAddressPolicies

            $exoEnvironment.Add("AcceptedDomains", $acceptedDomains)
            $exoEnvironment.Add("Recipients", $recipients)
            $exoEnvironment.Add("OrganizationRelationships", [array]$organizationRelationships)
            $exoEnvironment.Add("FederationTrusts", [array]$federationTrusts)
            $exoEnvironment.Add("TransportRules", [array]$transportRules)
            $exoEnvironment.Add("TransportConfig", $transportConfig)
            $exoEnvironment.Add("EmailAddressPolicies", [array]$emailAddressPolicies)
            $exoEnvironment.Add("OrganizationConfig", [array]$organizationConfig)

            Write-Log -Level "INFO" -Activity  $activity -Message "Completed Exchange Online Discovery." -WriteProgress
        }
        else
        {
            Write-Log -Level "WARNING" -Activity $activity -Message "Unable to execute Exchange Online Discovery because no PowerShell session could be established." -WriteProgress
        }

        $exoEnvironment
    }
}
