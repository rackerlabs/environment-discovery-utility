function Start-ExchangeDiscovery
{
    <#
    .SYNOPSIS
        This cmdlet will return information related to the current Active Directory Forest as well as its Domains and Sites.

    .DESCRIPTION
        This cmdlet will return information related to the current Active Directory Forest as well as its Domains and Sites.  This is not meant to be run independently and is part of the Environment Discovery Utility package.

    .OUTPUTS
        A PSObject representation of the discovered Active Directory environment.

    .EXAMPLE
        Start-ActiveDirectoryDiscovery
    #>

    [CmdletBinding()]
    param ()

}