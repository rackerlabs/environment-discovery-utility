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
        $forestDN = "DC=$($ForestName.Replace(".",",DC="))"
        $exchangeEnvironment.Add("Servers", [array]$(Get-ExchangeServers -DomainDN $forestDN))
        $exchangeEnvironment.Add("AcceptedDomains", [array]$(Get-ExchangeAcceptedDomains -DomainDN $forestDN))
        $exchangeEnvironment.Add("VirtualDirectories", [array]$(Get-ExchangeVirtualDirectories -DomainDN $forestDN))
        $exchangeEnvironment.Add("Recipients", [array]$(Get-ExchangeRecipients -DomainDN $forestDN -ExchangeShellConnected $exchangeShellConnected))
        $exchangeEnvironment.Add("PublicFolders", $(Start-PublicFolderDiscovery -DomainDN $forestDN -ExchangeShellConnected $exchangeShellConnected))
        $exchangeEnvironment.Add("DynamicGroups", [array]$(Get-ExchangeDynamicGroups -DomainDN $forestDN))
        $exchangeEnvironment.Add("FederationTrusts", [array]$(Get-ExchangeFederationTrust -DomainDN $forestDN))
        $exchangeEnvironment.Add("OrganizationalRelationships", [array]$(Get-ExchangeOrganizationalRelationship -DomainDN $forestDN))
        $exchangeEnvironment.Add("DatabaseJournaling", [array]$(Get-ExchangeDatabaseJournaling -DomainDN $forestDN))
        $exchangeEnvironment.Add("ImapPopSettings", [array]$(Get-ExchangeImapPopSettings -DomainDN $forestDN))
        $exchangeEnvironment.Add("TransportRules", [array]$(Get-ExchangeTransportRules -DomainDN $forestDN -ExchangeShellConnected $exchangeShellConnected))
        $exchangeEnvironment.Add("TransportSettings", [array]$(Get-ExchangeTransportConfig -DomainDN $forestDN))

        Write-Log -Level "VERBOSE" -Activity "Exchange Discovery" -Message "Completed Exchange Discovery." -WriteProgress

        $exchangeEnvironment
    }
}
