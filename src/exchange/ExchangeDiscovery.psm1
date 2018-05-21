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

    $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
    $forestName = $domain.Forest.Name
    $forestDN = "DC=$( $ForestName.Replace(".",",DC=") )"

    Get-ExchangeServers -Domain $forestDN
}