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
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -Message 'Attempting to connect to Exchange PowerShell' -WriteProgress
        $exchangeEnvironment = @{}
        [bool]$exchangeShellConnected = Initialize-ExchangePowershell
        clear
    }
    process
    {
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
        $forestName = $domain.Forest.Name
        $forestDN = "DC=$( $ForestName.Replace(".",",DC="))"
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -Message 'Searching for Exchange servers' -WriteProgress
        $exchangeEnvironment.Add("ExchangeServers", $(Get-ExchangeServers -DomainDN $forestDN))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -Message 'Finding Exchange accepted domains' -WriteProgress
        $exchangeEnvironment.Add("ExchangeAcceptedDomains", $(Get-ExchangeAcceptedDomains -DomainDN $forestDN))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -Message 'Finding Exchange virtual directories' -WriteProgress
        $exchangeEnvironment.Add("ExchangeVirtualDirectories", $(Get-ExchangeVirtualDirectories -DomainDN $forestDN))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -Message 'Discovering Exchange recipients' -WriteProgress
        $exchangeEnvironment.Add("ExchangeRecipients", $(Get-ExchangeRecipients -DomainDN $forestDN -ExchangeShellConnected $exchangeShellConnected))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -Message 'Discovering Exchange public folders' -WriteProgress
        $exchangeEnvironment.Add("ExchangePublicFoldersInfrastructure", $(Get-ExchangePublicFolderInfrastructure -DomainDN $forestDN))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -Message 'Gathering public folder statistics' -WriteProgress
        $exchangeEnvironment.Add("ExchangePublicFolderStatistics", $(Get-ExchangePublicFolderStatistics -ExchangeShellConnected $exchangeShellConnected))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -Message 'Completed Exchange Discovery' -WriteProgress

        $exchangeEnvironment
    }
}
