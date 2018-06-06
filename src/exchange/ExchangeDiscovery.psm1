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
        [int]
        $ProgressId,

        [int]
        $ParentProgressId = 99
    )
    begin
    {
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -ProgressId $ProgressId -Message 'Connecting to Exchange PowerShell and starting Exchange Discovery' -ParentProgressId $ParentProgressId
        $exchangeEnvironment = @{}
        [bool]$exchangeShellConnected = Initialize-ExchangePowershell
        clear
    }
    process
    {
        
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
        $forestName = $domain.Forest.Name
        $forestDN = "DC=$( $ForestName.Replace(".",",DC="))"
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -ProgressId $ProgressId -Message 'Searching for Exchange servers' -ParentProgressId $ParentProgressId
        $exchangeEnvironment.Add("ExchangeServers", $(Get-ExchangeServers -DomainDN $forestDN))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -ProgressId $ProgressId -Message 'Finding Exchange accepted domains' -ParentProgressId $ParentProgressId
        $exchangeEnvironment.Add("ExchangeAcceptedDomains", $(Get-ExchangeAcceptedDomains -DomainDN $forestDN))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -ProgressId $ProgressId -Message 'Finding Exchange virtual directories' -ParentProgressId $ParentProgressId
        $exchangeEnvironment.Add("ExchangeVirtualDirectories", $(Get-ExchangeVirtualDirectories -DomainDN $forestDN))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -ProgressId $ProgressId -Message 'Discovering Exchange recipients' -ParentProgressId $ParentProgressId
        $exchangeEnvironment.Add("ExchangeRecipients", $(Get-ExchangeRecipients -DomainDN $forestDN -IncludeStatistics $exchangeShellConnected))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -ProgressId $ProgressId -Message 'Discovering Exchange public folders' -ParentProgressId $ParentProgressId
        $exchangeEnvironment.Add("ExchangePublicFoldersInfrastructure", $(Get-ExchangePublicFolderInfrastructure -DomainDN $forestDN))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -ProgressId $ProgressId -Message 'Gathering public folder statistics' -ParentProgressId $ParentProgressId
        $exchangeEnvironment.Add("ExchangePublicFolderStatistics", $(Get-ExchangePublicFolderStatistics -ExchangeShellConnected $exchangeShellConnected))
        Write-Log -Level 'VERBOSE' -Activity 'Exchange Discovery' -ProgressId $ProgressId -Message 'Completed Exchange Discovery' -ParentProgressId $ParentProgressId -ProgressComplete

        $exchangeEnvironment
    }
}