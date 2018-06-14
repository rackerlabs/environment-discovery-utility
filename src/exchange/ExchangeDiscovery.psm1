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
    param ()
    begin
    {
        Write-Log -Level "VERBOSE" -Activity "Exchange Discovery" -Message "Attempting to connect to Exchange PowerShell." -WriteProgress
        $exchangeEnvironment = @{}
        [bool]$exchangeShellConnected = Initialize-ExchangePowershell
        clear
    }
    process
    {
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
        $forestName = $domain.Forest.Name
        $forestDN = "DC=$( $ForestName.Replace(".",",DC=") )"
        $exchangeEnvironment.Add("Servers", $(Get-ExchangeServers -DomainDN $forestDN))
        $exchangeEnvironment.Add("AcceptedDomains", $(Get-ExchangeAcceptedDomains -DomainDN $forestDN))
        $exchangeEnvironment.Add("VirtualDirectories", $(Get-ExchangeVirtualDirectories -DomainDN $forestDN))
        $exchangeEnvironment.Add("Recipients", $(Get-ExchangeRecipients -DomainDN $forestDN -ExchangeShellConnected $exchangeShellConnected))
        $exchangeEnvironment.Add("PublicFolders", $(Start-PublicFolderDiscovery -DomainDN $forestDN -ExchangeShellConnected $exchangeShellConnected))
        $exchangeEnvironment.Add("DynamicGroups", $(Get-ExchangeDynamicGroups -DomainDN $forestDN))
        $exchangeEnvironment.Add("FederationTrust", $(Get-ExchangeFederationTrust -DomainDN $forestDN))
        $exchangeEnvironment.Add("OrganizationalRelationships", [array]$(Get-ExchangeOrganizationalRelationship -DomainDN $forestDN))
        $exchangeEnvironment.Add("DatabaseJournaling", $(Get-ExchangeDatabaseJournaling -DomainDN $forestDN))
        $exchangeEnvironment.Add("ImapPopSettings", $(Get-ExchangeImapPopSettings -DomainDN $forestDN))
        $exchangeEnvironment.Add("TransportRules", $(Get-ExchangeTransportRules -DomainDN $forestDN -ExchangeShellConnected $exchangeShellConnected))
        Write-Log -Level "VERBOSE" -Activity "Exchange Discovery" -Message "Completed Exchange Discovery." -WriteProgress

        $exchangeEnvironment
    }
}
