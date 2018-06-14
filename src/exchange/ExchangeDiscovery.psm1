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
        $exchangeEnvironment.Add("ExchangeServers", [array]$(Get-ExchangeServers -DomainDN $forestDN))
        $exchangeEnvironment.Add("ExchangeAcceptedDomains", [array]$(Get-ExchangeAcceptedDomains -DomainDN $forestDN))
        $exchangeEnvironment.Add("ExchangeVirtualDirectories", [array]$(Get-ExchangeVirtualDirectories -DomainDN $forestDN))
        $exchangeEnvironment.Add("ExchangeRecipients", [array]$(Get-ExchangeRecipients -DomainDN $forestDN -ExchangeShellConnected $exchangeShellConnected))
        $exchangeEnvironment.Add("ExchangePublicFoldersInfrastructure", [array]$(Get-ExchangePublicFolderInfrastructure -DomainDN $forestDN))
        $exchangeEnvironment.Add("ExchangePublicFolderStatistics", [array]$(Get-ExchangePublicFolderStatistics -ExchangeShellConnected $exchangeShellConnected))
        $exchangeEnvironment.Add("ExchangeDynamicGroups", [array]$(Get-ExchangeDynamicGroups -DomainDN $forestDN))
        $exchangeEnvironment.Add("ExchangeFederationTrust", [array]$(Get-ExchangeFederationTrust -DomainDN $forestDN))
        $exchangeEnvironment.Add("ExchangeFederation", [array]$(Get-ExchangeFederation -DomainDN $forestDN))
        $exchangeEnvironment.Add("ExchangeDatabaseJournaling", [array]$(Get-ExchangeDatabaseJournaling -DomainDN $forestDN))
        $exchangeEnvironment.Add("ExchangeImapPopSettings", [array]$(Get-ExchangeImapPopSettings -DomainDN $forestDN))
        $exchangeEnvironment.Add("ExchangeTransportRules", [array]$(Get-ExchangeTransportRules -DomainDN $forestDN -ExchangeShellConnected $exchangeShellConnected))
        Write-Log -Level "VERBOSE" -Activity "Exchange Discovery" -Message "Completed Exchange Discovery." -WriteProgress

        $exchangeEnvironment
    }
}
