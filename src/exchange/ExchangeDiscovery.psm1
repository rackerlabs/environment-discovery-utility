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
        $exchangeEnvironment = @{}
        [bool] $exchangeShellConnected = Initialize-ExchangePowershell
    }
    process
    {
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
        $forestName = $domain.Forest.Name
        $forestDN = "DC=$( $ForestName.Replace(".",",DC=") )"
        $exchangeEnvironment.Add("ExchangeServers", $( Get-ExchangeServers -DomainDN $forestDN ))
        $exchangeEnvironment.Add("ExchangeAcceptedDomains", $( Get-ExchangeAcceptedDomains -DomainDN $forestDN ))
        $exchangeEnvironment.Add("ExchangeVirtualDirectories", $( Get-ExchangeVirtualDirectories -DomainDN $forestDN ))
        $exchangeEnvironment.Add("ExchangeRecipients", $( Get-ExchangeRecipients -DomainDN $forestDN -IncludeStatistics $exchangeShellConnected ))

        $exchangeEnvironment
    }
}