function Get-ExchangeServers
{
    [CmdletBinding()]
    param (
        [string]
        $Domain
    )

    $output = @()
    $baseDN = "CN=Configuration,$($Domain)"
    $strFilter = "(objectClass=msExchExchangeServer)"
    $context = "LDAP://CN=Configuration,$($Domain)"
    [array] $properties = "Name", "serialNumber"

    $output = Search-Directory -context $context -Filter $strFilter -Properties $properties -SearchRoot $baseDN

    $output
}