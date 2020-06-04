function Start-ExchangeDiscovery
{
    <#

        .SYNOPSIS
            This cmdlet will return information related to the configuration and state of Exchange in the environment.

        .DESCRIPTION
            This cmdlet will return information related to the configuration and state of Exchange in the environment.  This is not meant to be run independently and is part of the Environment Discovery Utility package.

        .OUTPUTS
            A PSObject representation of the discovered Exchange environment.

        .EXAMPLE
            Start-ExchangeDiscovery

    #>

    [CmdletBinding()]
    param (
        # SkipDnsLookups Switch used to skip performing DNS lookups
        [Parameter(Mandatory=$false)]
        [switch]
        $SkipDnsLookups
    )

    begin
    {
        $activity = "Exchange Discovery"
        Write-Log -Level "INFO" -Activity  $activity -Message "Attempting to connect to Exchange PowerShell." -WriteProgress
        $exchangeEnvironment = @{}
        [bool]$exchangeShellConnected = Initialize-ExchangePowershell
    }
    process
    {
        if ($exchangeShellConnected -eq $true)
        {
            [array]$exchangeServers = Get-ExchangeServers
            [array]$acceptedDomains = Get-ExchangeAcceptedDomains
            $virtualDirectories = Get-ExchangeVirtualDirectories -Servers $exchangeServers

            $exchangeEnvironment.Add("Servers", $exchangeServers)
            $exchangeEnvironment.Add("AcceptedDomains", $acceptedDomains)
            $exchangeEnvironment.Add("VirtualDirectories", $virtualDirectories)
            $exchangeEnvironment.Add("Recipients", [array]$(Get-ExchangeRecipients))
            $exchangeEnvironment.Add("PublicFolders", $(Start-PublicFolderDiscovery -Servers $exchangeServers))
            $exchangeEnvironment.Add("DynamicGroups", [array]$(Get-ExchangeDynamicGroups))
            $exchangeEnvironment.Add("FederationTrusts", [array]$(Get-ExchangeFederationTrust))
            $exchangeEnvironment.Add("OrganizationalRelationships", [array]$(Get-ExchangeOrganizationalRelationship))
            $exchangeEnvironment.Add("DatabaseJournaling", [array]$(Get-ExchangeDatabaseJournaling -AcceptedDomains $acceptedDomains))
            $exchangeEnvironment.Add("ImapPopSettings", [array]$(Get-ExchangeImapPopSettings -Servers $exchangeServers))
            $exchangeEnvironment.Add("TransportRules", [array]$(Get-ExchangeTransportRules))
            $exchangeEnvironment.Add("TransportSettings", $(Get-ExchangeTransportConfig))
            $exchangeEnvironment.Add("EmailAddressPolicies", [array]$(Get-ExchangeEmailAddressPolicies))
            $exchangeEnvironment.Add("OrganizationConfig", $(Get-ExchangeOrganizationConfig))
            $exchangeEnvironment.Add("ClientAccessServerSettings", [array]$(Get-ExchangeClientAccessConfig))
            $exchangeEnvironment.Add("RetentionPolicies", [array]$(Get-ExchangeRetentionPolicies))
            $exchangeEnvironment.Add("MobileDevicePolicies", [array]$(Get-ExchangeMobileDevicePolicies -Recipients $exchangeEnvironment["Recipients"]))
            $exchangeEnvironment.Add("HybridConfiguration", [array]$(Get-ExchangeHybridConfig))
            $exchangeEnvironment.Add("PartnerApplications", [array]$(Get-ExchangePartnerApplications -Servers $exchangeServers))
            $exchangeEnvironment.Add("SslCertificates", [array]$(Get-ExchangeSslCerts -Servers $exchangeServers))
            $exchangeEnvironment.Add("Dags", [array]$(Get-ExchangeDags -Servers $exchangeServers))
            $exchangeEnvironment.Add("AdminAuditLogConfig", [array]$(Get-ExchangeAdminAuditLogConfig))
            $exchangeEnvironment.Add("Databases", [array]$(Get-ExchangeDatabases))

            if ($SkipDnsLookups -eq $false)
            {
                $exchangeEnvironment.Add("DnsRecords", [array]$(Get-ExchangeDnsRecords -VirtualDirectories $virtualDirectories -AcceptedDomains $acceptedDomains))
            }
            else
            {
                Write-Log -Level "INFO" -Activity  $activity -Message "Skipping Exchange DNS Lookups due to the SkipDnsLookups parameter being provided." -WriteProgress
            }

            Write-Log -Level "INFO" -Activity  $activity -Message "Completed Exchange Discovery." -WriteProgress
        }
        else
        {
            Write-Log -Level "WARNING" -Activity $activity -Message "Unable to execute Exchange Discovery because no Exchange PowerShell session could be established." -WriteProgress
        }

        $exchangeEnvironment
    }
}
